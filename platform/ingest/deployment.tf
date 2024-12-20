resource "kubernetes_deployment" "ingest" {
  provider = kubernetes

  metadata {
    name      = "ingest-${var.name}"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ingest-${var.name}"
      }
    }

    template {
      metadata {
        labels = {
          app = "ingest-${var.name}"
        }
      }

      spec {
        container {
          name  = "ingest-${var.name}"
          image = "ghcr.io/sdu-se-big-data-e24/${var.image}"

          image_pull_policy = "Always"

          env {
            name  = "API_URL"
            value = var.endpoint_url
          }

          env {
            name  = "ORDER_BY"
            value = var.order_by
          }

          # env {
          #   name  = "FROM_DATE"
          #   value = "2024-11-01"
          # }

          # env {
          #   name  = "TO_DATE"
          #   value = "2021-01-01T01:00:00Z"
          # }

          env {
            name  = "KAFKA_BOOTSTRAP_SERVERS_HOST"
            value = "kafka"
          }

          env {
            name  = "KAFKA_BOOTSTRAP_SERVERS_PORT"
            value = "9092"
          }

          env {
            name  = "KAFKA_TOPIC"
            value = var.kafka_topic
          }

          env {
            name  = "SCHEMA_REGISTRY_HOST"
            value = "kafka-schema-registry"
          }

          env {
            name  = "SCHEMA_REGISTRY_PORT"
            value = "8081"
          }

          env {
            name  = "REDIS_HOST"
            value = var.redis_host
          }

          env {
            name  = "REDIS_PORT"
            value = "6379"
          }

          env {
            name  = "REDIS_DB"
            value = var.redis_db # Database number (0-15)
          }

          env {
            name  = "SLEEP_DELAY"
            value = 60
          }

          volume_mount {
            name       = "${var.name}-storage"
            mount_path = "/root/code"
          }

          resources {
            requests = {
              memory = "50Mi"
              cpu    = "10m"
            }

            limits = {
              memory = "1Gi"
              cpu    = "1"
            }
          }
        }

        volume {
          name = "${var.name}-storage"

          persistent_volume_claim {
            claim_name = "${var.name}-pvc"
          }
        }
      }
    }
  }
}
