variable "project" {
  type = object({
    project_id   = string
    region       = string
    network_name = string
  })
}
variable "inputs" {
  type = object({
    template = object({
      subnetwork_name = string
      disk_size_gb    = string
      disk_type       = string
      machine_type    = string
      name_prefix     = string
      tags = list(string)
    })
  })
}