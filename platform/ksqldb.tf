resource "kubernetes_config_map" "kafka_ksqldb_server_config" {
  metadata {
    name = "kafka-ksqldb-server-config"
	namespace = var.namespace
  }

  data = {
    KSQL_BOOTSTRAP_SERVERS                          = "kafka:9092"
    KSQL_KSQL_SCHEMA_REGISTRY_URL                   = "http://kafka-schema-registry:8081"
    KSQL_LISTENERS                                  = "http://0.0.0.0:8088"
    KSQL_KSQL_LOGGING_PROCESSING_STREAM_AUTO_CREATE = "true"
    KSQL_KSQL_LOGGING_PROCESSING_TOPIC_AUTO_CREATE  = "true"
    KSQL_KSQL_SERVICE_ID                            = "kafka-ksqldb-group-id-01"
  }

  depends_on = [
    helm_release.kafka,
	kubernetes_deployment.kafka_schema_registry
  ]
}

resource "kubernetes_deployment" "kafka_ksqldb_server" {
  metadata {
    name = "kafka-ksqldb-server"
	namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kafka-ksqldb-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka-ksqldb-server"
        }
      }

      spec {
        container {
          name  = "kafka-ksqldb-server"
          image = "confluentinc/cp-ksqldb-server:7.3.1"

          env_from {
            config_map_ref {
              name = kubernetes_config_map.kafka_ksqldb_server_config.metadata.0.name
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map.kafka_ksqldb_server_config
  ]
}

resource "kubernetes_deployment" "kafka_ksqldb_cli" {
  metadata {
    name = "kafka-ksqldb-cli"
	namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kafka-ksqldb-cli"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka-ksqldb-cli"
        }
      }

      spec {
        container {
          name  = "kafka-ksqldb-cli"
          image = "confluentinc/cp-ksqldb-cli:7.3.1"
          tty   = true
          stdin = true
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.kafka_ksqldb_server
  ]
}

resource "kubernetes_service" "kafka_ksqldb_server" {
  metadata {
    name = "kafka-ksqldb-server"
	namespace = var.namespace
  }

  spec {
    type = "NodePort"

    port {
      port        = 8088
      target_port = 8088
    }

    selector = {
      app = "kafka-ksqldb-server"
    }
  }

  depends_on = [
    kubernetes_deployment.kafka_ksqldb_server
  ]
}
