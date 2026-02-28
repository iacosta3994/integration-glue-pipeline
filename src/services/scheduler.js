import cron from 'node-cron';
import { syncData } from './sync.js';
import logger from '../utils/logger.js';

export function setupCronJobs(supabase, notion) {
  // Run sync every hour
  cron.schedule('0 * * * *', async () => {
    logger.info('Running scheduled sync');
    try {
      await syncData(supabase, notion);
    } catch (error) {
      logger.error('Scheduled sync failed:', error);
    }
  });

  logger.info('Cron jobs scheduled successfully');
}
