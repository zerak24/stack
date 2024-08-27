module "vpc" {
  source = "git@github.com:zerak24/terraform_modules.git//aws/vpc"

  name = var.project.env
  cidr = var.inputs.vpc.cidr

  azs             = var.inputs.vpc.zones
  private_subnets = var.inputs.vpc.private_subnets
  private_subnet_tags = var.inputs.vpc.private_subnet_tags
  public_subnets  = var.inputs.vpc.public_subnets
  public_subnet_tags = var.inputs.vpc.public_subnet_tags
  database_subnets = var.inputs.vpc.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = var.inputs.vpc.single_nat_gateway
  one_nat_gateway_per_az = true

  tags = {
    Terraform = "true"
    Environment = var.project.env
  }
}

module "eks" {
  source = "git@github.com:zerak24/terraform_modules.git//aws/eks"

  cluster_name    = var.project.env
  cluster_version = var.inputs.version

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = "vpc-1234556abcdef"
  subnet_ids               = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    example = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::123456789012:role/something"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

