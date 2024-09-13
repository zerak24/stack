resource "google_compute_address" "ip_address" {
  project      = var.project.project_id
  region       = var.project.region
  name         = "${var.inputs.template.name_prefix}-external-ip"
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}

module "template" {
  source               = "git@github.com:zerak24/terraform_modules.git//gcp/ce-template"
  project_id           = var.project.project_id
  region               = var.project.region
  network              = "https://www.googleapis.com/compute/v1/projects/${var.project.project_id}/global/networks/${var.project.env}"
  subnetwork           = "https://www.googleapis.com/compute/v1/projects/${var.project.project_id}/regions/${var.project.region}/subnetworks/${var.project.env}-${var.inputs.template.subnetwork_name}"
  disk_size_gb         = var.inputs.template.disk_size_gb
  disk_type            = var.inputs.template.disk_type
  machine_type         = var.inputs.template.machine_type
  source_image         = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"
  name_prefix          = var.inputs.template.name_prefix
  service_account = {
    email  = "default"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  tags = var.inputs.template.tags
}

module "compute" {
  source              = "git@github.com:zerak24/terraform_modules.git//gcp/ce"
  subnetwork_project  = var.project.project_id
  region              = var.project.region
  network             = "https://www.googleapis.com/compute/v1/projects/${var.project.project_id}/global/networks/${var.project.env}"
  subnetwork          = "https://www.googleapis.com/compute/v1/projects/${var.project.project_id}/regions/${var.project.region}/subnetworks/${var.project.env}-${var.inputs.template.subnetwork_name}"
  hostname            = "${var.inputs.template.name_prefix}-compute-engine"
  add_hostname_suffix = false
  instance_template   = module.template.self_link_unique
  num_instances       = "1"
  access_config = [{
    nat_ip       = "${google_compute_address.ip_address.address}"
    network_tier = "STANDARD"
  }]
}
