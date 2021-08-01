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
  default = "s.MDMZDHFObcIJDQsno3T9fUCC"
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
variable "vault_kv_path_mysql" {
  default = "boundary/mysql-user"

}
variable "vault_kv_path_rdp" {
  default = "boundary/rdp-user"
}
variable "aws_host" {
  default = ""
}
variable "gcp_host" {
  default = ""
}
variable "rdp_host" {
  default = ""
}
variable "gke_endpoint" {
  default = ""
}
