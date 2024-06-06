module "vpc" {
  source = "git@github.com:zerak24/terraform_modules.git//gcp/vpc"

  project_id   = var.project.project_id
  network_name = var.project.env
  routing_mode = "GLOBAL"

  subnets = [for sub in var.inputs.subnets :
    {
      subnet_name           = format("%v-%v", var.project.env, sub.subnet_name)
      subnet_ip             = sub.subnet_ip
      subnet_region         = var.project.region
      subnet_private_access = false
  }]

  secondary_ranges = merge([for key, value in var. inputs.secondary_ranges :
    {
      format(format("%v-%v", var.project.env, key)) = value
    }
  ]...)

  routes = var.inputs.routes

  ingress_rules = var.inputs.ingress_rules

  egress_rules = var.inputs.egress_rules
}
