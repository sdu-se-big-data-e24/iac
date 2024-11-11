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

	kafka = {
      source = "Mongey/kafka"
    }
  }
}

# ----------------------
# Providers
# ----------------------

locals {
  kube_config = yamldecode(file("${path.module}/../${var.kube_config_file}"))
}

provider "kubernetes" {
  config_path = "${path.module}/../${var.kube_config_file}"
}

provider "kubectl" {
  load_config_file = false

  config_path = "${path.module}/../${var.kube_config_file}"
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/../${var.kube_config_file}"
  }
}

provider "kafka" {
  bootstrap_servers = "kafka.kafka.svc.cluster.local:9092"
}

# ----------------------
# Variables
# ----------------------

variable "kube_config_file" {
  description = "Path to the kubeconfig file (Default: kubectl-config/config.yaml)"
  type        = string
  default     = "kubectl-config/group-02-kubeconfig.yaml"
}

variable "namespace" {
  description = "The namespace to deploy the system to"
  type        = string
  default     = "group-02"
}
