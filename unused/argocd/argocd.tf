# resource "helm_release" "argocd" {
#   namespace        = var.namespace
#   create_namespace = false
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   version          = "7.6.11"

#   # Helm chart deployment can sometimes take longer than the default 5 minutes
#   timeout = 800

#   # If values file specified by the var.values_file input variable exists then apply the values from this file
#   # else apply the default values from the chart
#   # values = [""]

#   set_sensitive {
#     name  = "configs.secret.argocdServerAdminPassword"
#     value = var.argocd_admin_password == "" ? "" : bcrypt(var.argocd_admin_password)
#   }

#   set {
#     name  = "configs.params.server\\.insecure"
#     value = true
#   }

#   set {
#     name  = "dex.enabled"
#     value = true
#   }
# }