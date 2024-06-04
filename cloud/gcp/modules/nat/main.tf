module "nat" {
  for_each = {
    for idx, object in var.inputs :
    idx => object
  }
  source                             = "git@github.com:zerak24/terraform_modules.git//gcp/nat"
  project_id                         = var.project.project_id
  region                             = var.project.region
  name                               = format("%v-%v", var.project.env, each.value.name)
  create_router                      = each.value.create_router
  router                             = format("%v-%v-router", var.project.env, each.value.name)
  network                            = var.project.network_name
  subnetworks                        = each.value.subnets
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
}