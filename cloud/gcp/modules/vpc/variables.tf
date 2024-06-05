variable "project" {
  type = object({
    project_id   = string
    region       = string
    network_name = string
  })
}
variable "inputs" {
  type = object({
    subnets = list(object({
      subnet_name = string
      subnet_ip   = string
    }))
    secondary_ranges = map(list(object({
      range_name    = string
      ip_cidr_range = string
    })))
    routes = list(any)
    egress_rules = list(object({
      name          = string
      source_ranges = list(string)
      allow = list(object({
        protocol = string
        ports    = optional(list(string))
      }))
    }))
    ingress_rules = list(object({
      name          = string
      source_ranges = list(string)
      target_tags   = optional(list(string))
      allow = list(object({
        protocol = string
        ports    = optional(list(string))
      }))
    }))
  })
}
