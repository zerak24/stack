variable "project" {
  type = object({
    project_id   = string
    region       = string
    network_name = string
  })
}
variable "inputs" {
  type = list(object({
    name = list(string)
    project_roles = list(string)
    description = string
  }))
}