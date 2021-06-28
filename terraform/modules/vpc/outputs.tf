// vpc module

output "link" {
  description = "A link to the VPC resource, useful for creating resources inside the VPC"
  value       = google_compute_network.private_network.self_link
}

output "name" {
  description = "The name of the VPC"
  value       = google_compute_network.private_network.name
}

output "private_vpc_connection" {
  description = "The private VPC connection"
  value       = google_service_networking_connection.private_vpc_connection
}

output "private_vpc_connector" {
  description = "VPC connector in the same network as the Postgres VPC"
  value       = google_vpc_access_connector.connector.name
}
