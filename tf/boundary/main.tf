terraform {
  required_providers {
    boundary = {
      source = "hashicorp/boundary"
      version = "1.0.3"
    }
  }
}

provider "boundary" {
  addr                            = "http://127.0.0.1:9200"
  auth_method_id                  = "ampw_1234567890"
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "password"
}

resource "boundary_scope" "global" {
  global_scope = true
  scope_id     = "global"
}

resource "boundary_scope" "org" {
  name                     = var.org
  scope_id                 = boundary_scope.global.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "project" {
  name                   = "Demo Project"
  description            = "My first scope!"
  scope_id               = boundary_scope.org.id
  auto_create_admin_role = true
}

resource "boundary_host_catalog" "my-host-catalog" {
  name     = "My Host Catalog"
  type     = "static"
  scope_id = boundary_scope.project.id
}

resource "boundary_credential_store_vault" "vault" {
  name        = "Vault Creds Store"
  description = "My first Vault credential store!"
  address     = var.vault_fqdn
  token       = var.vault_token_for_boundary
  scope_id    = boundary_scope.project.id
}
