variable "project" {
  type = object({
    project_id = string
    region     = string
  })
}
variable "inputs" {
  type = list(object({
  }))
}