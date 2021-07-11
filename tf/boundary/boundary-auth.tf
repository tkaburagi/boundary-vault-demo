//oidc
resource "boundary_auth_method_oidc" "oidc_azuread" {
  name                 = "Azure AD Authentication"
  description          = "Default OIDC Auth Method"
  scope_id             = boundary_scope.org.id
  type                 = "oidc"
  issuer               = var.issuer
  client_id            = var.client_id
  client_secret        = var.client_secret
  signing_algorithms   = var.signing_algorithms
  api_url_prefix       = "http://localhost:9200"
  is_primary_for_scope = true
}

resource "boundary_account_oidc" "boundary_account_oidc" {
  auth_method_id = boundary_auth_method_oidc.oidc_azuread.id
  description    = "Default OIDC Account"
  issuer         = var.issuer
  subject        = var.subject
}

resource "boundary_user" "tkaburagi" {
  name        = "kabu"
  description = "kabu's user resource"
  account_ids = [boundary_account_oidc.boundary_account_oidc.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_role" "server-admin" {
  name           = "Server Admin Role"
  grant_scope_id = boundary_scope.project.id
  grant_strings = [
    "id=*;type=target;actions=*",
    "id=${boundary_host_catalog.my-host-catalog.id};actions=*",
    "id=*;type=host-set;actions=*",
    "id=${boundary_host.aws-demo.id};actions=*",
    "id=${boundary_host.gcp-demo.id};actions=*",
    "id=*;type=session;actions=cancel:self,read"
  ]
  scope_id      = boundary_scope.org.id
  principal_ids = [boundary_user.tkaburagi.id]
}

//passsword
resource "boundary_auth_method" "password" {
  scope_id = boundary_scope.org.id
  type     = "password"
}

resource "boundary_account" "dbadmin" {
  auth_method_id = boundary_auth_method.password.id
  type           = "password"
  login_name     = "dbadmin"
  password       = "password"
}

resource "boundary_user" "dbadmin" {
  name        = "dbadmin"
  description = "dbadmin's user resource"
  account_ids = [boundary_account.dbadmin.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_role" "psql-admin" {
  name           = "PSQL Admin Role"
  grant_scope_id = boundary_scope.project.id
  grant_strings = [
    "id=*;type=target;actions=*",
    "id=${boundary_host_set.local.id};actions=*",
    "id=${boundary_host.localhost.id};actions=*",
    "id=${boundary_host_catalog.my-host-catalog.id};actions=*",
    "id=*;type=session;actions=cancel:self,read"
  ]
  scope_id      = boundary_scope.org.id
  principal_ids = [boundary_user.dbadmin.id]
}