// Database Configuration
import { createPool, Pool } from 'mysql2/promise';
import dotenv from 'dotenv';

const databasePool: Pool = createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

export default databasePool;
