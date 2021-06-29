# Main Terraform file
# This main file is calling the other modules to provision
# resources. To build other environments, no changes are required in this file

# Maintain alphabetcial order for easier readability

# Setup Cloud Build triggers to deploy latest code changes pushed to a specific
# repo and a specific branch

module "cloudbuild" {
  source = "../../modules/cloudbuild"

  branch_name    = var.branch_name
  filename       = var.filename
  gcp_project_id = var.gcp_project_id
  owner          = var.owner
  repo_name      = var.repo_name
}

# Setup Cloud Run services in a given region
module "cloudrun" {
  source = "../../modules/cloudrun"

  cloudrun_services     = var.cloudrun_services
  gcp_project_id        = var.gcp_project_id
  postgres-dbname       = module.postgres.postgres-dbname
  postgres-username-pwd = module.postgres.postgres-username-pwd
  postgres-username     = module.postgres.postgres-username
  postgres-conn-str     = module.postgres.connection_name
  region                = var.gcp_region
  vpc_connector_name    = module.vpc.private_vpc_connector
}

# Setup Monitoring
module "monitoring" {
  source = "../../modules/monitoring"
  project        = var.gcp_project_id
}

# Setup Postgres Database over Private IP
# Can be accessed only through CloudSql Proxy
module "postgres" {
  source = "../../modules/postgres"

  disk_size        = var.disk_size
  instance_type    = var.instance_type
  retained_backups = var.retained_backups
  user             = var.db_username
  vpc_name         = module.vpc.name
  vpc_link         = module.vpc.link

  db_depends_on = module.vpc.private_vpc_connection
}

# Setup Private VPC for Postgres DB and Bastion Host
module "vpc" {
  source = "../../modules/vpc"

  name   = "db-private-network"
  region = var.gcp_region
}
