FROM node:18-alpine

# Set working directory inside container
WORKDIR /usr/src/app

# Copy package manifests first for efficient layer caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application source code
COPY . .

# Expose port
EXPOSE 5000

# Start server
CMD ["npm", "start"]
