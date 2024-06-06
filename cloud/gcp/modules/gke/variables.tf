variable "project" {
  type = object({
    project_id   = string
    region       = string
    env = string
  })
}
variable "inputs" {
  type = object({
    zones                = list(string)
    subnet               = string
    pod_cidr             = string
    svc_cidr             = string
    service_account_name = string
    node_pools = list(object({
      pool_name    = string
      machine_type = string
      min_nodes    = number
      max_nodes    = number
      spot_plan    = bool
    }))
  })
}