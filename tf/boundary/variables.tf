variable "issuer" {}
variable "client_id" {}
variable "client_secret" {}
variable "subject" {}
variable "signing_algorithms" {
  default = ["RS256"]
}
variable "vault_token_for_boundary" {
  default = "s.9csV0NjiTyN0ybeMFYlnROpd"
}
variable "vault_fqdn" {
  default = "http://127.0.0.1:8200"
}
variable "vault_psql_dba_path" {
  default = "database/creds/dba"
}
variable "vault_ssh_path" {
  default = ""
}