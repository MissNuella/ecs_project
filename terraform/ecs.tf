# ECS Fargate cluster with two services: web (Nginx) and api (Node.js).
# Tasks run in private subnets and are reached only through the ALB.

resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "app" {
  for_each          = toset(["web", "api"])
  name              = "/ecs/${var.project}-${each.key}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${var.project}-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name         = "web"
    image        = "${aws_ecr_repository.app["web"].repository_url}:${var.image_tag}"
    essential    = true
    portMappings = [{ containerPort = 80, protocol = "tcp" }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.app["web"].name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "web"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name         = "api"
    image        = "${aws_ecr_repository.app["api"].repository_url}:${var.image_tag}"
    essential    = true
    portMappings = [{ containerPort = 3000, protocol = "tcp" }]
    environment = [
      { name = "PORT", value = "3000" },
      { name = "DB_SSL", value = "true" },
    ]
    # Pulled from SSM Parameter Store when the task starts.
    secrets = [
      { name = "DB_HOST", valueFrom = aws_ssm_parameter.db_host.arn },
      { name = "DB_NAME", valueFrom = aws_ssm_parameter.db_name.arn },
      { name = "DB_USER", valueFrom = aws_ssm_parameter.db_user.arn },
      { name = "DB_PASSWORD", valueFrom = aws_ssm_parameter.db_password.arn },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.app["api"].name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "api"
      }
    }
  }])
}

locals {
  services = {
    web = { task = aws_ecs_task_definition.web.arn, tg = aws_lb_target_group.web.arn, port = 80 }
    api = { task = aws_ecs_task_definition.api.arn, tg = aws_lb_target_group.api.arn, port = 3000 }
  }
}

resource "aws_ecs_service" "app" {
  for_each = local.services

  name            = "${var.project}-${each.key}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = each.value.task
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = each.value.tg
    container_name   = each.key
    container_port   = each.value.port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [aws_lb_listener.http, aws_lb_listener_rule.api]

  # GitHub Actions registers new task definitions on each deploy,
  # so Terraform should not roll them back.
  lifecycle {
    ignore_changes = [task_definition]
  }
}
