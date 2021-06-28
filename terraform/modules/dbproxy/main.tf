data "google_compute_subnetwork" "regional_subnet" {
  name   = var.vpc_name
  region = var.region
}

resource "google_compute_instance" "db_proxy" {
  name                      = "db-bastion-proxy"
  description               = <<-EOT
    A public-facing instance that proxies traffic to the database. This allows
    the db to only have a private IP address, but still be reachable from
    outside the VPC.
  EOT
  machine_type              = var.machine_type
  zone                      = var.zone
  desired_status            = "RUNNING"
  allow_stopping_for_update = true

  # Our firewall looks for this tag when deciding whether to allow SSH traffic
  # to an instance.
  tags = ["ssh-enabled"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable" # latest stable Container-Optimized OS.
      size  = 10                     # smallest disk possible is 10 GB.
      type  = "pd-ssd"               # use an SSD, not an HDD, because c'mon.
    }
  }

  # Terraform will not be able to destroy this asset until this is set to false
  # Setting to false so that Sydecar team can destroy it at will to resolve the
  # bastion host key in clear-text on GCP console UI issue
  deletion_protection = false

  lifecycle {
    prevent_destroy = false
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/run_cloud_sql_proxy.tpl", {
    "db_instance_name"    = var.db_instance_name,
    "service_account_key" = module.serviceaccount.private_key,
  })

  network_interface {
    network    = var.vpc_name
    subnetwork = data.google_compute_subnetwork.regional_subnet.self_link

    # The access_config block must be set for the instance to have a public IP,
    # even if it's empty.
    access_config {}
  }

  scheduling {
    # Migrate to another physical host during OS updates to avoid downtime.
    on_host_maintenance = "MIGRATE"
  }

  service_account {
    email = module.serviceaccount.email
    # These are OAuth scopes for the various Google Cloud APIs. We're already
    # using IAM roles (specifically, Cloud SQL Editor) to control what this
    # instance can and cannot do. We don't need another layer of OAuth
    # permissions on top of IAM, so we grant cloud-platform scope to the
    # instance. This is the maximum possible scope. It gives the instance
    # access to all Google Cloud APIs through OAuth.
    scopes = ["cloud-platform"]
  }
}

module "serviceaccount" {
  source = "../serviceaccount"

  name = "cloud-sql-proxy"
  role = "roles/cloudsql.editor"
}
