import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const SERVICES = [
  {
    name: 'Application',
    url: process.env.APP_URL || 'http://localhost:3000/health',
  },
  {
    name: 'Netlify',
    url: process.env.NETLIFY_SITE_URL,
  },
  {
    name: 'Supabase',
    url: `${process.env.SUPABASE_URL}/rest/v1/`,
  },
];

async function checkHealth() {
  console.log('🏥 Starting health checks...\n');
  
  let allHealthy = true;

  for (const service of SERVICES) {
    if (!service.url) {
      console.log(`⚠️  ${service.name}: URL not configured`);
      continue;
    }

    try {
      const response = await axios.get(service.url, { timeout: 5000 });
      if (response.status === 200) {
        console.log(`✅ ${service.name}: Healthy`);
      } else {
        console.log(`❌ ${service.name}: Unhealthy (Status: ${response.status})`);
        allHealthy = false;
      }
    } catch (error) {
      console.log(`❌ ${service.name}: Unreachable (${error.message})`);
      allHealthy = false;
    }
  }

  console.log('\n' + (allHealthy ? '✅ All services healthy' : '❌ Some services unhealthy'));
  process.exit(allHealthy ? 0 : 1);
}

checkHealth();
