variable "project" {
  type = object({
    project_id   = string
    region       = string
    network_name = string
    env          = string
  })
}
variable "inputs" {
  type = object({
    sa = object({
      names  = list(string)
      prefix = string
      roles  = list(string)
    })
    pubsub = object({
    })
  })
}
