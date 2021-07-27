// gcp
variable "project" {
  default = "se-kabu"
}

variable "gcp_machine_type" {
  default = "e2-medium"
}
variable "gcp_region" {
  default = "asia-northeast1"
}
variable "image" {
  default = "ubuntu-1804-bionic-v20201014"
}

// aws
variable "ami" {
  default = "ami-02b658ac34935766f"
}
variable "aws_region" {
  default = "ap-northeast-1"
}

variable "aws_machine_type" {
  default = "t2.micro"
}

variable "ubuntu_password" {
  default = "happyhacking"
}

// RDP Azure

variable "location" {
  default = "East US"
}

variable "admin_password" {
  default = "Password1234"
}

variable "admin_user" {
  default = "adminuser"
}