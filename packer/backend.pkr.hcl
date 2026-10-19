# Bakes the API image with Packer's Docker builder and pushes it to ECR.
# Run from the repo root:
#   packer init packer/
#   packer build -var "api_ecr_repository=<api repo url>" -var "web_ecr_repository=<web repo url>" -var "image_tag=<tag>" packer/

packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = ">= 1.0.10"
    }
  }
}

source "docker" "api" {
  image  = "node:20-alpine"
  commit = true
  changes = [
    "WORKDIR /app",
    "USER node",
    "EXPOSE 3000",
    "ENV NODE_ENV=production",
    "ENTRYPOINT [\"docker-entrypoint.sh\"]",
    "CMD [\"node\", \"server.js\"]",
  ]
}

build {
  name    = "api"
  sources = ["source.docker.api"]

  provisioner "shell" {
    inline = ["mkdir -p /app"]
  }

  provisioner "file" {
    sources     = ["${path.root}/../app/backend/package.json", "${path.root}/../app/backend/server.js"]
    destination = "/app/"
  }

  provisioner "shell" {
    inline = [
      "cd /app && npm install --omit=dev && npm cache clean --force",
      "chown -R node:node /app",
    ]
  }

  post-processors {
    post-processor "docker-tag" {
      repository = var.api_ecr_repository
      tags       = [var.image_tag, "latest"]
    }
    post-processor "docker-push" {}
  }
}
