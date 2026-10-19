# Used for local development with docker compose.
# In CI the same image is baked by Packer (see packer/frontend.pkr.hcl).
FROM nginx:1.27-alpine
ENV API_HOST=api
COPY nginx.conf /etc/nginx/templates/default.conf.template
COPY index.html app.js /usr/share/nginx/html/
EXPOSE 80
