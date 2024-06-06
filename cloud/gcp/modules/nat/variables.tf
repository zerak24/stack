variable "project" {
  type = object({
    project_id   = string
    region       = string
    env = string
  })
}
variable "inputs" {
  type = list(object({
    name = string
    subnets = list(object({
      name                     = string
      source_ip_ranges_to_nat  = list(string)
      secondary_ip_range_names = optional(list(string))
    }))
    create_router = bool
  }))
}