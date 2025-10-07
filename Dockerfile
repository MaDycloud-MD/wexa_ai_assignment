# Stage 1: Builder - Install dependencies and build the application
FROM node:22-alpine AS builder
WORKDIR /app

# Copy package files and install dependencies to leverage Docker layer caching
COPY package*.json ./
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the Next.js application
RUN npm run build

# Stage 2: Runner - Create the final, optimized image
FROM node:18-alpine AS runner
WORKDIR /app

# Create a non-root user for security best practices
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Copy build artifacts from the builder stage
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Switch to the non-root user
USER nextjs

# Expose the port the app runs on
EXPOSE 3000

# Set the command to start the application
CMD ["npm", "start"]