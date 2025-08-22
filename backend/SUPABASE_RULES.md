# Supabase Rules & Policies — Manual Input Guide (Detailed)

This document provides explicit step-by-step rules and exact SQL snippets you can paste into the Supabase SQL editor. Use these if you plan to input rules manually in the Dashboard SQL editor or via the SQL API.

Important notes before you start
- The server should use the `SUPABASE_SERVICE_ROLE_KEY` for storage admin/upload operations. The service role key bypasses Row-Level Security (RLS).
- Clients (Flutter/mobile/web) should use the anon/public key (`SUPABASE_KEY`) and only perform read operations against public buckets or via signed URLs.
- When you set policies, prefer the least-privilege approach: public read for playback, strict insert/update/delete rules.

---

## A. Environment variables (reminder)

Add to your `.env` or environment settings on the server:

```
SUPABASE_URL=https://<your-project>.supabase.co
SUPABASE_KEY=<anon-public-key>                # client-side read-only key
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>  # server-only secret key
ADMIN_TOKEN=<admin-token>                     # protects admin endpoints (optional)
ONLY_SUPABASE=true                            # optional: force backend to use Supabase
```

Obtain the Service Role Key from Supabase → Project Settings → API → Service Role Key.

---

## B. Buckets: create and make public (manual steps)

Dashboard steps (recommended for manual setup):
1. Open Supabase Dashboard → `Storage` → `Buckets` → `New bucket`.
2. Create a bucket named `sounds`. Toggle **Public** = ON to allow public URLs.
3. Create a bucket named `images`. Toggle **Public** = ON.

If you prefer SQL/CLI automation, use the `supabase` CLI or the REST API. The repo includes `ensureBucketPublic()` which can create/update buckets programmatically.

---

## C. Storage object policies (exact SQL you can paste)

Supabase storage uses the `storage.objects` table. The following example policies are conservative and assume:
- public read for objects in `sounds` and `images`
- inserts are allowed only for authenticated users (or server via service role)
- deletes and updates allowed only for the object owner

Open Supabase → SQL Editor, then paste and run the snippets below.

1) Make sure RLS is enabled for storage.objects (it usually is by default):

```sql
-- Enable RLS (if not already enabled)
ALTER TABLE IF EXISTS storage.objects ENABLE ROW LEVEL SECURITY;
```

2) Allow public SELECT (read) for objects in `sounds` and `images` only:

```sql
-- Public read for the sounds bucket
CREATE POLICY public_read_sounds
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'sounds');

-- Public read for the images bucket
CREATE POLICY public_read_images
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'images');
```

3) Allow INSERT only for authenticated users (server with service_role bypasses RLS automatically):

```sql
CREATE POLICY insert_authenticated
  ON storage.objects
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
```

Notes about INSERT: the `storage.objects` table `owner` column is set by Supabase when objects are created via the storage API and is normally the user's `auth.uid()` when using client uploads. If you want the server to set owner explicitly, perform inserts/metadata updates server-side and use the service role key (service role bypasses RLS).

4) Allow UPDATE/DELETE only by owner (object owner == auth.uid()):

```sql
CREATE POLICY owner_modify_storage_objects
  ON storage.objects
  FOR UPDATE, DELETE
  USING (auth.uid() = owner);
```

Important: when the server uses the service role key, it bypasses RLS policies and can insert/delete regardless of these policies — that is expected for server management.

---

## D. Example `sounds` metadata table and RLS (if you store metadata in Postgres)

If instead of Mongo you keep metadata in Supabase Postgres, create a `sounds` table and use RLS to protect it.

1) Table creation:

```sql
create table public.sounds (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  sound_url text not null,
  art_url text,
  owner uuid references auth.users(id),
  created_at timestamptz default now()
);
```

2) Enable RLS and policies:

```sql
alter table public.sounds enable row level security;

-- allow public reads
create policy public_select_sounds on public.sounds
  for select using (true);

-- allow authenticated users to insert rows; server can use service role
create policy insert_if_authenticated on public.sounds
  for insert with check (auth.uid() IS NOT NULL AND owner = auth.uid());

-- allow owners to update/delete their rows
create policy owner_modify_sounds on public.sounds
  for update, delete using (auth.uid() = owner);
```

Tip: If your admin UI posts metadata to the server (recommended), the server may insert rows using the service role key so you don't need to rely on client-side auth for metadata inserts.

---

## E. Signed URLs for private buckets (optional)

If you keep the bucket private, create temporary signed URLs for playback. Example server-side snippet:

```js
// server-side (using service role key)
const { data, error } = await supabase.storage.from('sounds').createSignedUrl('path/to/file.mp3', 60);
// data.signedUrl
```

The Flutter app can use the `signedUrl` for short-lived playback.

---

## F. Common troubleshooting & diagnostics

- Error: `StorageApiError: new row violates row-level security policy` or HTTP 403 on upload
  - Cause: using the anon/public key for upload or bucket policies prevent insert.
  - Fix: set `SUPABASE_SERVICE_ROLE_KEY` on the server, restart, then retry upload. Or temporarily run `ensureBucketPublic('sounds')` from your admin UI.

- Files return 403 when opened in browser
  - Cause: bucket not public.
  - Fix: make the bucket public via Dashboard or run `POST /supabase/make-public` using your admin token.

- Want to test policies manually
  - Use the SQL editor → run the policy SQL above.
  - Test as an authenticated user in Supabase Studio → Storage → try upload/download with anon key vs service role key.

---

## G. Recommended production checklist

- [ ] Keep `SUPABASE_SERVICE_ROLE_KEY` server-only and rotate keys if leaked.
- [ ] Protect admin endpoints with `ADMIN_TOKEN` or real user authentication.
- [ ] Use public buckets only for content intended to be public; use signed URLs for private content.
- [ ] Implement server-side deletion that removes both DB metadata and Supabase objects (the repo includes deletion logic but verify `soundFilePath` format).

---

If you'd like, I can add a `/admin/diag` endpoint that checks `supabase.storage.list()` and `supabase.storage.from(bucket).list()` so the admin UI can show bucket existence and whether the service role key appears to work. Would you like me to add that endpoint? 
