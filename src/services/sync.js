import logger from '../utils/logger.js';

export async function syncData(supabase, notion) {
  try {
    logger.info('Starting data synchronization');

    // Fetch data from Supabase
    const { data: records, error } = await supabase
      .from(process.env.SUPABASE_TABLE || 'records')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(100);

    if (error) throw error;

    logger.info(`Fetched ${records?.length || 0} records from Supabase`);

    // Sync to Notion
    if (records && records.length > 0) {
      for (const record of records) {
        await syncToNotion(notion, record);
      }
    }

    logger.info('Data synchronization completed successfully');
    return { success: true, recordsProcessed: records?.length || 0 };
  } catch (error) {
    logger.error('Sync error:', error);
    throw error;
  }
}

async function syncToNotion(notion, record) {
  try {
    const databaseId = process.env.NOTION_DATABASE_ID;
    
    await notion.pages.create({
      parent: { database_id: databaseId },
      properties: {
        Name: {
          title: [
            {
              text: {
                content: record.name || 'Untitled',
              },
            },
          ],
        },
        Status: {
          select: {
            name: record.status || 'New',
          },
        },
        'Created At': {
          date: {
            start: record.created_at,
          },
        },
      },
    });

    logger.info(`Synced record ${record.id} to Notion`);
  } catch (error) {
    logger.error(`Failed to sync record ${record.id}:`, error);
  }
}
