variable "project" {
  type = object({
    project_id = string
    region = string
  })
}
variable "inputs" {
  type = object({
    cluster_name = string
    zones = list(string)
    network_name = string
    subnet = string
    pod_cidr = string
    svc_cidr = string
    service_account_name = string
    node_pools = list(object({
      pool_name = string
      machine_type = string
      min_nodes = number
      max_nodes = number
      spot_plan = bool
    }))
  })
}