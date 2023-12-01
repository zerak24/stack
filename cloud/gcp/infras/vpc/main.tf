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
            subnet_private_access = true
        }]

    secondary_ranges = var.inputs.secondary_ranges

    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        }
    ]

    ingress_rules = var.inputs.ingress_rules

    egress_rules = var.inputs.egress_rules
}
