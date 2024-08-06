# Stage 1: Build the SvelteKit application
FROM node:20 AS build

# Set the working directory
WORKDIR /usr/src/app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . ./

# Build the app for production
RUN npm run build

# Stage 2: Serve the SvelteKit application with Nginx
FROM nginx:alpine

# Copy the built app from the previous stage
COPY --from=build /usr/src/app/build /usr/share/nginx/html

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port the app runs on
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]

