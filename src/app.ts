import express from 'express';
import userRoutes from './routes/userRoutes.ts';
import blogRoutes from './routes/blogRoutes.ts';
import swaggerUi from 'swagger-ui-express';
import swaggerJsDoc from 'swagger-jsdoc';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
app.use(express.json());

const swaggerOptions = {
	swaggerDefinition: {
		info: {
			title: 'Medical Departure Blog API',
			description: 'Medical Departure Blog API Information',
			servers: ['http://localhost:5000']
		}
	},
	apis: ['./routes/*.ts']
};

const swaggerDocs = swaggerJsDoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));
app.use('/users', userRoutes);
app.use('/blogs', blogRoutes);

export default app;