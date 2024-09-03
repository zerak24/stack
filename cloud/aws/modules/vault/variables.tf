variable "project" {
  type = object({
    env        = string
    company = string
  })
}
variable "vault" {
  type = object({
    name = string
  })
}