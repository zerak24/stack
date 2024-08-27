module "vpc" {
  count = var.vpc == null ? 0 : 1
  source = "git@github.com:zerak24/terraform_modules.git//aws/vpc"

  name = var.project.env
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