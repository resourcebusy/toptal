# Various variables used for the entire project infrastructure
# This is the one of the main places where environment
# specific changes could be made

# Maintain alphabetical Order for easier readability

# Common Variables
variable "gcp_project_id" {
  description = "The name of the GCP project where the db and Cloud SQL Proxy will be created"
  type        = string
  default     = "toptal-screening-app"
}

variable "gcp_region" {
  description = "The GCP region where the db and Cloud SQL Proxy will be created"
  type        = string
  default     = "us-west1"
}

# APIs for the project
variable "apis" {
  description = "List of APIs that need to be enabled for the project"
  type        = list(string)
  default = [
    "cloudasset.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "containerregistry.googleapis.com",
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    #"oslogin.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "storage.googleapis.com",
    "sqladmin.googleapis.com",
    "vpcaccess.googleapis.com",
  ]
}

### Begin Cloud Build Triggers for Cloudrun Apps ###
# Variables used by cloudbuild module
variable "branch_name" {
  description = "Github branch name for CloudBuild Trigger to act against"
  type        = string
  default     = "^master$"
}

# List the triggers to be created. Generally one per cloud run app
# <where_to_find_cloudbuild.yaml_in_repo> = <Glob_filter>
# Glob filter ensures that only when files in app's directory changes, that app's trigger
# fires.
variable "filename" {
  description = "Full path to Cloudbuild.yaml file"
  type        = map(string)
  default = {
    "apps/pythondb/cloudbuild.yaml"     = "apps/pythondb/**"
    "apps/angular-realworld-example-app-main/cloudbuild.yaml"     = "apps/angular-realworld-example-app-main/**"
  }
}
### END Cloud Build Triggers ###

### Github Repo to pull cloudrun apps from. These also contain the cloudbuild.yaml ###
variable "repo_name" {
  description = "Github repo name for CloudBuild Trigger to act against"
  type        = string
  default     = "toptal"
}

variable "owner" {
  description = "Github owner/project name for CloudBuild Trigger to act against"
  type        = string
  default     = "resourcebusy"
}
#### END GitHub #####

# cloudrun module Variables
variable "cloudrun_services" {
  description = "Names of the Cloud Run services"
  type        = map(string)
  default = {
    "cloudrun-pythondb"     = "img-pythondb:latest"
  }
}

### Begin Postgres ###
# postgres database module Variables
variable "db_username" {
  description = "The Postgres username"
  type        = string
  default     = "toptal-dev"
}

variable "disk_size" {
  description = "Postgres Database Disk Size in GB"
  type        = number
  default     = 10
}

variable "instance_type" {
  description = "The Postgres instance type"
  type        = string
  default     = "db-f1-micro"
}

variable "retained_backups" {
  description = "Number of Postgres Database backups to Retain"
  type        = number
  default     = 8
}

variable "machine_type" {
  description = "Postgres Database Machine Type"
  type        = string
  default     = "f1-micro"
}
### END Postgres ####
