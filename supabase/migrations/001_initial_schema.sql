-- Initial Database Schema
-- Integration Glue Pipeline
-- Author: Ian Acosta
-- Created: 2026-02-27

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Records table
CREATE TABLE IF NOT EXISTS public.records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'New',
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sync logs table
CREATE TABLE IF NOT EXISTS public.sync_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  source TEXT NOT NULL,
  destination TEXT NOT NULL,
  record_id UUID REFERENCES public.records(id),
  status TEXT NOT NULL,
  error_message TEXT,
  synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_records_status ON public.records(status);
CREATE INDEX IF NOT EXISTS idx_records_created_at ON public.records(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sync_logs_record_id ON public.sync_logs(record_id);
CREATE INDEX IF NOT EXISTS idx_sync_logs_synced_at ON public.sync_logs(synced_at DESC);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to records table
CREATE TRIGGER update_records_updated_at
  BEFORE UPDATE ON public.records
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO public.records (name, description, status) VALUES
  ('Sample Record 1', 'This is a test record', 'Active'),
  ('Sample Record 2', 'Another test record', 'Pending'),
  ('Sample Record 3', 'Third test record', 'Completed');

-- Grant permissions
GRANT ALL ON public.records TO authenticated;
GRANT ALL ON public.sync_logs TO authenticated;
GRANT SELECT ON public.records TO anon;
GRANT SELECT ON public.sync_logs TO anon;

COMMENT ON TABLE public.records IS 'Main records table for integration data';
COMMENT ON TABLE public.sync_logs IS 'Logs for tracking sync operations between services';
