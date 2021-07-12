resource "boundary_credential_library_vault" "psql_dba" {
  name                = "PSQL DBA Library"
  description         = "PSQL DBA"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = var.vault_psql_dba_path
  http_method         = "GET"
}

resource "boundary_credential_library_vault" "ssh_ubuntu" {
  name                = "SSH Ubunutu Library"
  description         = "SSH Ubunutu"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = var.vault_ssh_path
  http_method         = "POST"
  http_request_body        = <<EOT
    {
      "public_key": "ssh-rsa ...."
    }
    EOT
}

resource "boundary_credential_library_vault" "kv_mysql" {
  name                = "KV MySQL Library"
  description         = "KV MySQL"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = var.vault_kv_path
  http_method         = "GET"
}