#!/bin/bash

echo "🌐 Setting up simple domain access without port numbers..."

# Kill existing port forwarding processes
pkill -f "kubectl.*port-forward" 2>/dev/null
pkill -f "socat" 2>/dev/null

# Start kubectl port-forward for each service on standard ports
echo "🚀 Starting service port forwarding..."

# ArgoCD on port 80
kubectl port-forward -n argocd svc/argocd-server 80:80 > /tmp/argocd-80.log 2>&1 &
echo "✅ ArgoCD: http://argocd.local"

# Gitea on port 3000  
kubectl port-forward -n cloud-native-gauntlet svc/gitea 3000:3000 > /tmp/gitea-3000.log 2>&1 &
echo "✅ Gitea: http://gitea.local:3000"

# Keycloak on port 8080
kubectl port-forward -n cloud-native-gauntlet svc/keycloak 8080:8080 > /tmp/keycloak-8080.log 2>&1 &
echo "✅ Keycloak: http://keycloak.local:8080"

# Linkerd on port 8084
kubectl port-forward -n linkerd-viz svc/web 8084:8084 > /tmp/linkerd-8084.log 2>&1 &
echo "✅ Linkerd: http://linkerd.local:8084"

# API on port 8081
kubectl port-forward -n cloud-native-gauntlet svc/rust-api-service 8081:80 > /tmp/api-8081.log 2>&1 &
echo "✅ API: http://api.local:8081"

sleep 3

echo ""
echo "🎉 Services ready! Access without complex ports:"
echo "🌐 ArgoCD: http://argocd.local (port 80)"
echo "🌐 Gitea: http://gitea.local:3000"  
echo "🌐 Keycloak: http://keycloak.local:8080"
echo "🌐 Linkerd: http://linkerd.local:8084"
echo "🌐 API: http://api.local:8081"
echo ""
echo "💡 Add to /etc/hosts if needed:"
echo "127.0.0.1 argocd.local gitea.local keycloak.local linkerd.local api.local"
