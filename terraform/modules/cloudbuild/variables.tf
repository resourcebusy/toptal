variable "branch_name" {
  description = "Github branch name for Cloud Build Trigger"
  type        = string
}

variable "filename" {
  description = "Full path to Cloudbuild.yaml file"
  type        = map(string)
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "repo_name" {
  description = "The GitHub repo name that contains the code to be built"
  type        = string
}

variable "owner" {
  description = "The GitHub repo owner"
  type        = string
}
