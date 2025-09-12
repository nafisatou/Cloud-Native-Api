#!/bin/bash

echo "🌐 Setting up nginx reverse proxy for clean domain access..."

# Stop Apache2 completely
sudo systemctl stop apache2 2>/dev/null || true
sudo systemctl disable apache2 2>/dev/null || true
pkill -f apache2 2>/dev/null || true

# Install nginx if not present
if ! command -v nginx &> /dev/null; then
    echo "📦 Installing nginx..."
    sudo apt update && sudo apt install -y nginx
fi

# Remove default nginx config
sudo rm -f /etc/nginx/sites-enabled/default

# Create nginx configuration for domain routing
sudo tee /etc/nginx/sites-available/cloud-native << 'EOF'
server {
    listen 80;
    server_name argocd.local;
    location / {
        proxy_pass http://127.0.0.1:30080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name gitea.local;
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name keycloak.local;
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name linkerd.local;
    location / {
        proxy_pass http://127.0.0.1:30002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name api.local;
    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable the configuration
sudo ln -sf /etc/nginx/sites-available/cloud-native /etc/nginx/sites-enabled/

# Add DNS entries to /etc/hosts
sudo tee -a /etc/hosts << 'EOF'

# Cloud-Native Gauntlet Services
127.0.0.1 argocd.local
127.0.0.1 gitea.local
127.0.0.1 keycloak.local
127.0.0.1 linkerd.local
127.0.0.1 api.local
EOF

# Test nginx configuration
sudo nginx -t

# Start nginx
sudo systemctl enable nginx
sudo systemctl start nginx

echo "✅ Nginx reverse proxy configured!"
echo ""
echo "🌐 Clean domain access ready:"
echo "- ArgoCD: http://argocd.local"
echo "- Gitea: http://gitea.local"
echo "- Keycloak: http://keycloak.local"
echo "- Linkerd: http://linkerd.local"
echo "- API: http://api.local"
echo ""
echo "🎉 No port numbers needed!"
