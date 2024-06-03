resource "google_compute_address" "gitlab_ip_address" {
  project = var.project.project_id
  region = var.project.region
  name = "gitlab-external-ip"
  address_type = "EXTERNAL"
}

module "template" {
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/compute-template"
  project_id = var.project.project_id
  region     = var.project.region
  network = "https://www.googleapis.com/compute/v1/projects/${var.project.project_id}/global/networks/${var.project.network_name}"
  subnetwork = "https://www.googleapis.com/compute/v1/projects/${var.project.project_id}/regions/${var.project.region}/subnetworks/${var.inputs.subnetwork_name}"
  disk_size_gb = var.inputs.disk_size_gb
  disk_type = var.inputs.disk_type
  machine_type = var.inputs.machine_type
  source_image = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"
  name_prefix = var.inputs.name_prefix
  service_account = {
    email = ""
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

module "compute" {
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/compute"
  subnetwork_project = var.project.project_id
  region     = var.project.region
  hostname = "gitlab-compute-engine"
  static_ips = ["${google_compute_address.gitlab_ip_address.address}"]
  add_hostname_suffix = false
  instance_template = module.template.self_link_unique
  num_instances = "1"
}