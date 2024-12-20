# ----------------------
# Terraform Configuration
# ----------------------

terraform {
  required_version = ">= 1.9.5"

  required_providers {
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = ">= 2.32.0"
      configuration_aliases = [kubernetes]
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
  kube_config = yamldecode(file("${path.module}/../${local.config_file}"))
}

provider "kubernetes" {
  config_path = "${path.module}/../${local.config_file}"
}

provider "kubectl" {
  load_config_file = false

  config_path = "${path.module}/../${local.config_file}"
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/../${local.config_file}"
  }
}

# ----------------------
# Variables
# ----------------------

variable "namespace" {
  description = "The namespace to deploy the system to"
  type        = string
}

locals {
  config_file = "kubectl-config/${var.namespace}-kubeconfig.yaml"
}
