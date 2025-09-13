#!/bin/bash

# Cloud-Native Gauntlet - Check Port Forwarding Status

echo "🔍 Checking port forwarding status..."
echo ""

# Check if processes are running
if pgrep -f "kubectl port-forward" > /dev/null; then
    echo "✅ Port forwarding processes are running:"
    ps aux | grep "kubectl port-forward" | grep -v grep | while read line; do
        echo "  $line"
    done
    echo ""
    
    # Check which ports are listening
    echo "📡 Active ports:"
    netstat -tlnp 2>/dev/null | grep -E ":30447" || echo "  No ports found"
    
    echo ""
    echo "🌐 Service URLs:"
    echo "  • ArgoCD Dashboard: http://argocd.local:30447"
    echo "  • Linkerd Viz: http://linkerd.local:30447"
    echo "  • Keycloak: http://keycloak.local:30447"
    echo "  • Gitea: http://gitea.local:30447"
    echo "  • Rust API: http://rust-api.local:30447"
    echo "  • Registry: http://registry.local:30447"
else
    echo "❌ No port forwarding processes found."
    echo "Run ./scripts/start-port-forwarding.sh to start services."
fi
