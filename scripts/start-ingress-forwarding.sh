#!/bin/bash

# Cloud-Native Gauntlet - Ingress Port Forwarding
# Forward port 80 to ingress controller NodePort

echo "🌐 Setting up ingress port forwarding..."

# Kill any existing port forwarding on port 80
sudo pkill -f "socat.*:80" || true

# Forward port 80 to ingress controller NodePort 30447
echo "Starting port forwarding: 80 -> 30447 (ingress controller)"
nohup sudo socat TCP-LISTEN:80,fork TCP:127.0.0.1:30447 > /tmp/ingress-forward.log 2>&1 &

echo "✅ Ingress port forwarding started"
echo "📋 Access your services at:"
echo "  • ArgoCD: http://argocd.local"
echo "  • Gitea: http://gitea.local"
echo "  • Keycloak: http://keycloak.local"
echo "  • Linkerd: http://linkerd.local"
echo "  • API: http://api.local"
