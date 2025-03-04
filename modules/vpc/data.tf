data "aws_availability_zones" "available_azs" {
    filter {
      name = "opt-in-status"
      values = ["opt-in-not-required"]
    }
}