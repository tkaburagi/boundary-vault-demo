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

variable "ubuntu_password" {
  default = "399ed64f98b286f8"
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
