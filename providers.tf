# ----------------------
# Terraform Configuration
# ----------------------

terraform {
  required_version = ">= 1.9.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.32.0"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.16.1"
    }
  }
}

# ----------------------
# Providers
# ----------------------

locals {
  kube_config = yamldecode(file("${path.module}/${var.kube_config_file}"))
}

provider "kubernetes" {
  host                   = local.kube_config.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)

  client_certificate = base64decode(local.kube_config.users[0].user.client-certificate-data)
  client_key         = base64decode(local.kube_config.users[0].user.client-key-data)
}

provider "kubectl" {
  load_config_file = false

  host                   = local.kube_config.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)

  client_certificate = base64decode(local.kube_config.users[0].user.client-certificate-data)
  client_key         = base64decode(local.kube_config.users[0].user.client-key-data)
}

provider "helm" {
  kubernetes {
    host                   = local.kube_config.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)

    client_certificate = base64decode(local.kube_config.users[0].user.client-certificate-data)
    client_key         = base64decode(local.kube_config.users[0].user.client-key-data)
  }
}

# ----------------------
# Variables
# ----------------------

variable "kube_config_file" {
  description = "Path to the kubeconfig file (Default: kubectl-config/config.yaml)"
  type        = string
  default     = "kubectl-config/group-02-kubeconfig.yaml"
}
