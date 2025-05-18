provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}

resource "kubernetes_manifest" "postgres" {
  manifest = yamldecode(file("${path.module}/k8s/postgres.yaml"))
}

resource "kubernetes_manifest" "backend" {
  manifest = yamldecode(file("${path.module}/k8s/backend.yaml"))
  depends_on = [kubernetes_manifest.postgres]
}

resource "kubernetes_manifest" "migrate_job" {
  manifest = yamldecode(file("${path.module}/k8s/migrate-job.yaml"))
  depends_on = [kubernetes_manifest.backend]
}

resource "kubernetes_manifest" "frontend" {
  manifest = yamldecode(file("${path.module}/k8s/frontend.yaml"))
  depends_on = [kubernetes_manifest.migrate_job]
}

resource "kubernetes_manifest" "ingress" {
  manifest = yamldecode(file("${path.module}/k8s/ingress.yaml"))
  depends_on = [kubernetes_manifest.frontend]
}

