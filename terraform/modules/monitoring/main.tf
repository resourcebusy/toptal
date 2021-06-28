# Creating Monitoring Channel
# Essentially, how and where the oncall would be notified

resource "google_monitoring_notification_channel" "email" {
  display_name = "Sydecar Oncall"
  type         = "email"
  labels = {
    email_address = "will@sydecar.io"
  }
}

# Adding reference code for Slack Channel
# More details here
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_notification_channel

/* resource "google_monitoring_notification_channel" "default" {
  display_name = "Test Slack Channel"
  type         = "slack"
  labels = {
    "channel_name" = "#foobar"
  }
  sensitive_labels {
    auth_token = "one"
  }
} */

# Metrics that we are monitoring
# Below alert will trigger an email notification CloudSql CPU utilization breaches the threshold
# gcloud alpha monitoring policies list -> List all the monitoring alert policies
# The above command could be used to build more alerts

resource "google_monitoring_alert_policy" "cloudsql_cpu_utilization" {
  display_name = "Alert Policy for CPU utilization exceeding a given threshold"
  combiner     = "OR"
  conditions {
    display_name = "CPU utilization exceeded threshold"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\" AND resource.type=\"cloudsql_database\" AND resource.label.\"database_id\"=\"${var.project}:${var.db_instance_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.80
      trigger {
        count = 1
      }
      aggregations {
        alignment_period   = "120s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  notification_channels = [google_monitoring_notification_channel.email.id]
}
