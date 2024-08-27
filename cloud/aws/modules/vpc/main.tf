module "vpc" {
  count = var.inputs == null ? 0 : 1
  source = "git@github.com:zerak24/terraform_modules.git//aws/vpc"

  name = var.project.env
  cidr = var.inputs.cidr

  azs             = var.inputs.zones
  private_subnets = var.inputs.private_subnets
  private_subnet_tags = var.inputs.private_subnet_tags
  public_subnets  = var.inputs.public_subnets
  public_subnet_tags = var.inputs.public_subnet_tags
  database_subnets = var.inputs.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = var.inputs.single_nat_gateway
  one_nat_gateway_per_az = true

  tags = {
    Terraform = "true"
    Environment = var.project.env
  }
}