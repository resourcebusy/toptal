# Enable APIs for the project
# Terraform may have cyclic depedency for few APIs which may need to be enabled
# through Console UI

resource "google_project_service" "project" {
  for_each = toset(var.apis)
  project  = var.gcp_project_id
  service  = each.value

  # When tearing down, automatically traverse dependecy and take down resources.
  disable_dependent_services = true
}
