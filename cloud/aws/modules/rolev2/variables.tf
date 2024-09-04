variable "project" {
  type = object({
    env        = string
    company = string
  })
}
variable "role" {
  type = object({
    name = string
    trust_policy_conditions = optional(list(map(string)), [])
    trust_policy_statements = optional(list(map(string)), [])
    attach_custom_policy = optional(bool, false)
    policy_statements = optional(list(map(string)), [])
    additional_policy_arns = optional(map(string), {})

    attach_cluster_autoscaler_policy = optional(bool, false)
    cluster_autoscaler_cluster_names = optional(list, [])
    attach_aws_lb_controller_policy = optional(bool, false)
    attach_velero_policy       = optional(bool, false)
    velero_s3_bucket_arns      = optional(list, [])
    velero_s3_bucket_path_arns = optional(list, [])
  })
  default = null
}