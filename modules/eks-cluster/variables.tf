variable "vpc_id" {
  description = "vpc id to be used for eks cluster"
  type = string
}

variable "private_subnets" {
  description = "list of subnet ids"
  type = list(string)
}

variable "cluster_name" {
    description = "cluster name"
    type = string
    default = "default-name"
}

variable "node_groups_instance_types" {
  description = "instance types for node groups"
  type = list(string)
  default = ["m5.xlarge", "m5.large", "t3.medium"]
}

variable "rolearn" {
  description = "role arn to be used for eks cluster"
  type = string
}

variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type = number
  default = 2
}