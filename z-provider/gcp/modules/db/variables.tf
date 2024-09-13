variable "project" {
  type = object({
    project_id = string
    region     = string
    env        = string
  })
}
variable "inputs" {
  type = object({
    postgresql = list(object({
      name                        = string
      database_version            = string
      tier                        = string
      zone                        = string
      availability_type           = string
      deletion_protection_enabled = bool
      database_flags              = list(any)
      read_replica_name_suffix    = string
      read_replicas               = list(any)
      disk_size                   = number
      disk_type                   = string
      disk_autoresize             = bool
      disk_autoresize_limit       = number
    }))
  })
}