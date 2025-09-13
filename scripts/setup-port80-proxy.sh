#!/bin/bash

# Setup port 80 proxy for .local domains without requiring :30447
echo "🌐 Setting up port 80 proxy for .local domains..."

# Stop any existing nginx proxy
docker stop nginx-proxy 2>/dev/null || true
docker rm nginx-proxy 2>/dev/null || true

# Create nginx configuration
cat > /tmp/nginx-proxy.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream ingress {
        server 127.0.0.1:30447;
    }

    server {
        listen 8081;
        server_name gitea.local keycloak.local argocd.local linkerd.local rust-api.local registry.local;
        
        location / {
            proxy_pass http://ingress;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

# Start nginx proxy on port 8081 with host networking
docker run -d --name nginx-proxy \
    --network host \
    -v /tmp/nginx-proxy.conf:/etc/nginx/nginx.conf:ro \
    nginx:alpine

echo "✅ Nginx proxy started on port 8081"
echo "📋 Services now accessible at:"
echo "  - http://gitea.local:8081"
echo "  - http://keycloak.local:8081"
echo "  - http://argocd.local:8081"
echo "  - http://linkerd.local:8081"
echo "  - http://rust-api.local:8081"
echo "  - http://registry.local:8081"
