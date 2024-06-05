variable "project" {
  type = object({
    project_id   = string
    region       = string
    network_name = string
  })
}
variable "inputs" {
  type = object({
    instance_name = string
    instance_type = string
    zone = string
    subnetwork = string
    disk_size = number
    disk_type = string
    disk_name = string
    additional_metadata = any
    tags = list(string)
    docker = object({
      image = string
      env = list(object({
        name = string
        value = string
      }))
      volumeMounts = list(object({
        mountPath = string
        name      = string
        readOnly  = bool
      }))
      volumes = list(any)
    })
  })
  
}