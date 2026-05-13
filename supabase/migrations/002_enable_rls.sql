-- Enable Row-Level Security for the Supabase schema
-- Preserve public read access to records for the app's anon key
-- Keep sync_logs private to authenticated/service usage

-- records: public read, authenticated write access
ALTER TABLE public.records ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read access to records" ON public.records;
CREATE POLICY "Public read access to records"
ON public.records
FOR SELECT
TO anon, authenticated
USING (true);

DROP POLICY IF EXISTS "Authenticated insert records" ON public.records;
CREATE POLICY "Authenticated insert records"
ON public.records
FOR INSERT
TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS "Authenticated update records" ON public.records;
CREATE POLICY "Authenticated update records"
ON public.records
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Authenticated delete records" ON public.records;
CREATE POLICY "Authenticated delete records"
ON public.records
FOR DELETE
TO authenticated
USING (true);

-- sync_logs: keep internal only
ALTER TABLE public.sync_logs ENABLE ROW LEVEL SECURITY;

-- Remove anonymous access that was granted in the initial schema
REVOKE SELECT ON public.sync_logs FROM anon;
