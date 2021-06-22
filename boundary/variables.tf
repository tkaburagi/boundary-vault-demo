variable "issuer" {}
variable "client_id" {}
variable "client_secret" {}
variable "subject" {}
variable "signing_algorithms" {
  default = ["RS256"]
}