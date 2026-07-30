terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 Remote Backend Configuration
  backend "s3" {
    bucket = "likithreddy29-project1-tfstate"
    key    = "ecr/terraform.tfstate" # Stores state under the 'ecr/' path
    region = "us-east-1"             # Update if your bucket lives in a different region
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

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
