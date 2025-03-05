variable "vpc_id" {
  description = "vpc id to be used for eks cluster"
  type = string
}

variable "private_subnets" {
  description = "list of subnet ids"
  type = list(string)
}