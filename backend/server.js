require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');

const app = express();
app.use(cors());
app.use(express.json());

const mongoURI = process.env.MONGO_URI;
const dbName = process.env.MONGO_DB || 'hurdo';
const port = process.env.PORT || 4000;

// Mongoose connection
async function start() {
  try {
    const conn = await mongoose.connect(mongoURI, { dbName });
    console.log('✅ MongoDB connected');

  const db = conn.connection.db;

  // Serve admin UI
    app.use(express.static('public'));

    // Health check
    app.get('/health', (req, res) => res.json({ ok: true }));

    // Prefer Supabase automatically when credentials are present.
    // You can also force Supabase-only mode with ONLY_SUPABASE=true
    // Require Supabase for file storage. This server uses MongoDB for metadata and
    // Supabase buckets for the actual file blobs. GridFS support has been removed.
    const hasSupabaseCreds = Boolean(process.env.SUPABASE_URL && (process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY));
    if (!hasSupabaseCreds) {
      console.error('Supabase not configured. Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY (recommended)');
      process.exit(1);
    }
    const sb = require('./supabase');
    const uploadToBucket = sb.uploadToBucket;
    // use memory storage, upload buffers to Supabase
    const upload = multer({ storage: multer.memoryStorage() });
    console.log('Using Supabase storage for uploads (GridFS removed)');

    // Sound metadata schema
    const SoundSchema = new mongoose.Schema({
      title: String,
      description: String,
      soundFileId: String, // public URL from Supabase
      artFileId: String,
      // when using Supabase store object path so we can delete later
      soundFilePath: String,
      artFilePath: String,
      createdAt: { type: Date, default: Date.now }
    });
    const Sound = mongoose.model('Sound', SoundSchema);

    // Helper to sanitize filenames for upload
    function sanitizeFilename(name) {
      if (!name) return `${Date.now()}`;
      // remove path characters, control chars, and replace spaces with dashes
      return name
        .replace(/[^A-Za-z0-9._-]/g, '-')
        .replace(/-+/g, '-')
        .replace(/^[-_.]+|[-_.]+$/g, '') || `${Date.now()}`;
    }

    // Upload: fields 'sound' and 'art'
    app.post('/sounds', upload.fields([{ name: 'sound' }, { name: 'art' }]), async (req, res) => {
      try {
  let soundFileId = null;
  let artFileId = null;
  let soundFilePath = null;
  let artFilePath = null;
        // upload buffers to Supabase buckets
        const soundBuf = req.files['sound']?.[0]?.buffer;
        const rawSoundName = req.files['sound']?.[0]?.originalname || 'sound';
        const soundName = `${Date.now()}-${sanitizeFilename(rawSoundName)}`;
        const artBuf = req.files['art']?.[0]?.buffer;
        const rawArtName = req.files['art']?.[0]?.originalname || 'art';
        const artName = artBuf ? `${Date.now()}-${sanitizeFilename(rawArtName)}` : null;
        if (soundBuf) {
          const { url, path } = await uploadToBucket('sounds', soundBuf, soundName, req.files['sound'][0].mimetype);
          soundFileId = url; // public URL for playback (may be null if URL couldn't be created)
          soundFilePath = path; // object path for deletion
          // If we couldn't obtain a public URL, clean up the uploaded object and return an error.
          if (!soundFileId) {
            try {
              // path is 'bucket/filename'
              if (soundFilePath) {
                const [bucket, ...parts] = soundFilePath.split('/');
                const objectPath = parts.join('/');
                await sb.supabase.storage.from(bucket).remove([objectPath]);
              }
            } catch (cleanupErr) {
              console.error('Failed to cleanup uploaded sound after missing public URL', cleanupErr);
            }
            return res.status(500).json({ error: 'Upload succeeded but a public URL could not be generated. Ensure SUPABASE_SERVICE_ROLE_KEY is set or buckets are public.' });
          }
          console.log('Uploaded sound -> url:', soundFileId, 'path:', soundFilePath);
        }
        if (artBuf) {
          const { url, path } = await uploadToBucket('images', artBuf, artName, req.files['art'][0].mimetype);
          artFileId = url;
          artFilePath = path;
          // if artwork didn't produce a public URL, attempt cleanup but continue (art is optional)
          if (!artFileId && artFilePath) {
            try {
              const [bucket, ...parts] = artFilePath.split('/');
              const objectPath = parts.join('/');
              await sb.supabase.storage.from(bucket).remove([objectPath]);
              artFilePath = null;
            } catch (e) {
              console.error('Failed to cleanup uploaded art after missing public URL', e);
            }
            artFileId = null;
          }
          if (artFileId) console.log('Uploaded art -> url:', artFileId, 'path:', artFilePath);
        }

        const doc = await Sound.create({
          title: req.body.title || 'Untitled',
          description: req.body.description || '',
          soundFileId,
          artFileId,
          soundFilePath,
          artFilePath
        });
        res.json(doc);
      } catch (err) {
        console.error('Upload failed', err);
        res.status(500).send('Upload failed');
      }
    });

    // List sounds (only return items with valid http(s) sound URLs)
    app.get('/sounds', async (req, res) => {
      const list = await Sound.find().sort({ createdAt: -1 }).lean();
      // filter to ensure we only return entries with usable soundFileId
      const filtered = list.filter((d) => {
        const s = d.soundFileId;
        return typeof s === 'string' && (s.startsWith('http://') || s.startsWith('https://'));
      });

      // Determine skipped items and reasons for easier debugging
      const skipped = list.filter((d) => {
        const s = d.soundFileId;
        return !(typeof s === 'string' && (s.startsWith('http://') || s.startsWith('https://')));
      });

      // Log returned URLs for debugging
      console.log('GET /sounds returning', filtered.length, 'items');
      filtered.forEach((d) => console.log(' ->', d.soundFileId, d.artFileId || '(no art)'));

      // Log skipped items with reason so developers can see what was filtered out
      if (skipped.length) {
        console.log('GET /sounds skipped', skipped.length, 'items (not valid http(s) soundFileId)');
        skipped.forEach((d) => {
          const s = d.soundFileId;
          let reason = 'unknown';
          if (s === undefined || s === null) reason = 'missing soundFileId';
          else if (typeof s !== 'string') reason = `soundFileId not a string (type=${typeof s})`;
          else if (!s.startsWith('http://') && !s.startsWith('https://')) reason = `non-http soundFileId: ${s}`;
          console.log(` - id:${d._id} title:"${d.title || ''}" reason:${reason}`);
        });
      }

      res.json(filtered);
    });

  // Note: /files route removed. Supabase public URLs are stored in soundFileId/artFileId

    // Delete sound and associated files
    app.delete('/sounds/:id', async (req, res) => {
      try {
        const id = req.params.id;
        const doc = await Sound.findById(id);
        if (!doc) return res.status(404).send('Not found');
        try {
          const sb = require('./supabase');
          // soundFilePath/artFilePath are stored as bucket/path
          if (doc.soundFilePath) {
            const [bucket, ...parts] = doc.soundFilePath.split('/');
            const path = parts.join('/');
            await sb.supabase.storage.from(bucket).remove([path]);
          }
          if (doc.artFilePath) {
            const [bucket, ...parts] = doc.artFilePath.split('/');
            const path = parts.join('/');
            await sb.supabase.storage.from(bucket).remove([path]);
          }
        } catch (e) {
          console.error('Failed to delete supabase objects', e);
        }
        await doc.remove();
        res.send('deleted');
      } catch (e) {
        console.error('Delete failed', e);
        res.status(500).send('delete failed');
      }
    });

    // Admin endpoint to make Supabase buckets public (requires ADMIN_TOKEN)
    app.post('/supabase/make-public', async (req, res) => {
      try {
        const token = req.headers['x-admin-token'] || req.body.token;
        if (process.env.ADMIN_TOKEN && token !== process.env.ADMIN_TOKEN) return res.status(403).send('forbidden');
  if (!hasSupabaseCreds) return res.status(400).send('Supabase not enabled');
  await sb.ensureBucketPublic('sounds');
  await sb.ensureBucketPublic('images');
        res.json({ ok: true });
      } catch (e) {
        console.error('Supabase make-public failed', e);
        res.status(500).send('failed');
      }
    });

  // Note: programmatic Postgres/Supabase policy application was removed to keep the server Mongo-first.
  // If you still want to apply SQL policies programmatically, re-add a secured endpoint that connects
  // to Postgres and runs the desired SQL. See backend/SUPABASE_RULES.md for recommended SQL snippets.

    app.listen(port, () => console.log('Server running on port', port));
  } catch (err) {
    console.error('Failed to connect to MongoDB:', err);
    process.exit(1);
  }
}

start();
