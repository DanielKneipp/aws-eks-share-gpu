data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    command     = "aws"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.22.0"

  cluster_version = "1.21"
  cluster_name    = local.cluster_name
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets

  write_kubeconfig = false

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.cluster_secrets.arn
    resources        = ["secrets"]
  }]

  cluster_endpoint_private_access                = true
  cluster_create_endpoint_private_access_sg_rule = true
  cluster_endpoint_private_access_cidrs          = module.vpc.private_subnets_cidr_blocks


  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = local.admin_ips

  node_groups = {
    gpu-ng = {
      desired_capacity = 1
      min_capacity     = 1
      max_capacity     = 1

      instance_types = ["g4dn.xlarge"]
      capacity_type  = "ON_DEMAND"
      ami_id         = local.ami_id

      disk_size              = 50
      disk_encrypted         = true
      create_launch_template = true
      disk_kms_key_id        = aws_kms_key.gpu_volume.arn

      kubelet_extra_args = "--node-labels=k8s.amazonaws.com/accelerator=vgpu"

      update_config = {
        max_unavailable_percentage = 100 # For testing
      }
    }
  }
}
