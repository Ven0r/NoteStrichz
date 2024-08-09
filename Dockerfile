# Stage 1: Build the SvelteKit application
FROM node:20 AS build

# Set the working directory
WORKDIR /usr/src/app

# Copy the package.json, package-lock.json, and tsconfig.json files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies with retry and logging
RUN set -e; \
    for i in $(seq 1 5); do \
        npm ci && break || (echo "npm ci failed on attempt $i"; \
        if [ $i -eq 5 ]; then exit 1; fi; \
        sleep 10); \
    done

# Add node_modules/.bin to PATH
ENV PATH=/usr/src/app/node_modules/.bin:$PATH

# Run svelte-kit sync to ensure .svelte-kit directory is available
RUN npx svelte-kit sync

# Copy the rest of the application code
COPY . ./

# Build the app for production using npx vite directly
RUN set -e; \
    for i in $(seq 1 5); do \
        npx vite build && break || (echo "Vite build failed on attempt $i"; \
        if [ $i -eq 5 ]; then exit 1; fi; \
        sleep 10); \
    done

# Check if the build directory is created and list its contents
RUN ls -la .svelte-kit/output

# Stage 2: Serve the SvelteKit application with Nginx
FROM nginx:alpine

# Copy the built app from the previous stage
COPY --from=build /usr/src/app/.svelte-kit/output /usr/share/nginx/html

# Check the contents of the copied build directory
RUN ls -la /usr/share/nginx/html

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port the app runs on
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
