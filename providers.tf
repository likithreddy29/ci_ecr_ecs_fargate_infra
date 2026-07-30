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
    key    = "ecr/terraform.tfstate"
    region = "us-east-1"
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}
