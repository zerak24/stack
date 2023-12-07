module "vpc" {
    source  = "../../modules/vpc"

    project_id   = var.project.project_id
    network_name = var.inputs.network_name
    routing_mode = "GLOBAL"

    subnets = [for sub in var.inputs.subnets:
        {
            subnet_name = sub.subnet_name
            subnet_ip = sub.subnet_ip
            subnet_region = var.project.region
            subnet_private_access = false
        }]

    secondary_ranges = var.inputs.secondary_ranges

    routes = []

    ingress_rules = var.inputs.ingress_rules

    egress_rules = var.inputs.egress_rules
}
