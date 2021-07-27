variable "issuer" {}
variable "client_id" {}
variable "client_secret" {}
variable "subject" {}
variable "org" {
  default = "kabuorg"
}
variable "signing_algorithms" {
  default = ["RS256"]
}
variable "vault_token_for_boundary" {
  default = "s.sk4b0R4NoyvZL3ujGRo0kazY"
}
variable "vault_fqdn" {
  default = "http://127.0.0.1:8200"
}
variable "vault_psql_dba_path" {
  default = "database/creds/dba"
}
variable "vault_ssh_path" {
  default = "ssh/sign/ubuntu"
}
variable "vault_kv_path" {
  default = "boundary/mysql-user"
}
variable "aws_host" {
  default = "176.34.4.197"
}
variable "gcp_host" {
  default = "34.146.166.173"
}
variable "rdp_host" {
  default = "40.117.185.50"
}