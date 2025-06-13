# Build stage
FROM node:21-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source code
COPY frontend .

# Build the application
RUN npm run build

# Production stage
FROM node:21-alpine AS production

WORKDIR /app

# Copy built application
COPY --from=builder /app/build ./build
COPY --from=builder /app/package*.json ./

# Install production dependencies
RUN npm ci --production

# Expose the port the app runs on
EXPOSE 3000

# Start the application
CMD ["node", "build"]
