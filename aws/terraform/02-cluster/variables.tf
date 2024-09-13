variable "region" {
  description = "The region Terraform deploys your instance"
  default     = "eu-west-1"
}

variable "ssh_public_key" {
  default = "../../master.pub"
}

variable "ssh_private_key" {
  default = "../../master"
}
