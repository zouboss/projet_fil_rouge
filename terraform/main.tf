provider "kubernetes" {
  config_path = "~/.kube/config"
}

# SERVICES
resource "kubernetes_manifest" "postgres_service" {
  manifest = yamldecode(file("${path.module}/k8s/postgres-service.yaml"))
}

resource "kubernetes_manifest" "backend_service" {
  manifest = yamldecode(file("${path.module}/k8s/backend-service.yaml"))
}

resource "kubernetes_manifest" "frontend_service" {
  manifest = yamldecode(file("${path.module}/k8s/frontend-service.yaml"))
}

# DEPLOYMENTS
resource "kubernetes_manifest" "postgres" {
  manifest = yamldecode(file("${path.module}/k8s/postgres-statefulset.yaml"))
  depends_on = [kubernetes_manifest.postgres_service]
}

resource "kubernetes_manifest" "backend" {
  manifest = yamldecode(file("${path.module}/k8s/backend-deployment.yaml"))
  depends_on = [kubernetes_manifest.backend_service]
}

resource "kubernetes_manifest" "frontend" {
  manifest = yamldecode(file("${path.module}/k8s/frontend-deployment.yaml"))
  depends_on = [kubernetes_manifest.frontend_service]
}

# JOB DE MIGRATION
resource "kubernetes_manifest" "migrate_job" {
  manifest = yamldecode(file("${path.module}/k8s/migrate-job.yaml"))
  depends_on = [kubernetes_manifest.postgres]
}

# INGRESS
resource "kubernetes_manifest" "ingress" {
  manifest = yamldecode(file("${path.module}/k8s/ingress.yaml"))
  depends_on = [
    kubernetes_manifest.frontend_service,
    kubernetes_manifest.backend_service
  ]
}

