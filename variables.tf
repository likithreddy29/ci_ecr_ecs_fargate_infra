variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS Region where resources will be created"
}

variable "repository_name" {
  type        = string
  default     = "zomato"
  description = "The name of the ECR repository"
}

variable "environment" {
  type        = string
  default     = "testing"
  description = "Deployment environment tag"
}


## Adding ECS fargate and networking resources

variable "aws_region" {
  description = "AWS region for provisioning resources"
  type        = string
  default     = "us-east-1"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "zomato"
}

variable "app_port" {
  description = "Port exposed by the Docker container"
  type        = number
  default     = 3000
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units (256 = 0.25 vCPU)"
  type        = string
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory (in MiB)"
  type        = string
  default     = "512"
}
