//target id
output "target-ids" {
  value = [
    "GCP VM: ${boundary_target.ssh-gcp-target.id}",
    "AWS VM: ${boundary_target.ssh-aws-target.id}",
    "AZURE RDP: ${boundary_target.rdp-target.id}",
    "LOCAL MYSQL: ${boundary_target.mysql-target.id}",
    "LOCAL POSTGRES: ${boundary_target.psql-target.id}",
    "GKE K8S: ${boundary_target.gke-target.id}",
  ]
}

//password
output "dbadmin-password" {
  value = [boundary_account.dbadmin.login_name, boundary_account.dbadmin.password]
}

output "auth-method" {
  value = [
    "PASSWORD: ${boundary_auth_method.password.id}",
    "AZURE AD: ${boundary_auth_method_oidc.oidc_azuread.id}"
    ]
}