# Triggers Cloud build once new code is pushed with a specific release tag
# or against a specific branch
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger

resource "google_cloudbuild_trigger" "filename-trigger" {

  # Trigger name has to be unique across the project
  # Depending on the number of cloudbuild yaml files, we build a
  # unique name for each trigger
  for_each    = var.filename
  name        = format("%s%s", split("/", each.key)[1], "-trigger")
  description = "Build Trigger against push to a specific repo/branch"
  filename    = each.key # Cloudbuild file name and its path

  github {
    owner = var.owner     # Owner of the repository
    name  = var.repo_name # Name of the repository
    push {
      # Push can be setup against a branch name or a specific tag
      branch = var.branch_name
    }
  }

  included_files = [each.value]

  # Tag for the trigger. Not mandatory
  tags = [
  ]
}

/* resource "google_service_account" "sa" {
  account_id   = "my-service-account"
  display_name = "Cloud build's default service account"
} */

# Data block to fetch the project number
data "google_project" "project" {
}

# Add IAM role for Cloud Build SA to impersonate to run as projectnumber-compute@developer.gserviceaccount.com
resource "google_service_account_iam_binding" "add_role_serviceAccount_user" {
  service_account_id = "projects/${var.gcp_project_id}/serviceAccounts/${data.google_project.project.number}-compute@developer.gserviceaccount.com"

  role = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
  ]
}

# Add IAM "roles/run.admin" role to Cloud Build SA to be able to deploy the service
resource "google_project_iam_binding" "add_role_run_admin" {
  role = "roles/run.admin"
  members = [
    "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
  ]
}
