#!/bin/bash

echo "🌐 Setting up clean domain access (no ports needed)..."

# Add local DNS entries to /etc/hosts
echo "📝 Adding DNS entries to /etc/hosts..."
cat << 'EOF' | sudo tee -a /etc/hosts
# Cloud-Native Gauntlet Services
127.0.0.1 argocd.local
127.0.0.1 gitea.local  
127.0.0.1 keycloak.local
127.0.0.1 linkerd.local
127.0.0.1 api.local
EOF

# Create nginx config to proxy domains to correct ports
echo "🔧 Creating nginx proxy configuration..."
sudo tee /etc/nginx/sites-available/cloud-native-proxy << 'EOF'
server {
    listen 8080;
    server_name argocd.local;
    location / {
        proxy_pass http://127.0.0.1:30080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 8080;
    server_name gitea.local;
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 8080;
    server_name keycloak.local;
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 8080;
    server_name linkerd.local;
    location / {
        proxy_pass http://127.0.0.1:30002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 8080;
    server_name api.local;
    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Enable the configuration
sudo ln -sf /etc/nginx/sites-available/cloud-native-proxy /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

echo "✅ Clean domain access configured!"
echo ""
echo "🌐 Access services at:"
echo "- ArgoCD: http://argocd.local:8080"
echo "- Gitea: http://gitea.local:8080"
echo "- Keycloak: http://keycloak.local:8080"
echo "- Linkerd: http://linkerd.local:8080"
echo "- API: http://api.local:8080"
