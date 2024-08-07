# Stage 1: Build the SvelteKit application
FROM node:20 AS build

# Set the working directory
WORKDIR /usr/src/app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install dependencies with retry and logging
RUN set -e; \
    for i in $(seq 1 5); do \
        npm install && break || (echo "npm install failed on attempt $i"; \
        if [ $i -eq 5 ]; then exit 1; fi; \
        sleep 10); \
    done

# Add node_modules/.bin to PATH
ENV PATH=/usr/src/app/node_modules/.bin:$PATH

# Verify Vite installation with retry
RUN set -e; \
    for i in $(seq 1 5); do \
        npx vite --version && break || (echo "npx vite failed on attempt $i"; \
        if [ $ i -eq 5 ]; then exit 1; fi; \
        sleep 10); \
    done

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
RUN ls -la /usr/src/app/build

# Stage 2: Serve the SvelteKit application with Nginx
FROM nginx:alpine

# Copy the built app from the previous stage
COPY --from=build /usr/src/app/build /usr/share/nginx/html

# Check the contents of the copied build directory
RUN ls -la /usr/share/nginx/html

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port the app runs on
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]

