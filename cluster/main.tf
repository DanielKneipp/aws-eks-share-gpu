terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63"
    }
  }

  required_version = "~> 1.0.3"
}

provider "aws" {
  region = "us-east-1"
}
