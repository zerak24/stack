variable "project" {
  type = object({
    env        = string
    key_directory = optional(string)
    company = string
  })
}
variable "vault" {
  type = object({
    name = string
  })
}