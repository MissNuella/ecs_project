# Bakes the web (Nginx) image with Packer's Docker builder and pushes it to ECR.

source "docker" "web" {
  image  = "nginx:1.27-alpine"
  commit = true
  changes = [
    "EXPOSE 80",
    "ENV API_HOST=api",
    "ENTRYPOINT [\"/docker-entrypoint.sh\"]",
    "CMD [\"nginx\", \"-g\", \"daemon off;\"]",
  ]
}

build {
  name    = "web"
  sources = ["source.docker.web"]

  provisioner "shell" {
    inline = ["mkdir -p /etc/nginx/templates"]
  }

  provisioner "file" {
    sources     = ["${path.root}/../app/frontend/index.html", "${path.root}/../app/frontend/app.js"]
    destination = "/usr/share/nginx/html/"
  }

  provisioner "file" {
    source      = "${path.root}/../app/frontend/nginx.conf"
    destination = "/etc/nginx/templates/default.conf.template"
  }

  post-processors {
    post-processor "docker-tag" {
      repository = var.web_ecr_repository
      tags       = [var.image_tag, "latest"]
    }
    post-processor "docker-push" {}
  }
}
