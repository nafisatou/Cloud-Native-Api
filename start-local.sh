#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
KCFG="$ROOT_DIR/kind-kubeconfig-local.yaml"

echo "[1/4] Starting Docker stacks..."
if [ -f "$ROOT_DIR/docker-compose-infra.yaml" ]; then
  docker compose -f "$ROOT_DIR/docker-compose-infra.yaml" up -d
fi
docker compose -f "$ROOT_DIR/docker-compose.yaml" up -d

echo "[2/4] Ensuring kubectl context..."
export KUBECONFIG="$KCFG"

echo "[3/4] Starting port-forwards (Argo CD 30080, Linkerd Viz 30001)..."
pkill -f 'port-forward.*argocd-server' >/dev/null 2>&1 || true
pkill -f 'port-forward.*linkerd-viz' >/dev/null 2>&1 || true
nohup kubectl -n argocd port-forward svc/argocd-server 30080:80 >/tmp/argocd-pf.log 2>&1 &
nohup kubectl -n linkerd-viz port-forward svc/web 30001:8084 >/tmp/linkerd-pf.log 2>&1 &

echo "[4/4] Status summary:"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo
echo "Endpoints:"
echo "- Gitea     http://localhost:3000"
echo "- Keycloak  http://localhost:8082"
echo "- API       http://localhost:8081/health"
echo "- Registry  http://localhost:5000/v2/_catalog"
echo "- Linkerd   http://localhost:30001"
echo "- Argo CD   http://localhost:30080"

echo "Done."




