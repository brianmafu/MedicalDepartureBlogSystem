# Use the official Node.js image.
FROM node:14

# Create and change to the app directory.
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
COPY package*.json ./
# Copy swagger.json to dist/ directory.
COPY ./src/swagger.json ./dist/swagger.json
# Install dependencies.
RUN npm install

# Copy local code to the container image.
COPY . .

# Build the TypeScript code.
RUN npm run build

# Run the web service on container startup.
CMD ["node", "dist/server.js"]
