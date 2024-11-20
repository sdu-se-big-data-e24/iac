resource "kubernetes_config_map" "kafka_connect_config" {
  metadata {
    name = "kafka-connect-config"
	namespace = var.namespace
  }

  data = {
    HADOOP_USER_NAME                            = "root"
    CONNECT_BOOTSTRAP_SERVERS                   = "kafka:9092"
    CONNECT_REST_PORT                           = "8083"
    CONNECT_GROUP_ID                            = "kafka-connect-group-id-01"
    CONNECT_CONFIG_STORAGE_TOPIC                = "_connect-configs"
    CONNECT_OFFSET_STORAGE_TOPIC                = "_connect-offsets"
    CONNECT_STATUS_STORAGE_TOPIC                = "_connect-status"
    CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR   = "1"
    CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR   = "1"
    CONNECT_STATUS_STORAGE_REPLICATION_FACTOR   = "1"
    CONNECT_PLUGIN_PATH                         = "/usr/share/java,/usr/share/confluent-hub-components,/data/connect-jars"
    CONNECT_KEY_CONVERTER                       = "io.confluent.connect.avro.AvroConverter"
    CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL   = "http://kafka-schema-registry:8081"
    CONNECT_VALUE_CONVERTER                     = "io.confluent.connect.avro.AvroConverter"
    CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL = "http://kafka-schema-registry:8081"
    CONNECT_INTERNAL_KEY_CONVERTER              = "org.apache.kafka.connect.json.JsonConverter"
    CONNECT_INTERNAL_VALUE_CONVERTER            = "org.apache.kafka.connect.json.JsonConverter"
  }

  depends_on = [
    helm_release.kafka,
	kubernetes_config_map.kafka_schema_registry_config
  ]
}

resource "kubernetes_persistent_volume_claim" "kafka_connect_pvc" {
  metadata {
    name = "kafka-connect-pvc"
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

resource "kubernetes_deployment" "kafka_connect" {
  metadata {
    name = "kafka-connect"
	namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kafka-connect"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka-connect"
        }
      }

      spec {
        security_context {
          run_as_user     = 1000
          run_as_group    = 1000
          run_as_non_root = true
        }

        volume {
          name = "kafka-connect-pv-storage"

          persistent_volume_claim {
            claim_name = "kafka-connect-pvc"
          }
        }

        container {
          name  = "kafka-connect"
          image = "registry.gitlab.sdu.dk/jah/bigdatarepo/kafka-connect:7.3.1"

          security_context {
            allow_privilege_escalation = false
          }

          volume_mount {
            mount_path = "/data/"
            name       = "kafka-connect-pv-storage"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.kafka_connect_config.metadata.0.name
            }
          }

          env {
            name = "CONNECT_REST_ADVERTISED_HOST_NAME"

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
    kubernetes_config_map.kafka_connect_config
  ]
}

resource "kubernetes_service" "kafka_connect" {
  metadata {
    name = "kafka-connect"
	namespace = var.namespace
  }

  spec {
    type = "NodePort"

    port {
      port        = 8083
      target_port = 8083
    }

    selector = {
      app = "kafka-connect"
    }
  }

  depends_on = [
    kubernetes_deployment.kafka_connect
  ]
}
