#!/bin/bash

echo "🌐 Setting up port 80 forwarding for clean domain access..."

# Kill any existing socat processes
pkill -f "socat.*:80.*:30447" 2>/dev/null

# Get the ingress NodePort
INGRESS_PORT=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
echo "📡 Ingress NodePort: $INGRESS_PORT"

# Start port forwarding from 80 to ingress NodePort using socat
echo "🔄 Starting port 80 -> $INGRESS_PORT forwarding..."
nohup socat TCP-LISTEN:80,fork,reuseaddr TCP:127.0.0.1:$INGRESS_PORT > /tmp/port80-forward.log 2>&1 &
SOCAT_PID=$!

sleep 2

# Verify the forwarding is working
if ps -p $SOCAT_PID > /dev/null; then
    echo "✅ Port 80 forwarding active (PID: $SOCAT_PID)"
else
    echo "❌ Port 80 forwarding failed to start"
    exit 1
fi

# Test domain access
echo "🧪 Testing domain access..."
for domain in argocd.local gitea.local keycloak.local linkerd.local api.local; do
    if curl -s --connect-timeout 3 http://$domain > /dev/null; then
        echo "✅ $domain accessible"
    else
        echo "⚠️  $domain not responding"
    fi
done

echo ""
echo "🎉 Clean domain access ready!"
echo "🌐 Access services without port numbers:"
echo "- ArgoCD: http://argocd.local"
echo "- Gitea: http://gitea.local"
echo "- Keycloak: http://keycloak.local"
echo "- Linkerd: http://linkerd.local"
echo "- API: http://api.local"
