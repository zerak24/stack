variable "project" {
  type = object({
    project_id   = string
    region       = string
    network_name = string
    env          = string
  })
}
variable "inputs" {
  type = list(object({
    network_name = string
    subnets = list(object({
      name                     = string
      source_ip_ranges_to_nat  = list(string)
      secondary_ip_range_names = optional(list(string))
    }))
    router_name   = string
    create_router = bool
  }))
}