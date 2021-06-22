resource "boundary_scope" "global" {
  global_scope = true
  scope_id     = "global"
}

resource "boundary_scope" "org" {
  name                     = "tkaburagi"
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

resource "boundary_host" "aws-demo" {
  name            = "aws-demo"
  type            = "static"
  address         = "13.231.69.129"
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
}

resource "boundary_host" "gcp-demo" {
  name            = "gcp-demo"
  type            = "static"
  address         = "35.200.15.197"
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
}

resource "boundary_host_set" "aws" {
  name            = "AWS hosts set"
  type            = "static"
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
  host_ids = [
    boundary_host.aws-demo.id
  ]
}

resource "boundary_host_set" "gcp" {
  name            = "GCP hosts set"
  type            = "static"
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
  host_ids = [
    boundary_host.gcp-demo.id
  ]
}

resource "boundary_target" "ssh-target" {
  name         = "SSH Target"
  type         = "tcp"
  default_port = "22"
  scope_id     = boundary_scope.project.id
  host_set_ids = [
    boundary_host_set.gcp.id,
    boundary_host_set.aws.id
  ]
}

