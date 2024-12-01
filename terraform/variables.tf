# Environment (e.g., dev, staging, prod)
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "development"
}

# Kubernetes namespace
variable "namespace" {
  description = "Kubernetes namespace for WebGoat"
  type        = string
  default     = "webgoat"
}

# Resource limits for the namespace
variable "resource_limits" {
  description = "Resource limits for containers in the namespace"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "1"
    memory = "1Gi"
  }
}

# Resource requests for the namespace
variable "resource_requests" {
  description = "Resource requests for containers in the namespace"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "500m"
    memory = "512Mi"
  }
}

# Resource quotas for namespace
variable "resource_quota" {
  description = "Resource quotas for the namespace"
  type = object({
    requests_cpu    = string
    requests_memory = string
    limits_cpu      = string
    limits_memory   = string
    pods            = string
  })
  default = {
    requests_cpu    = "2"
    requests_memory = "2Gi"
    limits_cpu      = "4"
    limits_memory   = "4Gi"
    pods            = "10"
  }
}

# Container image for WebGoat
variable "webgoat_image" {
  description = "Docker image for the WebGoat application"
  type        = string
  default     = "webgoat/webgoat-8.0"
}

# Deployment replicas
variable "replicas" {
  description = "Number of replicas for the WebGoat deployment"
  type        = number
  default     = 1
}
