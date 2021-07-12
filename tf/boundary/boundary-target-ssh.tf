resource "boundary_host" "aws-demo" {
  name            = "aws-demo"
  type            = "static"
  address         = var.aws_host
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
}

resource "boundary_host" "gcp-demo" {
  name            = "gcp-demo"
  type            = "static"
  address         = var.gcp_host
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

resource "boundary_target" "ssh-aws-target" {
  name         = "SSH AWS Target"
  type         = "tcp"
  default_port = "22"
  scope_id     = boundary_scope.project.id
  host_set_ids = [
    boundary_host_set.aws.id
  ]
  application_credential_library_ids = [
    //todo
    boundary_credential_library_vault.kv_mysql.id
  ]
}

resource "boundary_target" "ssh-gcp-target" {
  name         = "SSH GCP Target"
  type         = "tcp"
  default_port = "22"
  scope_id     = boundary_scope.project.id
  host_set_ids = [
    boundary_host_set.gcp.id,
  ]
  application_credential_library_ids = [
    boundary_credential_library_vault.ssh_ubuntu.id
  ]
}