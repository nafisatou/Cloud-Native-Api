#!/bin/bash

echo "🚀 Starting Cloud-Native Gauntlet with Domain Access Automation"

# Function to check if port forwarding is running
check_port_forward() {
    local service=$1
    local port=$2
    if pgrep -f "kubectl.*port-forward.*$service.*$port" > /dev/null; then
        echo "✅ $service port forwarding already running"
        return 0
    else
        echo "❌ $service port forwarding not running"
        return 1
    fi
}

# Start ingress port forwarding (port 80 to 8888)
echo "🔧 Setting up ingress port forwarding for domain access..."
if ! check_port_forward "ingress-nginx-controller" "8888:80"; then
    echo "Starting ingress port forwarding..."
    nohup kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8888:80 > /tmp/ingress-forward.log 2>&1 &
    sleep 2
fi

# Verify ingress is accessible
echo "🌐 Testing domain access..."
for domain in "argocd.local" "gitea.local" "keycloak.local" "linkerd.local" "api.local"; do
    if curl -s -o /dev/null -w "%{http_code}" http://$domain:8888 | grep -q "200\|302\|404"; then
        echo "✅ $domain:8888 accessible"
    else
        echo "⚠️  $domain:8888 not responding"
    fi
done

echo ""
echo "🎉 Domain Access Ready!"
echo ""
echo "🌐 Access your services at:"
echo "- ArgoCD:     http://argocd.local:8888"
echo "- Gitea:      http://gitea.local:8888"
echo "- Keycloak:   http://keycloak.local:8888"
echo "- Linkerd:    http://linkerd.local:8888"
echo "- Rust API:   http://api.local:8888"
echo ""
echo "💡 No need to remember ports - just use the domain names!"
echo "🔧 Port forwarding runs in background automatically"
