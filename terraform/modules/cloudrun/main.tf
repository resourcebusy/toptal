# Start of the configuration for Cloud Run Servie

resource "google_cloud_run_service" "run_service" {
  project  = var.gcp_project_id
  provider = google-beta
  location = var.region

  # Iterate through key-value maps of [service_name:image_name]
  for_each = var.cloudrun_services
  name     = each.key

  template {
    metadata {
      annotations = {
        "client.knative.dev/user-image"           = "gcr.io/toptal-screening-app/img-pythondb:latest"
        "run.googleapis.com/client-name"          = "cloud-console"
        "run.googleapis.com/cloudsql-instances"   = var.postgres-conn-str
        "run.googleapis.com/vpc-access-connector" = "projects/${var.gcp_project_id}/locations/${var.region}/connectors/${var.vpc_connector_name}"
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "autoscaling.knative.dev/maxScale"        = 100
      }
    }
    spec {
      service_account_name  = "484881786086-compute@developer.gserviceaccount.com"
      containers {
        image = "gcr.io/${var.gcp_project_id}/${each.value}"
        env {
          name  = "CLOUD_SQL_CONNECTION_NAME"
          value = var.postgres-conn-str
        }
        env {
          name = "DB_NAME"
          value_from {
            secret_key_ref {
              name = var.postgres-dbname
              key  = "latest"
            }
          }
        }
        env {
          name = "DB_USER"
          value_from {
            secret_key_ref {
              name = var.postgres-username
              key  = "latest"
            }
          }
        }
        env {
          name = "DB_PASS"
          value_from {
            secret_key_ref {
              name = var.postgres-username-pwd
              key  = "latest"
            }
          }
        }
      }
    }
  }
  # Removing the below metadata block breaks Cloud Run. Official docs shows included.
  #https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service#example-usage---cloud-run-service-secret-environment-variables
  metadata {
    annotations = {
      generated-by                      = "magic-modules"
      "run.googleapis.com/launch-stage" = "ALPHA"
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  autogenerate_revision_name = true

  lifecycle {
    ignore_changes = [
      metadata.0.annotations,
    ]
  }
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  for_each = var.cloudrun_services
  service  = each.key
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
  depends_on = [
    google_cloud_run_service.run_service
  ]
}
