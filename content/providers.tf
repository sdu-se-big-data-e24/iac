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

    kafka-connect = {
      source = "Mongey/kafka-connect"
    }

    schemaregistry = {
      source  = "cad/schemaregistry"
      version = "0.1.0"
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

provider "kafka" {
  bootstrap_servers = ["localhost:9092"]
  kafka_version     = "3.8.0"
}

provider "kafka-connect" {
  url                  = "http://localhost:8083"
  tls_auth_is_insecure = true # Optionnal if you do not want to check CA 
}

provider "schemaregistry" {
  uri = "http://localhost:8082"
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
