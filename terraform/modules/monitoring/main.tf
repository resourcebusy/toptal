# Creating PubSub Topics/Subscription and Log Sink for DataDog Monitoring

# LogSink for StackDriver to stream the logs to PubSub Topic
resource "google_logging_project_sink" "pubsub-sink" {
  name = "export-logs-to-datadog"

  destination = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.cloudrun-metrics.name}"
  unique_writer_identity = true
  depends_on = [
    google_pubsub_topic.cloudrun-metrics
  ]
}

# Because the sink uses a unique_writer, grant that writer access to the topic.
resource "google_project_iam_binding" "log-writer" {
  role = "roles/pubsub.publisher"

  members = [
    google_logging_project_sink.pubsub-sink.writer_identity,
  ]
}

# PubSub Topic that DataSog will subscribe to. StackDriver would stream
# cloudrun metrics on this topic

resource "google_pubsub_topic" "cloudrun-metrics" {
  name = "metrics-stream-topic"

  labels = {
    explorer = "datadog"
  }
}

# Push Forwarder PubSub Subscriber to send metrics to DataSog

resource "google_pubsub_subscription" "cloudrun-metrics-sub" {
  name  = "metrics-stream-sub"
  topic = google_pubsub_topic.cloudrun-metrics.name

  ack_deadline_seconds = 20

  labels = {
    explorer = "datadog"
  }

  push_config {
    push_endpoint = "https://gcp-intake.logs.datadoghq.com/v1/input/aa613ad7d14f09099c3ec53432a8bd68/"

    # attributes = {
    #   x-goog-version = "v1"
    # }
  }

  depends_on = [
    google_pubsub_topic.cloudrun-metrics
  ]

}
