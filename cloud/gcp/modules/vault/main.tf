module "vault" {
  source = "git@github.com:zerak24/terraform_modules.git//gcp/vault"

  project_id                = var.project.project_id
  region                    = var.project.region
  allow_ssh                 = false
  network                   = "https://www.googleapis.com/compute/v1/projects/${var.project.project_id}/global/networks/${var.project.network_name}"
  network_subnet_cidr_range = var.inputs.network_subnet_cidr_range
  ssh_allowed_cidrs         = var.inputs.ssh_allowed_cidrs
  vault_allowed_cidrs       = var.inputs.vault_allowed_cidrs
  vault_max_num_servers     = var.inputs.max_nodes
  vault_min_num_servers     = var.inputs.min_nodes
  vault_machine_type        = var.inputs.machine_type

  storage_bucket_force_destroy = true
}
