#!/bin/bash

echo "🌐 Setting up permanent .local domain access..."

# Kill any existing port forwards to ingress
pkill -f "kubectl.*port-forward.*ingress-nginx" 2>/dev/null

# Start persistent port forwarding to ingress controller
echo "🔄 Starting ingress port forwarding..."
nohup kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 30447:80 > /tmp/ingress-forward.log 2>&1 &
FORWARD_PID=$!

sleep 3

# Verify port forwarding is working
if ps -p $FORWARD_PID > /dev/null; then
    echo "✅ Ingress port forwarding active (PID: $FORWARD_PID)"
else
    echo "❌ Port forwarding failed to start"
    exit 1
fi

# Test all services
echo "🧪 Testing .local domain access..."
for service in "argocd.local" "gitea.local" "keycloak.local" "linkerd.local" "api.local"; do
    echo -n "Testing $service: "
    if curl -s --connect-timeout 5 -H "Host: $service" http://127.0.0.1:30447 > /dev/null; then
        echo "✅ Working"
    else
        echo "❌ Failed"
    fi
done

echo ""
echo "🎉 .local domain access is ready!"
echo ""
echo "🌐 Access your services at:"
echo "- ArgoCD: http://argocd.local:30447"
echo "- Gitea: http://gitea.local:30447"  
echo "- Keycloak: http://keycloak.local:30447"
echo "- Linkerd: http://linkerd.local:30447"
echo "- API: http://api.local:30447"
echo ""
echo "💡 Note: Use port 30447 to access services via .local domains"
echo "📝 Port forwarding PID: $FORWARD_PID (saved to /tmp/ingress-forward.log)"
