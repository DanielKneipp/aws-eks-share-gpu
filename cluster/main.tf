terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63"
    }
  }

  required_version = "1.0.10"
}

provider "aws" {
  region = "us-east-1"
}

locals {
  cluster_name = "tf-eks"
  ami_id       = data.aws_ami.gpu.image_id

  admin_ips = [
    "${chomp(data.http.myip.body)}/32",
  ]
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ami" "gpu" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-gpu-ami-*"]
  }
}
