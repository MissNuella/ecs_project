# Used for local development with docker compose.
# In CI the same image is baked by Packer (see packer/backend.pkr.hcl).
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY server.js ./
USER node
EXPOSE 3000
CMD ["node", "server.js"]
