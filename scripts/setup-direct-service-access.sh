#!/bin/bash

# Setup direct service access bypassing browser cache issues
echo "🔧 Setting up direct service access..."

# Stop existing nginx proxy
docker stop nginx-proxy 2>/dev/null || true
docker rm nginx-proxy 2>/dev/null || true

# Start port forwarding for problematic services
echo "Starting direct port forwards..."

# Keycloak direct access
kubectl port-forward -n cloud-native-gauntlet svc/keycloak 8090:8080 &
KEYCLOAK_PID=$!

# Linkerd viz direct access  
kubectl port-forward -n linkerd-viz svc/web 8091:8084 &
LINKERD_PID=$!

# Wait for port forwards to establish
sleep 3

echo "✅ Direct service access established:"
echo "  - Keycloak: http://localhost:8090"
echo "  - Linkerd: http://localhost:8091"
echo ""
echo "🌐 Other services still available via nginx proxy:"
echo "  - Gitea: http://gitea.local:9080"
echo "  - ArgoCD: http://argocd.local:9080"
echo "  - Rust API: http://rust-api.local:9080"
echo ""
echo "PIDs: Keycloak=$KEYCLOAK_PID, Linkerd=$LINKERD_PID"
echo "To stop: kill $KEYCLOAK_PID $LINKERD_PID"
