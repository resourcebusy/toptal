# This GCS bucket stores Terraform state information
# TF state is a single source of truth for the infrastructure stae
# TF state stores sensitive information
# TF state bucket must be kept under strict IAM control
# Only TF needs to be able to write to it

terraform {
  backend "gcs" {
    bucket = "toptal-screening-app-tf"
    prefix = "terraform/state"
  }
}
