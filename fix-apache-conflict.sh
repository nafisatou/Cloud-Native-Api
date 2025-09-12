#!/bin/bash

echo "🔧 Fixing Apache2 port conflict for localhost access..."

# Stop Apache2 to free port 80
echo "🛑 Stopping Apache2..."
sudo systemctl stop apache2
sudo systemctl disable apache2

# Kill any processes using port 80
echo "🔍 Checking for processes on port 80..."
sudo fuser -k 80/tcp 2>/dev/null || echo "No processes found on port 80"

# Set up local DNS entries for domain access
echo "🌐 Setting up local DNS entries..."
sudo tee -a /etc/hosts << 'EOF'

# Cloud-Native Gauntlet Services
127.0.0.1 argocd.local
127.0.0.1 gitea.local
127.0.0.1 keycloak.local
127.0.0.1 linkerd.local
127.0.0.1 api.local
EOF

# Start ingress port forwarding for domain access
echo "🚀 Starting ingress port forwarding..."
./scripts/start-ingress-forwarding.sh

echo "✅ Apache2 conflict resolved!"
echo ""
echo "🌐 Services now accessible via:"
echo "- ArgoCD: http://argocd.local"
echo "- Gitea: http://gitea.local"
echo "- Keycloak: http://keycloak.local"
echo "- Linkerd: http://linkerd.local"
echo "- API: http://api.local"
