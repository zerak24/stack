variable "project" {
  type = object({
    project_id   = string
    region       = string
    network_name = string
  })
}