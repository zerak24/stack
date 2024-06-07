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
    iam_members = list(object({
      role = string
      member = string
    }))
    lifecycle_rules = list(object())
    cors = list(any)
    storage_class = string
    versioning = bool
  }))
}