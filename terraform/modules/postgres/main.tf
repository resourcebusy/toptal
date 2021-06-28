data "google_project" "project" {

}

resource "google_sql_database" "main" {
  name     = "main"
  instance = google_sql_database_instance.main_primary.name
}

# Can't re-use the same db instance name for 7 days once its deleted
# Using a random integer to generate a unique DB name
resource "random_integer" "make_db_name_unique" {
  min = 1
  max = 50000
}

# TODO: Add sample code for "database flags"
# TODO: Point-in-time recovery
resource "google_sql_database_instance" "main_primary" {
  name             = "main-primary-${random_integer.make_db_name_unique.result}"
  database_version = "POSTGRES_13"
  depends_on       = [var.db_depends_on]

  # Don't allow terraform to delete this resource
  lifecycle {
    prevent_destroy = false
  }

  settings {
    tier              = var.instance_type
    availability_type = "REGIONAL"
    disk_size         = var.disk_size

    ip_configuration {
      ipv4_enabled    = false # Has to be false to get a private IP
      private_network = var.vpc_link
    }

    # Automated backups for the database
    backup_configuration {
      enabled = true
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7

      backup_retention_settings {
        retention_unit   = "COUNT"
        retained_backups = var.retained_backups
      }
    }

  }

  deletion_protection = false # Set this to true for PROD
}

# Generate a random password for postgres user
resource "random_string" "random" {
  length  = 12
  special = false
}

resource "google_sql_user" "db_user" {
  name     = var.user
  instance = google_sql_database_instance.main_primary.name
  password = random_string.random.result
}

resource "google_secret_manager_secret" "postgres-username" {
  secret_id = "postgres-username"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "postgres-username-pwd" {
  secret_id = "postgres-username-pwd"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "postgres-dbname" {
  secret_id = "postgres-dbname"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "postgres-username-1" {

  secret      = google_secret_manager_secret.postgres-username.id
  secret_data = google_sql_user.db_user.name
}

resource "google_secret_manager_secret_version" "postgres-username-pwd-1" {

  secret      = google_secret_manager_secret.postgres-username-pwd.id
  secret_data = google_sql_user.db_user.password
}

resource "google_secret_manager_secret_version" "postgres-dbname-1" {

  secret      = google_secret_manager_secret.postgres-dbname.id
  secret_data = google_sql_database.main.name

}

resource "google_secret_manager_secret_iam_member" "secret-access-username" {
  provider = google-beta

  secret_id  = google_secret_manager_secret.postgres-username.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.postgres-username]
}


resource "google_secret_manager_secret_iam_member" "secret-access-pwd" {
  provider = google-beta

  secret_id  = google_secret_manager_secret.postgres-username-pwd.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.postgres-username-pwd]
}

resource "google_secret_manager_secret_iam_member" "secret-access-postgres-dbname" {
  provider = google-beta

  secret_id  = google_secret_manager_secret.postgres-dbname.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.postgres-dbname]
}
