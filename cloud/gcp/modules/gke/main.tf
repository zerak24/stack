data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "git@github.com:zerak24/terraform_modules.git//gcp/gke"
  project_id                 = var.project.project_id
  name                       = var.inputs.cluster_name
  region                     = var.project.region
  zones                      = var.inputs.zones
  network                    = var.project.network_name
  subnetwork                 = var.inputs.subnet
  ip_range_pods              = var.inputs.pod_cidr
  ip_range_services          = var.inputs.svc_cidr
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = false
  filestore_csi_driver       = false
  create_service_account     = false
  service_account_name       = var.inputs.service_account_name
  remove_default_node_pool   = true
  deletion_protection        = false
  release_channel            = "STABLE"

  node_pools = [ for idx, node_pool in var.inputs.node_pools:
    {
      name                      = node_pool.pool_name
      machine_type              = node_pool.machine_type
      node_locations            = var.inputs.zones[idx]
      min_count                 = node_pool.min_nodes
      max_count                 = node_pool.max_nodes
      local_ssd_count           = 0
      spot                      = node_pool.spot_plan
      disk_size_gb              = 50
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      logging_variant           = "DEFAULT"
      auto_repair               = true
      auto_upgrade              = true
      service_account_name      = "${node_pool.pool_name}-gke-service-account"
      preemptible               = false
      enable_integrity_monitoring = false
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}