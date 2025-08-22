MongoDB Atlas quick setup for Hurdo backend

Checklist
- Create a MongoDB Atlas account and cluster
- Create a database user and whitelist your IP (or allow 0.0.0.0/0 for testing)
- Copy the connection string and put it in `backend/.env` as `MONGO_URI`
- Test connection and start the backend

1) Create a free Atlas cluster
- Go to https://www.mongodb.com/cloud/atlas and sign up or sign in.
- Create a new Project then "Build a Cluster" and choose the free tier (Shared Cluster Atlas).
- Wait a few minutes until the cluster status is "ACTIVE".

2) Add Network Access (IP whitelist)
- In the Atlas UI go to Network Access → Add IP Address.
- For quick testing you can add `0.0.0.0/0` (allows any IP). For security, instead add your current public IP.

3) Create a database user
- In Database Access → Create New Database User.
- Choose a username and password (note them down). Give it the built-in role `readWrite` on the new database or `Atlas admin` for convenience during development.

4) Get the connection string
- In the cluster view, click "Connect" → "Connect your application" → copy the connection string.
- It will look like either:
  - mongodb+srv://<username>:<password>@cluster0.abcd.mongodb.net/<dbname>?retryWrites=true&w=majority
  - or mongodb://<username>:<password>@host1:27017,host2:27017/<dbname>?replicaSet=...
- Replace `<username>`, `<password>`, and `<dbname>` (e.g., `hurdo`) in the string.

5) Create `backend/.env`
- Copy `backend/.env.example` to `backend/.env` and edit it.

Example `.env` (do not commit this file):

MONGO_URI=mongodb+srv://myuser:mypassword@cluster0.abcd.mongodb.net/hurdo?retryWrites=true&w=majority
PORT=4000

6) Test connection from your machine (Node)
- From the `backend/` folder run:

```powershell
# on Windows PowerShell
$env:MONGO_URI = "mongodb+srv://myuser:mypassword@cluster0.abcd.mongodb.net/hurdo?retryWrites=true&w=majority"
node -e "const mongoose=require('mongoose'); mongoose.connect(process.env.MONGO_URI).then(()=>{console.log('connected'); process.exit()}).catch(e=>{console.error(e); process.exit(1)})"
```

- Or install `mongosh` and test:

```powershell
mongosh "mongodb+srv://myuser:mypassword@cluster0.abcd.mongodb.net/hurdo"
```

7) Run the backend
```powershell
cd backend
npm install
npm run dev
```
- The server uses `process.env.MONGO_URI` (the `.env` file) so once the `.env` is set the server will connect to Atlas.

8) Quick upload test (use curl to upload a sound + art)
- Replace IDs and file paths as needed.

```powershell
curl -X POST "http://localhost:4000/sounds" -F "title=Test Sound" -F "sound=@C:/path/to/sample.mp3" -F "art=@C:/path/to/art.jpg"
```

9) Fetch list from Flutter (example)
- GET `http://your-server:4000/sounds` -> returns JSON array with `soundFileId` and `artFileId`.
- Note: this backend no longer exposes `/files/<id>`. When using Supabase, `soundFileId` and `artFileId` will be public URLs.

Notes & Tips
- For production never use `0.0.0.0/0` for IP access. Use the app server IP or a more limited range.
- Keep your `.env` secret and do not commit it to git.
- If you prefer, I can walk you through copying the exact connection string and filling `.env` here. I cannot create or access your Atlas account for you, but I can guide every step and verify the `.env` you paste.

If you want, paste the Atlas connection string _without the password_ and I will generate the exact `.env` contents and the `curl` example with placeholders.

Optional: Use Supabase storage instead of GridFS
------------------------------------------------
- Create a Supabase project and two buckets named `sounds` and `images`.
- In Supabase Settings → API copy the `SUPABASE_URL` and `SUPABASE_KEY` (service role or anon key as appropriate).
- In `backend/.env` add:

```
USE_SUPABASE=true
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-key
```

When `USE_SUPABASE=true` the backend will upload files to Supabase and store public URLs in the `sounds` documents. Deletion of files in Supabase is not implemented here and should be done via Supabase dashboard or API.
