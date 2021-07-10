resource "boundary_host" "aws-demo" {
  name            = "aws-demo"
  type            = "static"
  address         = "35.74.166.40"
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
}

resource "boundary_host" "gcp-demo" {
  name            = "gcp-demo"
  type            = "static"
  address         = "34.84.245.180"
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

