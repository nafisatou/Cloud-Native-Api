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
    netstat -tlnp 2>/dev/null | grep -E ":(30080|30002|8081|8080|3000)" || echo "  No ports found"
    
    echo ""
    echo "🌐 Service URLs:"
    echo "  • ArgoCD Dashboard: http://localhost:30080"
    echo "  • Linkerd Viz: http://localhost:30002"
    echo "  • Keycloak: http://localhost:8080"
    echo "  • Gitea: http://localhost:3000"
    echo "  • Rust API: http://localhost:8081"
else
    echo "❌ No port forwarding processes found."
    echo "Run ./scripts/start-port-forwarding.sh to start services."
fi
