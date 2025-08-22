const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

// Prefer the service_role key for server operations (required for storage uploads, bucket management)
const effectiveKey = SUPABASE_SERVICE_ROLE_KEY || SUPABASE_KEY;

let supabase = null;
if (SUPABASE_URL && effectiveKey) {
  supabase = createClient(SUPABASE_URL, effectiveKey);
} else {
  console.warn('Supabase not fully configured: set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY (recommended) or SUPABASE_KEY');
}

async function uploadToBucket(bucket, fileBuffer, filename, contentType){
  if(!supabase) throw new Error('Supabase not configured - please set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in your .env for server uploads');
  try {
    const { data, error } = await supabase.storage.from(bucket).upload(filename, fileBuffer, { contentType, upsert: true });
    if(error) throw error;

    // Try to get a public URL first
    let publicURL = null;
    try {
      const { data: pu, error: e2 } = await supabase.storage.from(bucket).getPublicUrl(filename);
      if (e2) throw e2;
      publicURL = pu?.publicUrl || pu?.publicURL || null;
    } catch (e) {
      // ignore and attempt remediation below
      publicURL = null;
    }

    // If we didn't get a public URL, and we have service-role privileges, try to make bucket public and retry
    if (!publicURL && SUPABASE_SERVICE_ROLE_KEY) {
      try {
        await ensureBucketPublic(bucket);
        const { data: pu2, error: e3 } = await supabase.storage.from(bucket).getPublicUrl(filename);
        if (!e3) publicURL = pu2?.publicUrl || pu2?.publicURL || null;
      } catch (e) {
        // ignore here and fall through to signed URL attempt
        publicURL = null;
      }
    }

    // As a last resort, if we still don't have a public URL and we have service-role key, create a signed URL
    if (!publicURL && SUPABASE_SERVICE_ROLE_KEY) {
      try {
        // create a long-lived signed URL (30 days). Adjust expiry as needed.
        const expiresIn = 60 * 60 * 24 * 30;
        const { data: signed, error: e4 } = await supabase.storage.from(bucket).createSignedUrl(filename, expiresIn);
        if (e4) throw e4;
        publicURL = signed?.signedUrl || null;
      } catch (e) {
        // if this fails, we'll throw below
        publicURL = null;
      }
    }

    // return both public URL (may be null if nothing worked) and object path for later deletion
    return { url: publicURL, path: `${bucket}/${filename}` };
  } catch (err) {
    // Provide a clearer message for common permission errors
    if (err && err.status === 403) {
      const msg = 'Supabase storage upload failed with 403. Likely causes: using an anon/public key instead of the service_role key, or RLS/storage policies blocking insert. Set SUPABASE_SERVICE_ROLE_KEY to your service role key and ensure the bucket exists or create it via the admin endpoint.';
      const e = new Error(msg);
      e.cause = err;
      throw e;
    }
    throw err;
  }
}

async function ensureBucketPublic(bucket){
  if(!supabase) throw new Error('Supabase not configured');
  // create bucket if not exists
  const { data: list } = await supabase.storage.list();
  const exists = list.some(b => b.name === bucket);
  if(!exists){
    console.log('Creating bucket', bucket, 'and setting public');
    const { error: e } = await supabase.storage.createBucket(bucket, { public: true });
    if(e) {
      console.error('Failed to create bucket', bucket, e);
      throw e;
    }
    return { created: true };
  }
  // update bucket to public
  console.log('Updating bucket', bucket, 'to public');
  const { error } = await supabase.storage.updateBucket(bucket, { public: true });
  if(error) {
    console.error('Failed to update bucket to public', bucket, error);
    throw error;
  }
  return { updated: true };
}

module.exports = { supabase, uploadToBucket, ensureBucketPublic };
