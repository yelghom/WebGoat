terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

# Namespace
resource "kubernetes_namespace" "webgoat" {
  metadata {
    name = var.namespace
    labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

# Resource Quota
resource "kubernetes_resource_quota" "webgoat" {
  metadata {
    name      = "webgoat-quota"
    namespace = kubernetes_namespace.webgoat.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = var.resource_quota.requests_cpu
      "requests.memory" = var.resource_quota.requests_memory
      "limits.cpu"      = var.resource_quota.limits_cpu
      "limits.memory"   = var.resource_quota.limits_memory
      "pods"            = var.resource_quota.pods
    }
  }
}

# Network Policy
resource "kubernetes_network_policy" "webgoat" {
  metadata {
    name      = "${var.namespace}-network-policy"
    namespace = kubernetes_namespace.webgoat.metadata[0].name
  }
  spec {
    pod_selector {
      match_labels = {
        app = "webgoat"
      }
    }
    ingress {
      from {
        namespace_selector {
          match_labels = {
            environment = var.environment
          }
        }
      }
      ports {
        port     = 8080
        protocol = "TCP"
      }
    }
    policy_types = ["Ingress"]
  }
}

# Service Account
resource "kubernetes_service_account" "webgoat" {
  metadata {
    name      = "${var.namespace}-sa"
    namespace = kubernetes_namespace.webgoat.metadata[0].name
  }
}

# Role
resource "kubernetes_role" "webgoat" {
  metadata {
    name      = "${var.namespace}-role"
    namespace = kubernetes_namespace.webgoat.metadata[0].name
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "services"]
    verbs      = ["get", "list", "watch"]
  }
}

# Role Binding
resource "kubernetes_role_binding" "webgoat" {
  metadata {
    name      = "${var.namespace}-role-binding"
    namespace = kubernetes_namespace.webgoat.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.webgoat.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.webgoat.metadata[0].name
    namespace = kubernetes_namespace.webgoat.metadata[0].name
  }
}

# Storage Class
resource "kubernetes_storage_class" "webgoat" {
  metadata {
    name = "webgoat-storage"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  reclaim_policy      = "Retain"
}

# Deployment
resource "kubernetes_deployment" "webgoat" {
  metadata {
    name      = "webgoat-app"
    namespace = kubernetes_namespace.webgoat.metadata[0].name
    labels = {
      app = "webgoat"
    }
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        app = "webgoat"
      }
    }
    template {
      metadata {
        labels = {
          app = "webgoat"
        }
      }
      spec {
        container {
          name  = "webgoat"
          image = var.webgoat_image
          port {
            container_port = 8080
          }
          resources {
            requests = var.resource_requests
            limits   = var.resource_limits
          }
        }
      }
    }
  }
}

# Service
resource "kubernetes_service" "webgoat" {
  metadata {
    name      = "${var.namespace}-service"
    namespace = kubernetes_namespace.webgoat.metadata[0].name
  }
  spec {
    selector = {
      app = "webgoat"
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
  }
}
