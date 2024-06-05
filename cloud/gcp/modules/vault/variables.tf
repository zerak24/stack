variable "project" {
  type = object({
    project_id   = string
    region       = string
    network_name = string
  })
}
variable "inputs" {
  type = object({
    network_subnet_cidr_range = string
    ssh_allowed_cidrs         = list(string)
    vault_allowed_cidrs       = list(string)
    machine_type              = string
    max_nodes                 = string
    min_nodes                 = string
  })
}
