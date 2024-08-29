module "vpc" {
  count = var.vpc == null ? 0 : 1
  source = "git@github.com:zerak24/terraform_modules.git//aws/vpc"

  name = format("%s-%s-vpc", var.project.company, var.project.env)
  cidr = var.vpc.cidr

  azs             = var.vpc.zones
  private_subnets = var.vpc.private_subnets
  private_subnet_tags = var.vpc.private_subnet_tags
  public_subnets  = var.vpc.public_subnets
  public_subnet_tags = var.vpc.public_subnet_tags
  database_subnets = var.vpc.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = var.vpc.single_nat_gateway
  one_nat_gateway_per_az = true

  tags = {
    Terraform = "true"
    Environment = var.project.env
  }
}

module "sg" {
  for_each = var.sg
  source = "git@github.com:zerak24/terraform_modules.git//aws/sg"

  name        = format("%s-%s-%s-sg", var.project.company, var.project.env, each.key)
  description = each.value.description
  vpc_id      = module.vpc[0].vpc_id

  ingress_with_cidr_blocks = each.value.ingress_with_cidr_blocks
}

module "rds" {
  for_each = var.rds
  source = "git@github.com:zerak24/terraform_modules.git//aws/rds"
  
  identifier        = format("%s-%s-%s", var.project.company, var.project.env, each.key)
  # subnet_ids             = module.vpc[0].database_subnets
  vpc_security_group_ids = [for sg in module.sg : sg.security_group_id]
  db_subnet_group_name = module.vpc[0].database_subnet_group
  username = "root"

  engine            = each.value.engine
  engine_version    = each.value.engine_version
  instance_class    = each.value.instance_class
  family = format("%s%s", each.value.engine, each.value.engine_version)
  storage_type = "gp3"
  allocated_storage = 30
  multi_az = true
  
  deletion_protection = true
  iam_database_authentication_enabled = true
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
}

module "eks" {
  count = var.eks == null ? 0 : 1
  source = "git@github.com:zerak24/terraform_modules.git//aws/eks"

  cluster_name    = format("%s-%s-eks", var.project.company, var.project.env)
  cluster_version = var.eks.version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_enabled_log_types = var.eks.cluster_enabled_log_types == null ? ["audit", "api", "authenticator"] : var.eks.cluster_enabled_log_types

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = module.vpc[0].vpc_id
  subnet_ids               = module.vpc[0].private_subnets
  cluster_service_ipv4_cidr = var.eks.cluster_service_ipv4_cidr

  kms_key_administrators = var.eks.kms_key_administrators

  node_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description               = "Nodes on ephemeral ports"
      protocol                  = "-1"
      from_port                 = 0
      to_port                   = 0
      type                      = "ingress"
      source_node_security_group= true
    }
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_groups = {for k,v in var.eks.eks_managed_node_groups: k => merge(v, {subnet_ids = [module.vpc[0].private_subnets[index(var.vpc.zones, v.zone)]]})}

  access_entries = {for k,v in var.eks.access_entries: k => merge(v, {policy_associations = {
    admin = {
      policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      access_scope = {
        type = "cluster"
      }
    }
  }})}

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

