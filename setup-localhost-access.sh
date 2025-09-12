#!/bin/bash

echo "🌐 Setting up localhost access without Apache2 conflicts..."

# Check if Apache2 is running and stop it
if pgrep apache2 > /dev/null; then
    echo "🛑 Apache2 detected, attempting to stop..."
    pkill -f apache2 2>/dev/null || echo "Apache2 processes killed"
fi

# Kill any process using port 80
echo "🔍 Freeing port 80..."
fuser -k 80/tcp 2>/dev/null || echo "Port 80 is free"

# Add local DNS entries to /etc/hosts (user-level)
echo "🌐 Adding local DNS entries..."
if ! grep -q "argocd.local" /etc/hosts 2>/dev/null; then
    echo "127.0.0.1 argocd.local gitea.local keycloak.local linkerd.local api.local" | tee -a ~/.hosts
    echo "📝 DNS entries added to ~/.hosts"
    echo "Note: You may need to manually add these to /etc/hosts with sudo:"
    echo "127.0.0.1 argocd.local gitea.local keycloak.local linkerd.local api.local"
fi

# Start domain access automation
echo "🚀 Starting domain access automation..."
./domain-access-automation.sh

echo ""
echo "✅ Setup complete! Services accessible at:"
echo "🌐 ArgoCD: http://argocd.local"
echo "🌐 Gitea: http://gitea.local" 
echo "🌐 Keycloak: http://keycloak.local"
echo "🌐 Linkerd: http://linkerd.local"
echo "🌐 API: http://api.local"
echo ""
echo "💡 If domains don't resolve, add this to /etc/hosts:"
echo "127.0.0.1 argocd.local gitea.local keycloak.local linkerd.local api.local"
