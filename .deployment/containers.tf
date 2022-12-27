########################
#### ECS cluster #######
########################

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster-${var.environment}"
}

output "aws_ecs_cluster-main-name" {
  value = aws_ecs_cluster.main.name
}

########################
#### ECR ressource #####
########################

resource "aws_ecr_repository" "lotus" {
  name                 = "${var.project_name}-lotus-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "aws_ecr_repository-lotus-name" {
  value = aws_ecr_repository.lotus.name
}

########################
#### Log groups ########
########################

resource "aws_cloudwatch_log_group" "lotus" {
  name = "/ecs/${var.project_name}-lotus-${var.environment}"
}

########################
#### ECS services ######
########################

resource "aws_ecs_service" "lotus" {
  name            = "${var.project_name}-lotus-${var.environment}"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.lotus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 5

  load_balancer {
    target_group_arn = aws_lb_target_group.lotus.arn
    container_name   = "${var.project_name}-lotus-${var.environment}"
    container_port   = 3000
  }

  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0  

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    assign_public_ip = true
    security_groups  = [ aws_security_group.ecs-lotus.id ]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  depends_on = [
    aws_lb_listener.lotus-https
  ]
}

output "aws_ecs_service-lotus-name" {
  value = "${var.project_name}-lotus-${var.environment}"
}

#####################################
#### ECS roles and policies #########
#####################################

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# lotus task
resource "aws_iam_role" "ecs_lotus_tasks_execution_role" {
  name               = "${var.project_name}-lotus-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_lotus_tasks_default" {
  role       = aws_iam_role.ecs_lotus_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

########################
#### ECS tasks #########
########################

resource "aws_ecs_task_definition" "lotus" {
  family                   = "${var.project_name}-lotus-${var.environment}"
  requires_compatibilities = [ "FARGATE" ]
  network_mode             = "awsvpc"
  cpu                      = var.task_definition_configs.lotus.cpu
  memory                   = var.task_definition_configs.lotus.memory
  execution_role_arn       = aws_iam_role.ecs_lotus_tasks_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_lotus_tasks_execution_role.arn
  container_definitions = jsonencode([
    {
      name              = "${var.project_name}-lotus-${var.environment}"
      image             = "rebelthor/sleep"
      cpu               = var.task_definition_configs.lotus.cpu
      memory            = var.task_definition_configs.lotus.memory
      memoryReservation = var.task_definition_configs.lotus.soft_memory_limit
      essential         = true
      portMappings      = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]

      mountPoints = [
        {
          readOnly        = null,
          containerPath   = "/root/.lotus",
          sourceVolume    = "lotus-storage"
        }
      ]

      environment = []

      logConfiguration  = {
        logDriver       = "awslogs"
        secretOptions   = null
        options         = {
          awslogs-group         = aws_cloudwatch_log_group.lotus.name
          awslogs-region        = data.aws_region.main.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  volume {
    name = "lotus-storage"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.lotus.id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.lotus.id
        iam             = "ENABLED"
      }
    }
  }

  runtime_platform {
    operating_system_family = "LINUX"
  }
}

output "aws_ecs_task_definition-lotus-name" {
  value = aws_ecs_task_definition.lotus.family
}