#!/bin/bash

echo "🔧 Fixing domain access - removing Apache2 and setting up proper routing..."

# Kill Apache2 processes (requires sudo but we'll try without first)
echo "🛑 Stopping Apache2..."
pkill -f apache2 2>/dev/null || echo "Apache2 processes may still be running (need sudo)"

# Kill any processes on port 80
fuser -k 80/tcp 2>/dev/null || echo "Port 80 cleanup attempted"

# Add hosts entries
echo "📝 Adding /etc/hosts entries..."
if ! grep -q "argocd.local" /etc/hosts 2>/dev/null; then
    echo "127.0.0.1 argocd.local gitea.local keycloak.local linkerd.local api.local" | sudo tee -a /etc/hosts
fi

# Stop existing port forwards
pkill -f "kubectl.*port-forward" 2>/dev/null

# Apply Terraform ingress configuration
echo "🚀 Applying Terraform ingress configuration..."
cd terraform
terraform init -upgrade
terraform apply -auto-approve

# Get ingress controller port
INGRESS_PORT=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
echo "📡 Ingress controller running on port: $INGRESS_PORT"

# Set up port forwarding from 80 to ingress
echo "🔄 Setting up port 80 forwarding to ingress..."
nohup socat TCP-LISTEN:80,fork,reuseaddr TCP:127.0.0.1:$INGRESS_PORT > /tmp/port80-socat.log 2>&1 &

sleep 3

# Test domain access
echo "🧪 Testing domain access..."
for domain in argocd.local gitea.local keycloak.local linkerd.local api.local; do
    if curl -s --connect-timeout 5 http://$domain | grep -q "html\|HTTP"; then
        echo "✅ $domain accessible"
    else
        echo "❌ $domain not responding"
    fi
done

echo ""
echo "🎉 Domain access configured!"
echo "🌐 Access services at:"
echo "- ArgoCD: http://argocd.local"
echo "- Gitea: http://gitea.local"
echo "- Keycloak: http://keycloak.local"
echo "- Linkerd: http://linkerd.local"
echo "- API: http://api.local"
