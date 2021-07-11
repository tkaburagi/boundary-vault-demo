resource "boundary_credential_library_vault" "psql_dba" {
  name                = "PSQL DBA Library"
  description         = "PSQL DBA"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = "database/creds/dba"
  http_method         = "GET"
}

