import express from 'express';
import userRoutes from './routes/userRoutes'
import blogRoutes from './routes/blogRoutes';
import swaggerUi from 'swagger-ui-express';
import swaggerJsDoc from 'swagger-jsdoc';
import dotenv from 'dotenv';
import configureSwagger from './swaggerConfig';

dotenv.config();

const app = express();
app.use(express.json());
app.use('/users', userRoutes);
app.use('/blogs', blogRoutes);
// Serve Swagger documentation
configureSwagger(app);

export default app;