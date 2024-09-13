variable "project" {
  type = object({
    project_id = string
    region     = string
    env        = string
  })
}
variable "inputs" {
  type = object({
    identity = object({
      name      = string
      namespace = string
      roles     = list(string)
    })
    pubsub = list(object({
      topic        = string
      topic_labels = object()
      storage_name = string
    }))
  })
}
