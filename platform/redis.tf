resource "kubernetes_persistent_volume_claim_v1" "redis-data" {
  metadata {
    name      = "redis-data"
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

resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          name  = "redis"
          image = "redis:bookworm"

          image_pull_policy = "Always"

          volume_mount {
            name       = "redis-data"
            mount_path = "/data"
          }

          liveness_probe {
            exec {
              command = ["sh -c redis-cli ping"]
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }

        volume {
          name = "redis-data"

          persistent_volume_claim {
            claim_name = "redis-data"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }
  }
}
