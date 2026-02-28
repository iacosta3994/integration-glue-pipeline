import express from 'express';
import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';
import { Client as NotionClient } from '@notionhq/client';
import logger from './utils/logger.js';
import { syncData } from './services/sync.js';
import { setupCronJobs } from './services/scheduler.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize clients
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

const notion = new NotionClient({
  auth: process.env.NOTION_TOKEN,
});

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
  });
});

// Sync endpoint
app.post('/sync', async (req, res) => {
  try {
    logger.info('Starting manual sync');
    await syncData(supabase, notion);
    res.json({ success: true, message: 'Sync completed successfully' });
  } catch (error) {
    logger.error('Sync failed:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Start server
app.listen(PORT, () => {
  logger.info(`Integration glue pipeline running on port ${PORT}`);
  
  // Setup scheduled jobs
  setupCronJobs(supabase, notion);
});

export { supabase, notion };
