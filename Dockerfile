# Stage 1: Build the SvelteKit application
FROM node:20 as build

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Stage 2: Serve the SvelteKit application with Nginx
FROM nginx:alpine

COPY --from=build /usr/src/app/.svelte-kit/output /usr/share/nginx/html

# Expose the port the app runs on
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]

