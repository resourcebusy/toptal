output "connection_name" {
  description = "The connection string used by Cloud SQL Proxy, e.g. my-project:us-central1:my-db"
  value       = google_sql_database_instance.main_primary.connection_name
}

output "postgres-username-pwd" {
  description = "Password for the postgres user account"
  value       = google_secret_manager_secret.postgres-username-pwd.secret_id
}

output "postgres-dbname" {
  description = "Postgres DB name"
  value       = google_secret_manager_secret.postgres-dbname.secret_id
}

output "postgres-username" {
  description = "Postgres database user name"
  value       = google_secret_manager_secret.postgres-username.secret_id
}

output "instance_id" {
  description = "Postgres primary instance ID"
  value       = google_sql_database_instance.main_primary.id
}
