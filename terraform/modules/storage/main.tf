# Create GCS buckets
resource "google_storage_bucket" "gcs_bucket" {
  for_each      = toset(var.bucket_names)
  name          = "${var.project}-${each.value}"
  location      = "US"
  force_destroy = true

  # Check with Will
  /*   lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  } */
}

# TODO: Check with Will
resource "google_storage_bucket_iam_binding" "gcs_readers_binding" {
  for_each = toset(var.bucket_names)
  bucket   = google_storage_bucket.gcs_bucket[each.value].name
  role     = "roles/storage.objectViewer"
  members  = var.gcs_bucket_readers

}

resource "google_storage_bucket_iam_binding" "gcs_writers_binding" {
  for_each = toset(var.bucket_names)
  bucket   = google_storage_bucket.gcs_bucket[each.value].name
  role     = "roles/storage.objectAdmin"
  members  = var.gcs_bucket_writers
}
