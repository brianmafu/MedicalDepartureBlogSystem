import swaggerUi from 'swagger-ui-express';
import fs from 'fs';
import path from 'path';

const swaggerPath = path.resolve(__dirname, 'swagger.json');
const swaggerDocument = JSON.parse(fs.readFileSync(swaggerPath, 'utf8'));

export default function configureSwagger(app:any) {
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
}