variable "bucket_names" {
  description = "The names of GCS buckets"
  type        = list(string)
}

variable "project" {
  description = "The name of GCP Project"
  type        = string
}

variable "gcs_bucket_writers" {
  description = "List of users that are GCS storage admins"
  type        = list(string)
}

variable "gcs_bucket_readers" {
  description = "List of users that are GCS storage admins"
  type        = list(string)
}
