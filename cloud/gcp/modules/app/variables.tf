variable "project" {
  type = object({
    project_id   = string
    region       = string
    env = string
  })
}
variable "inputs" {
  type = object({
    sa = object({
    })
    pubsub = object({
    })
  })
}
