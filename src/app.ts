import express from 'express';
import userRoutes from './routes/userRoutes'
import blogRoutes from './routes/blogRoutes';
import swaggerUi from 'swagger-ui-express';
import swaggerJsDoc from 'swagger-jsdoc';
import { config } from 'dotenv';
import dotenv from 'dotenv';
import configureSwagger from './swaggerConfig';
import  databasePool  from './config/database';

// Load environment variables from .env file
dotenv.config();
config();

// creat Tables
const createTables = async () => {
  try {

    const createUsersTable = `
      CREATE TABLE IF NOT EXISTS Users (
        id INT PRIMARY KEY AUTO_INCREMENT,
        username VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL
      );
    `;

    const createBlogsTable = `
      CREATE TABLE IF NOT EXISTS Blogs (
        id INT PRIMARY KEY AUTO_INCREMENT,
        user_id INT NOT NULL,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES Users(id)
      );
    `;

    await databasePool.query(createUsersTable);
    await databasePool.query(createBlogsTable);

    console.log('Tables created successfully');
  } catch (err: any) {
    console.error('Error creating tables:', err);
  }
};

createTables();

const app = express();
app.use(express.json());
app.use('/users', userRoutes);
app.use('/blogs', blogRoutes);
// Serve Swagger documentation
configureSwagger(app);

export default app;