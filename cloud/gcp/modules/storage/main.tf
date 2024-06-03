module "storage" {
  for_each = { 
    for idx, object in var.inputs:
      idx => object
    }
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/storage"
  project_id = var.project.project_id
  region     = var.project.region
  create_router = each.value.create_router
  router     = each.value.router_name
  network    = each.value.network_name
  subnetworks = each.value.subnets
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
}