# Vault is the source of truth for the database password.
# Terraform reads it from Vault, uses it for RDS, and copies it into
# SSM Parameter Store as a SecureString so ECS can inject it at runtime.

data "vault_kv_secret_v2" "db" {
  mount = var.vault_kv_mount
  name  = var.vault_db_secret_path
}

locals {
  db_password = data.vault_kv_secret_v2.db.data["password"]
  ssm_prefix  = "/${var.project}"
}

resource "aws_ssm_parameter" "db_password" {
  name  = "${local.ssm_prefix}/db/password"
  type  = "SecureString"
  value = local.db_password
}

resource "aws_ssm_parameter" "db_host" {
  name  = "${local.ssm_prefix}/db/host"
  type  = "String"
  value = aws_db_instance.main.address
}

resource "aws_ssm_parameter" "db_name" {
  name  = "${local.ssm_prefix}/db/name"
  type  = "String"
  value = var.db_name
}

resource "aws_ssm_parameter" "db_user" {
  name  = "${local.ssm_prefix}/db/user"
  type  = "String"
  value = var.db_username
}
