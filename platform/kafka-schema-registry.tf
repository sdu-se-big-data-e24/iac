resource "kubernetes_config_map" "kafka_schema_registry_config" {
  metadata {
    name = "kafka-schema-registry-config"
	namespace = var.namespace
  }

  data = {
    SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS = "kafka:9092"
    SCHEMA_REGISTRY_LISTENERS                    = "http://0.0.0.0:8081"
  }

  depends_on = [
	helm_release.kafka
  ]
}

resource "kubernetes_deployment" "kafka_schema_registry" {
  metadata {
    name = "kafka-schema-registry"
	namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kafka-schema-registry"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka-schema-registry"
        }
      }

      spec {
        container {
          name  = "kafka-schema-registry"
          image = "confluentinc/cp-schema-registry:7.3.1"

          port {
            container_port = 8081
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.kafka_schema_registry_config.metadata.0.name
            }
          }

          env {
            name = "SCHEMA_REGISTRY_HOST_NAME"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
	kubernetes_config_map.kafka_schema_registry_config
  ]
}

resource "kubernetes_service" "kafka_schema_registry" {
  metadata {
    name = "kafka-schema-registry"
	namespace = var.namespace
  }

  spec {
    selector = {
      app = "kafka-schema-registry"
    }

    port {
      name       = "web"
      protocol   = "TCP"
      port       = 8081
      target_port = 8081
    }
  }

  depends_on = [
	kubernetes_deployment.kafka_schema_registry
  ]
}