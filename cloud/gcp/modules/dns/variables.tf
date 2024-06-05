variable "project" {
  type = object({
    project_id   = string
    region       = string
    network_name = string
  })
}
variable "inputs" {
  type = object({
    name   = string
    domain = string
    recordsets = list(object({
      name    = string
      type    = string
      ttl     = number
      records = list(string)
    }))
  })
}