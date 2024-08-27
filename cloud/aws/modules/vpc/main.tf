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