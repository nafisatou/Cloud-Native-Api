#!/bin/bash

# Fix Apache conflict with .local domains
echo "🔧 Fixing Apache conflict with .local domain routing..."

# Stop nginx proxy
docker stop nginx-proxy 2>/dev/null || true
docker rm nginx-proxy 2>/dev/null || true

# Create new nginx configuration that bypasses Apache
cat > /tmp/nginx-proxy-fixed.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream ingress {
        server 127.0.0.1:30447;
    }

    server {
        listen 9080;
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

# Start nginx proxy on port 9080 (avoiding Apache on 80)
docker run -d --name nginx-proxy \
    --network host \
    -v /tmp/nginx-proxy-fixed.conf:/etc/nginx/nginx.conf:ro \
    nginx:alpine

echo "✅ Nginx proxy started on port 9080 (bypassing Apache)"
echo "📋 Services now accessible at:"
echo "  - http://gitea.local:9080"
echo "  - http://keycloak.local:9080"
echo "  - http://argocd.local:9080"
echo "  - http://linkerd.local:9080"
echo "  - http://rust-api.local:9080"
echo "  - http://registry.local:9080"
