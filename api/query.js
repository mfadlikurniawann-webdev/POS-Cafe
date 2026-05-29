import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  // CORS configuration for local development
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  try {
    const { query, params } = req.body;
    
    if (!query) {
      return res.status(400).json({ error: 'Query is required' });
    }

    // Connect to Neon Database
    const sql = neon('postgresql://neondb_owner:npg_dwc7rRCm4uZo@ep-royal-surf-aopa38s3-pooler.c-2.ap-southeast-1.aws.neon.tech/neondb?sslmode=require');
    
    let processedQuery = query;
    let processedParams = [];

    if (params && typeof params === 'object' && !Array.isArray(params)) {
      let paramIndex = 1;
      processedQuery = query.replace(/@([a-zA-Z0-9_]+)/g, (match, paramName) => {
        if (params[paramName] !== undefined) {
          processedParams.push(params[paramName]);
          return `$${paramIndex++}`;
        }
        return match;
      });
    } else {
      processedParams = params || [];
    }

    // Execute query
    const result = await sql(processedQuery, processedParams);
    
    return res.status(200).json({ data: result });
  } catch (error) {
    console.error('Database query error:', error);
    return res.status(500).json({ error: error.message });
  }
}
