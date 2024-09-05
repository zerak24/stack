variable "project" {
  type = object({
    project_id = string
    region     = string
    env        = string
  })
}
variable "inputs" {
  type = list(object({
    name          = list(string)
    project_roles = list(string)
    description   = string
  }))
}