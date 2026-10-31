# Multi-stage lightweight Node.js container
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install build dependencies
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy application source
COPY . .

# Ensure uploads directory exists
RUN mkdir -p uploads

# Expose server port
EXPOSE 5000

# Environment variables default
ENV NODE_ENV=production
ENV PORT=5000

# Start command
CMD ["npm", "start"]
