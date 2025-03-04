locals {
  name_ = "${var.vpc_owner}-${var.vpc_use}"

  common_tags = {
    owners    = var.vpc_owner
    use       = var.vpc_use
    terraform = "True"
  }
}