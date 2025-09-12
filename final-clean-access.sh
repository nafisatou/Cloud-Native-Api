#!/bin/bash

echo "🌐 Setting up clean .local domain access without port numbers..."

# Kill existing processes
pkill -f "kubectl.*port-forward" 2>/dev/null
pkill -f socat 2>/dev/null

# Start required port forwards
kubectl port-forward -n argocd svc/argocd-server 8080:80 > /tmp/argocd.log 2>&1 &
kubectl port-forward -n cloud-native-gauntlet svc/gitea 3000:3000 > /tmp/gitea.log 2>&1 &
kubectl port-forward -n cloud-native-gauntlet svc/keycloak 8081:8080 > /tmp/keycloak.log 2>&1 &
kubectl port-forward -n linkerd-viz svc/web 8084:8084 > /tmp/linkerd.log 2>&1 &
kubectl port-forward -n cloud-native-gauntlet svc/rust-api-service 8082:80 > /tmp/api.log 2>&1 &

sleep 3

# Use socat to proxy port 80 to different services based on Host header
# This is a workaround since we can't use nginx without sudo

# Create a simple HTTP proxy script
cat > /tmp/http-proxy.py << 'EOF'
#!/usr/bin/env python3
import socket
import threading
import urllib.request
import re

def handle_request(client_socket):
    try:
        request = client_socket.recv(4096).decode()
        if not request:
            return
        
        # Extract Host header
        host_match = re.search(r'Host: ([^\r\n]+)', request)
        if not host_match:
            client_socket.close()
            return
        
        host = host_match.group(1).strip()
        
        # Route based on host
        if 'argocd.local' in host:
            target_port = 8080
        elif 'gitea.local' in host:
            target_port = 3000
        elif 'keycloak.local' in host:
            target_port = 8081
        elif 'linkerd.local' in host:
            target_port = 8084
        elif 'api.local' in host:
            target_port = 8082
        else:
            client_socket.close()
            return
        
        # Forward request to target service
        target_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        target_socket.connect(('127.0.0.1', target_port))
        target_socket.send(request.encode())
        
        # Forward response back
        response = target_socket.recv(4096)
        client_socket.send(response)
        
        target_socket.close()
        client_socket.close()
    except:
        client_socket.close()

def start_proxy():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('127.0.0.1', 8888))
    server.listen(5)
    
    while True:
        client_socket, addr = server.accept()
        thread = threading.Thread(target=handle_request, args=(client_socket,))
        thread.start()

if __name__ == "__main__":
    start_proxy()
EOF

chmod +x /tmp/http-proxy.py

# Start the proxy in background
python3 /tmp/http-proxy.py &
PROXY_PID=$!

sleep 2

echo "✅ HTTP proxy running on port 8888"
echo ""
echo "🌐 Access your services without individual port numbers:"
echo "- ArgoCD: http://argocd.local:8888"
echo "- Gitea: http://gitea.local:8888"
echo "- Keycloak: http://keycloak.local:8888"
echo "- Linkerd: http://linkerd.local:8888"
echo "- API: http://api.local:8888"
echo ""
echo "💡 All services use the same port (8888) - the proxy routes based on domain name!"
echo "🔧 Proxy PID: $PROXY_PID"
