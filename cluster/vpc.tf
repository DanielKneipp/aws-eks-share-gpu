module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10"

  name = "tf-vpc"
  cidr = "10.0.0.0/16"

  # Use this many AZs to test Spot instances availability in
  # the future
  azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1f",
  ]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
  ]

  public_subnets = ["10.0.101.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  # Requirement for private eks endpoint
  # (https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html)
  enable_dns_hostnames             = true
  enable_dns_support               = true
  enable_dhcp_options              = true
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  # TODO: test if these are really required
  # Source: https://github.com/hashicorp/learn-terraform-provision-eks-cluster/blob/master/vpc.tf#L34-L46
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
