//target id
output "ssh-gcp-target-id" {
  value = boundary_target.ssh-gcp-target.id
}

output "ssh-aws-target-id" {
  value = boundary_target.ssh-aws-target.id
}

output "psql-target-id" {
  value = boundary_target.psql-target.id
}

output "mysql-target-id" {
  value = boundary_target.mysql-target.id
}

output "rdp-target-id" {
  value = boundary_target.rdp-target.id
}

//password
output "dbadmin-password" {
  value = [boundary_account.dbadmin.login_name,boundary_account.dbadmin.password]
}