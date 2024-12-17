resource "helm_release" "kafka" {
  name             = "kafka"
  repository       = "oci://registry-1.docker.io/"
  chart            = "bitnamicharts/kafka"
  namespace        = var.namespace
  create_namespace = false
  version          = "30.0.4"
  values = [
    "${file("${path.module}/manifests/kafka-cluster/kafka-values.yaml")}"
  ]
}

# Add Redpanda ui
resource "kubernetes_config_map_v1" "redpanda_config" {
  metadata {
    name      = "redpanda-config"
    namespace = var.namespace
  }
  data = {
    KAFKA_BROKERS                = "kafka:9092"
    KAFKA_SCHEMAREGISTRY_ENABLED = "true"
    KAFKA_SCHEMAREGISTRY_URLS    = "http://kafka-schema-registry:8081"
    CONNECT_ENABLED              = "true"
    CONNECT_CLUSTERS_NAME        = "Connectors"
    CONNECT_CLUSTERS_URL         = "http://kafka-connect:8083"
  }

  depends_on = [
    helm_release.kafka
  ]
}

resource "kubernetes_deployment_v1" "redpanda" {
  metadata {
    name      = "redpanda"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "redpanda"
      }
    }
    template {
      metadata {
        labels = {
          app = "redpanda"
        }
      }
      spec {
        container {
          name  = "redpanda"
          image = "redpandadata/console:v2.7.0"
          port {
            container_port = 8080
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.redpanda_config.metadata.0.name
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map_v1.redpanda_config
  ]
}

resource "kubernetes_service_v1" "redpanda" {
  metadata {
    name      = "redpanda"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "redpanda"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }
  }

  depends_on = [
    kubernetes_deployment_v1.redpanda
  ]
}
