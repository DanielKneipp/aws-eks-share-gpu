module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.10"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-east-1a", "eu-west-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = true
}
