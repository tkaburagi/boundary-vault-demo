resource "boundary_target" "mysql-target" {
  name         = "MySQL Target"
  type         = "tcp"
  default_port = "3306"
  scope_id     = boundary_scope.project.id
  host_set_ids = [
    boundary_host_set.local.id
  ]
  application_credential_library_ids = [
    //todo
    boundary_credential_library_vault.kv_mysql.id
  ]
}