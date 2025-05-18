variable "kubeconfig_path" {
  default = "/var/lib/jenkins/.kube/config"
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# SERVICES
resource "kubernetes_manifest" "postgres_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "postgres-service"
      namespace = "default"
    }
    spec = {
      selector = {
        app = "postgres"
      }
      ports = [
        {
          protocol   = "TCP"
          port       = 5432
          targetPort = 5432
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "backend_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "backend-service"
      namespace = "default"
    }
    spec = {
      selector = {
        app = "backend"
      }
      ports = [
        {
          protocol   = "TCP"
          port       = 8000
          targetPort = 8000
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "frontend_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "frontend-service"
      namespace = "default"
    }
    spec = {
      selector = {
        app = "frontend"
      }
      ports = [
        {
          protocol   = "TCP"
          port       = 3000
          targetPort = 3000
        }
      ]
    }
  }
}

# DEPLOYMENTS
resource "kubernetes_manifest" "postgres" {
  manifest = merge(
    yamldecode(file("${path.module}/k8s/postgres-statefulset.yaml")),
    {
      metadata = merge(
        yamldecode(file("${path.module}/k8s/postgres-statefulset.yaml")).metadata,
        { namespace = "default" }
      )
    }
  )
  depends_on = [kubernetes_manifest.postgres_service]
}

resource "kubernetes_manifest" "backend" {
  manifest = merge(
    yamldecode(file("${path.module}/k8s/backend-deployment.yaml")),
    {
      metadata = merge(
        yamldecode(file("${path.module}/k8s/backend-deployment.yaml")).metadata,
        { namespace = "default" }
      )
    }
  )
  depends_on = [kubernetes_manifest.backend_service]
}

resource "kubernetes_manifest" "frontend" {
  manifest = merge(
    yamldecode(file("${path.module}/k8s/frontend-deployment.yaml")),
    {
      metadata = merge(
        yamldecode(file("${path.module}/k8s/frontend-deployment.yaml")).metadata,
        { namespace = "default" }
      )
    }
  )
  depends_on = [kubernetes_manifest.frontend_service]
}

# JOB DE MIGRATION
resource "kubernetes_manifest" "migrate_job" {
  manifest = merge(
    yamldecode(file("${path.module}/k8s/migrate-job.yaml")),
    {
      metadata = merge(
        yamldecode(file("${path.module}/k8s/migrate-job.yaml")).metadata,
        { namespace = "default" }
      )
    }
  )
  depends_on = [kubernetes_manifest.postgres]
}

# INGRESS
resource "kubernetes_manifest" "ingress" {
  manifest = merge(
    yamldecode(file("${path.module}/k8s/ingress.yaml")),
    {
      metadata = merge(
        yamldecode(file("${path.module}/k8s/ingress.yaml")).metadata,
        { namespace = "default" }
      )
    }
  )
  depends_on = [
    kubernetes_manifest.frontend_service,
    kubernetes_manifest.backend_service
  ]
}
