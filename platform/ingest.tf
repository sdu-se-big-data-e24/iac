resource "kubernetes_persistent_volume_claim" "producer_energinet_consumption_industry_pvc" {
  metadata {
    name      = "producer-energinet-consumption-industry-pvc"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "producer_energinet_consumption_industry" {
  metadata {
    name      = "producer-energinet-consumption-industry"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "producer-energinet-consumption-industry"
      }
    }

    template {
      metadata {
        labels = {
          app = "producer-energinet-consumption-industry"
        }
      }

      spec {
        container {
          name  = "producer-energinet-consumption-industry"
          image = "ghcr.io/sdu-se-big-data-e24/ingest-energinet-producer:latest"

          image_pull_policy = "Always"

          env {
            name  = "API_URL"
            value = "https://api.energidataservice.dk/dataset/ProductionConsumptionSettlement"
          }

          env {
            name  = "ORDER_BY"
            value = "HourUTC"
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
            value = "ProductionConsumptionSettlement"
          }

          env {
            name  = "VALUE_SCHEMA_SUBJECT"
            value = "ProductionConsumptionSettlement-value"
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
            value = kubernetes_service.redis.metadata.0.name
          }

          env {
            name  = "REDIS_PORT"
            value = "6379"
          }

          env {
            name  = "REDIS_DB"
            value = "0" # Database number (0-15)
          }

          env {
            name  = "SLEEP_DELAY"
            value = 60
          }

          volume_mount {
            name       = "producer-energinet-consumption-industry-storage"
            mount_path = "/root/code"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "500m"
            }

            limits = {
              memory = "1Gi"
              cpu    = "1"
            }
          }
        }

        volume {
          name = "producer-energinet-consumption-industry-storage"

          persistent_volume_claim {
            claim_name = "producer-energinet-consumption-industry-pvc"
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.kafka,
    kubernetes_deployment.redis
  ]
}
