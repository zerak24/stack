resource "google_compute_address" "gitlab_ip_address" {
  project = var.project.project_id
  region = var.project.region
  name = "gitlab-external-ip"
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}

module "template" {
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/ce-template"
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
    email = "default"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  tags = [
    "allow-ssh",
    "allow-http",
    "allow-https"
  ]
}

module "compute" {
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/ce"
  subnetwork_project = var.project.project_id
  region     = var.project.region
  network = "https://www.googleapis.com/compute/v1/projects/${var.project.project_id}/global/networks/${var.project.network_name}"
  subnetwork = "https://www.googleapis.com/compute/v1/projects/${var.project.project_id}/regions/${var.project.region}/subnetworks/${var.inputs.subnetwork_name}"
  hostname = "gitlab-compute-engine"
  add_hostname_suffix = false
  instance_template = module.template.self_link_unique
  num_instances = "1"
  access_config = [{
    nat_ip = "${google_compute_address.gitlab_ip_address.address}"
    network_tier = "STANDARD"
    }]
}
