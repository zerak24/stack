variable "project" {
  type = object({
    env        = string
    company = string
  })
}
variable "eks-sa" {
  type = object({
    name = string
    cluster_service_accounts = map(list(string))
    role_policy_arns = optional(map(string), {})
    iam_policy = optional(object({
      name = string
      policy = string
    }))
  })
  default = null
}