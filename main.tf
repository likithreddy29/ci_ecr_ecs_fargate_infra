# Amazon ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.repository_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Lifecycle Policy (Expires untagged images after 14 days)
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}


# ----------------------------------------------------
# 1. ECR REPOSITORY (Your existing resource)
# ----------------------------------------------------
resource "aws_ecr_repository" "zomato_ecr" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------------------------------
# 2. NETWORKING (Default VPC & Subnets)
# ----------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ----------------------------------------------------
# 3. SECURITY GROUP
# ----------------------------------------------------
resource "aws_security_group" "zomato_sg" {
  name        = "zomato-fargate-sg"
  description = "Allow inbound traffic on port 3000"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----------------------------------------------------
# 4. ECS CLUSTER
# ----------------------------------------------------
resource "aws_ecs_cluster" "zomato_cluster" {
  name = "zomato-cluster"
}

# ----------------------------------------------------
# 5. IAM TASK EXECUTION ROLE
# ----------------------------------------------------
resource "aws_iam_role" "ecs_execution_role" {
  name = "zomatoEcsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ----------------------------------------------------
# 6. ECS TASK DEFINITION
# ----------------------------------------------------
resource "aws_ecs_task_definition" "zomato_task" {
  family                   = "zomato-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "zomato-app"
      image     = "${aws_ecr_repository.zomato_ecr.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# ----------------------------------------------------
# 7. ECS SERVICE
# ----------------------------------------------------
resource "aws_ecs_service" "zomato_service" {
  name            = "zomato-service"
  cluster         = aws_ecs_cluster.zomato_cluster.id
  task_definition = aws_ecs_task_definition.zomato_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.zomato_sg.id]
    assign_public_ip = true
  }
}
