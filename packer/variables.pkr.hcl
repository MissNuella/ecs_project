variable "api_ecr_repository" {
  type        = string
  description = "ECR repository URL for the API image (terraform output ecr_api_repository)."
}

variable "web_ecr_repository" {
  type        = string
  description = "ECR repository URL for the web image (terraform output ecr_web_repository)."
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Tag for the baked images. CI uses the git commit SHA."
}
