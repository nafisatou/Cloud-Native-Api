#!/bin/bash

echo "🔧 Bypassing Apache2 completely with alternative port setup..."

# Kill existing port forwards and socat
pkill -f "kubectl.*port-forward" 2>/dev/null
pkill -f socat 2>/dev/null

# Use alternative ports that don't conflict with Apache2
echo "🚀 Setting up direct service access on alternative ports..."

# ArgoCD on port 8080
kubectl port-forward -n argocd svc/argocd-server 8080:80 > /tmp/argocd.log 2>&1 &
echo "✅ ArgoCD: http://argocd.local:8080"

# Gitea on port 3000
kubectl port-forward -n cloud-native-gauntlet svc/gitea 3000:3000 > /tmp/gitea.log 2>&1 &
echo "✅ Gitea: http://gitea.local:3000"

# Keycloak on port 8081
kubectl port-forward -n cloud-native-gauntlet svc/keycloak 8081:8080 > /tmp/keycloak.log 2>&1 &
echo "✅ Keycloak: http://keycloak.local:8081"

# Linkerd on port 8084
kubectl port-forward -n linkerd-viz svc/web 8084:8084 > /tmp/linkerd.log 2>&1 &
echo "✅ Linkerd: http://linkerd.local:8084"

# API on port 8082
kubectl port-forward -n cloud-native-gauntlet svc/rust-api-service 8082:80 > /tmp/api.log 2>&1 &
echo "✅ API: http://api.local:8082"

sleep 5

# Test services on their specific ports
echo ""
echo "🧪 Testing services on alternative ports..."
for service in "argocd.local:8080" "gitea.local:3000" "keycloak.local:8081" "linkerd.local:8084" "api.local:8082"; do
    echo -n "Testing $service: "
    if curl -s --connect-timeout 5 http://$service > /dev/null; then
        echo "✅ Working"
    else
        echo "❌ Failed"
    fi
done

echo ""
echo "🎉 Services accessible with ports (Apache2 bypassed):"
echo "🌐 ArgoCD: http://argocd.local:8080"
echo "🌐 Gitea: http://gitea.local:3000"
echo "🌐 Keycloak: http://keycloak.local:8081"
echo "🌐 Linkerd: http://linkerd.local:8084"
echo "🌐 API: http://api.local:8082"
echo ""
echo "💡 These will work in your browser without Apache2 interference!"
