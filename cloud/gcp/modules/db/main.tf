module "postgres" {
  for_each = {
    for idx, object in var.inputs.postgresql :
    idx => object
  }
  source     = "git@github.com:zerak24/terraform_modules.git//gcp/db/modules/postgresql"
  project_id = var.project.project_id
  region     = var.project.region
  name = each.value.name
  database_version = each.value.database_version
  tier = each.value.tier
  zone = format("%v-%v", var.project.region ,each.value.zone)
  availability_type = each.value.availability_type
  deletion_protection_enabled = each.value.deletion_protection_enabled
  database_flags = each.value.database_flags
  read_replica_name_suffix = each.value.read_replica_name_suffix
  read_replicas = each.value.read_replicas
  disk_size = each.value.disk_size
  disk_type = each.value.disk_type
  disk_autoresize = each.value.disk_autoresize
  disk_autoresize_limit = each.value.disk_autoresize_limit
  ip_configuration = {
    ipv4_enabled       = false
    require_ssl        = false
    # ssl_mode = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    private_network    = format("https://www.googleapis.com/compute/v1/projects/%v/global/networks/%v", var.project.project_id, "develop-main")
  #   allocated_ip_range = "default-sql"
  }
  backup_configuration = {
    enabled                        = true
    start_time                     = "3:00"
    point_in_time_recovery_enabled = false
  }
}