###---compute/variables.tf---

variable "public_sg" {}
variable "private_sg" {}
variable "private_subnet" {}
variable "public_subnet" {}
variable "key_name" {}
variable "elb" {}
variable "cicd_alb_tg" {}

variable "bastion_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "webserver_instance_type" {
  type    = string
  default = "t2.micro"
}