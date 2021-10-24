data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.22.0"

  cluster_version = "1.21.2"
  cluster_name    = "gpu"
  vpc_id          = module.vpc.vpc_id
  subnets         = tolist(module.vpc.private_subnets)

  worker_groups_launch_template = [
    {
      instance_type = "g4dn.xlarge"
      ami_id        = "???"

      asg_max_size         = 2
      asg_desired_capacity = 2
      asg_min_size         = 2
      suspended_processes  = ["AZRebalance"]

      root_encrypted   = true
      root_volume_size = 50

      kubelet_extra_args = "--node-labels=node.kubernetes.io/lifecycle=spot,k8s.amazonaws.com/accelerator=vgpu"
    }
  ]
}
