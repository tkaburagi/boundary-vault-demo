resource "boundary_host" "gke-demo" {
  name            = "gke-demo"
  type            = "static"
  address         = var.gke_endpoint
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
}

resource "boundary_host_set" "gke" {
  name            = "GKE hosts set"
  type            = "static"
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
  host_ids = [
    boundary_host.gke-demo.id
  ]
}

resource "boundary_target" "gke-target" {
  name         = "GKE Target"
  type         = "tcp"
  default_port = "443"
  scope_id     = boundary_scope.project.id
  host_set_ids = [
    boundary_host_set.gke.id
  ]
  # application_credential_library_ids = [
  #   boundary_credential_library_vault.kv_gke.id
  # ]
}
