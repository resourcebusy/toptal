variable "region" {
  description = "The default region for VPC connector"
  type        = string
}

variable "cloudrun_services" {
  description = "Names of the cloud run services"
}

variable "postgres-dbname" {
  description = "Postgres Database name"
}

variable "postgres-username-pwd" {
  description = "Username for the postgres database"
}

variable "postgres-username" {
  description = "User for the postgres database"
}

variable "gcp_project_id" {
  description = "GCP Project ID"
}

variable "postgres-conn-str" {
  description = "Postgres DB connection string"
}

variable "vpc_connector_name" {
  description = "VPC connector defined in the same network as Postgres instance"
}
