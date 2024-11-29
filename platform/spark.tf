# helm install --values spark-values.yaml spark oci://registry-1.docker.io/bitnamicharts/spark --version 9.2.10

resource "helm_release" "spark" {
  name             = "spark"
  repository       = "oci://registry-1.docker.io/"
  chart            = "bitnamicharts/spark"
  namespace        = var.namespace
  create_namespace = false
  version          = "9.2.10"
  values = [
    "${file("${path.module}/manifests/spark/spark-values.yaml")}"
  ]
}

