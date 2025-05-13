#!/bin/bash

set -e

echo "🧹 Suppression des ressources conflictuelles (MicroK8s)..."

# Utiliser microk8s kubectl
KUBECTL="microk8s kubectl"
HELM="helm"  # ou "microk8s helm3" si tu utilises helm via MicroK8s

# Supprimer le namespace si présent
$KUBECTL delete ns ingress-nginx --ignore-not-found=true

# Supprimer les ressources globales
$KUBECTL delete clusterrole ingress-nginx --ignore-not-found=true
$KUBECTL delete clusterrolebinding ingress-nginx --ignore-not-found=true
$KUBECTL delete ingressclass nginx --ignore-not-found=true
$KUBECTL delete validatingwebhookconfiguration ingress-nginx-admission --ignore-not-found=true
$KUBECTL delete mutatingwebhookconfiguration ingress-nginx-admission --ignore-not-found=true

# Attendre la suppression complète du namespace
echo "⏳ Attente de la suppression complète du namespace..."
while $KUBECTL get ns ingress-nginx > /dev/null 2>&1; do
  sleep 2
done

echo "✅ Nettoyage terminé."

echo "📦 Ajout du dépôt ingress-nginx..."
$HELM repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
$HELM repo update

echo "🚀 Réinstallation de ingress-nginx avec Helm..."

$HELM uninstall ingress-nginx -n ingress-nginx 2>/dev/null || true

$HELM install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace

echo "✅ Installation terminée. Vérifie les pods :"
$KUBECTL get pods -n ingress-nginx

