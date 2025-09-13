#!/bin/bash

# Cloud-Native Gauntlet - Port Forwarding Script
# This script sets up persistent port forwarding for ingress controller

echo "🚀 Starting Cloud-Native Gauntlet Port Forwarding..."

# Kill existing port forwarding processes
echo "Stopping existing port forwarding processes..."
pkill -f "kubectl port-forward" || true
sleep 2

# Start ingress controller port forwarding
echo "Starting ingress controller port forwarding on port 30447..."
nohup kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 30447:80 --address=0.0.0.0 > /tmp/port-forward-ingress.log 2>&1 &
echo "Ingress controller port forwarding started (PID: $!) - logs: /tmp/port-forward-ingress.log"

echo ""
echo "✅ Port forwarding setup complete!"
echo ""
echo "🌐 Access your services at:"
echo "  • ArgoCD Dashboard: http://argocd.local:30447"
echo "  • Linkerd Viz: http://linkerd.local:30447"
echo "  • Keycloak: http://keycloak.local:30447"
echo "  • Gitea: http://gitea.local:30447"
echo "  • Rust API: http://rust-api.local:30447"
echo "  • Registry: http://registry.local:30447"
echo ""
echo "📋 To stop all port forwarding: ./scripts/stop-port-forwarding.sh"
echo "📋 To check status: ./scripts/check-port-forwarding.sh"
