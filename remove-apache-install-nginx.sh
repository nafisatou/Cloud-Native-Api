#!/bin/bash

echo "🔧 Removing Apache2 and installing nginx for clean domain access..."

# Force remove Apache2 completely
sudo apt remove --purge apache2 apache2-utils apache2-bin apache2.2-common -y
sudo apt autoremove -y
sudo systemctl stop apache2 2>/dev/null || true
sudo systemctl disable apache2 2>/dev/null || true

# Kill any remaining Apache processes
sudo pkill -9 apache2 2>/dev/null || true

# Install nginx
sudo apt update
sudo apt install -y nginx

# Stop nginx default service
sudo systemctl stop nginx

# Remove default nginx config
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-available/default

# Create nginx configuration for clean domain routing
sudo tee /etc/nginx/sites-available/cloud-native-proxy << 'EOF'
server {
    listen 80;
    server_name argocd.local;
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
        proxy_pass http://127.0.0.1:8081;
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
        proxy_pass http://127.0.0.1:8084;
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
        proxy_pass http://127.0.0.1:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable the configuration
sudo ln -sf /etc/nginx/sites-available/cloud-native-proxy /etc/nginx/sites-enabled/

# Test nginx configuration
sudo nginx -t

# Start nginx
sudo systemctl start nginx
sudo systemctl enable nginx

echo "✅ Apache2 removed, nginx installed and configured!"
echo ""
echo "🌐 Clean domain access ready:"
echo "- ArgoCD: http://argocd.local"
echo "- Gitea: http://gitea.local"
echo "- Keycloak: http://keycloak.local"
echo "- Linkerd: http://linkerd.local"
echo "- API: http://api.local"
