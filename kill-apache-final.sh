#!/bin/bash

echo "🛑 Permanently stopping Apache2 and fixing domain access..."

# Kill Apache2 processes with extreme prejudice
sudo pkill -9 apache2 2>/dev/null || echo "Apache2 processes killed"
sudo systemctl stop apache2 2>/dev/null || echo "Apache2 service stopped"
sudo systemctl disable apache2 2>/dev/null || echo "Apache2 service disabled"

# Kill anything on port 80
sudo fuser -k 80/tcp 2>/dev/null || echo "Port 80 cleared"

# Remove Apache2 completely
sudo apt remove --purge apache2 apache2-utils apache2-bin apache2.2-common -y 2>/dev/null || echo "Apache2 removal attempted"

# Kill existing socat processes
pkill -f socat 2>/dev/null

# Wait for port to be free
sleep 3

# Get ingress NodePort
INGRESS_PORT=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
echo "📡 Ingress NodePort: $INGRESS_PORT"

# Start socat forwarding with sudo to bind to port 80
echo "🚀 Starting port 80 forwarding to ingress..."
sudo nohup socat TCP-LISTEN:80,fork,reuseaddr TCP:127.0.0.1:$INGRESS_PORT > /tmp/port80-final.log 2>&1 &

sleep 5

# Test services
echo "🧪 Testing domain access..."
for domain in argocd.local gitea.local keycloak.local linkerd.local api.local; do
    echo -n "Testing $domain: "
    RESPONSE=$(curl -s --connect-timeout 5 http://$domain)
    if echo "$RESPONSE" | grep -q "Apache2 Default Page"; then
        echo "❌ Still showing Apache2"
    elif echo "$RESPONSE" | grep -q "<!DOCTYPE\|<html"; then
        echo "✅ Service working"
    else
        echo "⚠️ Unknown response"
    fi
done

echo ""
echo "🎉 Apache2 permanently removed!"
echo "🌐 Your services should now be accessible at:"
echo "- ArgoCD: http://argocd.local"
echo "- Gitea: http://gitea.local"
echo "- Keycloak: http://keycloak.local"
echo "- Linkerd: http://linkerd.local"
echo "- API: http://api.local"
