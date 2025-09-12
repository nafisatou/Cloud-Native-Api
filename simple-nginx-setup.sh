#!/bin/bash

echo "🔧 Setting up nginx without sudo for clean domain access..."

# Kill existing port forwards
pkill -f "kubectl.*port-forward" 2>/dev/null

# Start the port forwards we need
kubectl port-forward -n argocd svc/argocd-server 8080:80 > /tmp/argocd.log 2>&1 &
kubectl port-forward -n cloud-native-gauntlet svc/gitea 3000:3000 > /tmp/gitea.log 2>&1 &
kubectl port-forward -n cloud-native-gauntlet svc/keycloak 8081:8080 > /tmp/keycloak.log 2>&1 &
kubectl port-forward -n linkerd-viz svc/web 8084:8084 > /tmp/linkerd.log 2>&1 &
kubectl port-forward -n cloud-native-gauntlet svc/rust-api-service 8082:80 > /tmp/api.log 2>&1 &

sleep 3

# Create nginx config in home directory (no sudo needed)
mkdir -p ~/.nginx
cat > ~/.nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    server {
        listen 8888;
        server_name argocd.local;
        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }

    server {
        listen 8888;
        server_name gitea.local;
        location / {
            proxy_pass http://127.0.0.1:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }

    server {
        listen 8888;
        server_name keycloak.local;
        location / {
            proxy_pass http://127.0.0.1:8081;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }

    server {
        listen 8888;
        server_name linkerd.local;
        location / {
            proxy_pass http://127.0.0.1:8084;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }

    server {
        listen 8888;
        server_name api.local;
        location / {
            proxy_pass http://127.0.0.1:8082;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
EOF

# Kill any existing nginx processes
pkill nginx 2>/dev/null

# Start nginx with our config
nginx -c ~/.nginx/nginx.conf -p ~/.nginx/ &

sleep 2

echo "✅ Nginx proxy running on port 8888"
echo ""
echo "🌐 Access your services without port numbers:"
echo "- ArgoCD: http://argocd.local:8888"
echo "- Gitea: http://gitea.local:8888"
echo "- Keycloak: http://keycloak.local:8888"
echo "- Linkerd: http://linkerd.local:8888"
echo "- API: http://api.local:8888"
echo ""
echo "💡 Just add :8888 to your .local domains - no other ports needed!"
