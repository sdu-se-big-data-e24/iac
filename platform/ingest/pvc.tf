resource "kubernetes_persistent_volume_claim" "ingest" {
  provider = kubernetes

  metadata {
    name      = "${var.name}-pvc"
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
