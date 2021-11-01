terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.6.1"
    }
  }

  required_version = "1.0.10"
}

provider "aws" {
  region = "us-east-1"
}

locals {
  cluster_name = "gpu"
}

data "aws_eks_cluster" "eks" {
  name = local.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
    command     = "aws"
  }
}
