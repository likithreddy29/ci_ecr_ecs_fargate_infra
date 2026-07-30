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
