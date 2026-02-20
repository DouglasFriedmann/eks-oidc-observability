module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  cluster_endpoint_public_access = true

  # Minimal managed node group
  eks_managed_node_groups = {
    default = {
      name = "ng1"

      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1

      capacity_type = "ON_DEMAND"

      tags = local.tags
    }
  }

  tags = local.tags
}

