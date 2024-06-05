module "docker" {
  source  = "git@github.com:zerak24/terraform_modules.git//gcp/docker"

  container = {
    image = var.inputs.docker.image

    env = var.inputs.docker.env

    volumeMounts = var.inputs.docker.volumeMounts
  }

  volumes = var.inputs.docker.volumes

  restart_policy = "Always"
}

resource "google_compute_disk" "pd" {
  project = var.project.project_id
  name    = "${var.inputs.instance_name}-data-disk"
  type    = var.inputs.disk_type
  zone    = format("%v-%v", var.project.region, var.inputs.zone)
  size    = var.inputs.disk_size
}

resource "google_compute_instance" "vm" {
  project      = var.project.project_id
  name         = var.inputs.instance_name
  machine_type = var.inputs.instance_type
  allow_stopping_for_update = true
  zone         = format("%v-%v", var.project.region, var.inputs.zone)

  boot_disk {
    initialize_params {
      image = module.docker.source_image
    }
  }

  attached_disk {
    source      = google_compute_disk.pd.self_link
    device_name = var.inputs.disk_name
    mode        = "READ_WRITE"
  }

  network_interface {
    subnetwork_project = var.project.project_id
    subnetwork         = format("%v-%v" ,var.project.network_name, var.inputs.subnetwork)
    access_config {}
  }

  metadata = merge(var.inputs.additional_metadata, { "gce-container-declaration" = module.docker.metadata_value })

  labels = {
    container-vm = module.docker.vm_container_label
  }

  tags = var.inputs.tags

  service_account {
    email = "default"
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
