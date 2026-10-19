variable "project" {
  description = "Name prefix for every resource."
  type        = string
  default     = "ecs-notes"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "github_repo" {
  description = "GitHub repo allowed to deploy, as owner/name (e.g. ellz/ecs-notes)."
  type        = string
}

variable "vault_db_secret_path" {
  description = "Path of the KV v2 secret in Vault that holds the DB password."
  type        = string
  default     = "ecs-notes/db"
}

variable "vault_kv_mount" {
  description = "Vault KV v2 mount."
  type        = string
  default     = "secret"
}

variable "db_name" {
  type    = string
  default = "notes"
}

variable "db_username" {
  type    = string
  default = "notes"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "image_tag" {
  description = "Image tag used for the first deploy. GitHub Actions rolls out new tags after that."
  type        = string
  default     = "latest"
}

variable "desired_count" {
  description = "Tasks per ECS service."
  type        = number
  default     = 1
}
