#!/bin/bash

# Setup Gitea admin user and restore repository

echo "📂 Setting up Gitea admin user and repository..."

# Wait for Gitea to be ready
echo "Waiting for Gitea to be ready..."
until curl -s http://gitea.local:8888 > /dev/null; do
    echo "Waiting for Gitea..."
    sleep 5
done

# Create admin user via API
echo "Creating admin user..."
curl -X POST http://gitea.local:8888/user/sign_up \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "user_name=admin1" \
  -d "email=admin@cloudnative.local" \
  -d "password=admin123" \
  -d "retype=admin123"

# Login and get session
echo "Logging in..."
SESSION=$(curl -c /tmp/gitea_cookies -b /tmp/gitea_cookies -X POST http://gitea.local:8888/user/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "user_name=admin1" \
  -d "password=admin123" \
  -s -D /tmp/gitea_headers | grep -i "set-cookie" | head -1)

# Create repository
echo "Creating Cloud-Native-Api repository..."
curl -b /tmp/gitea_cookies -X POST http://gitea.local:8888/api/v1/user/repos \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Cloud-Native-Api",
    "description": "Cloud-Native Gauntlet Infrastructure Repository",
    "private": false,
    "auto_init": true,
    "gitignores": "",
    "license": "",
    "readme": "Default"
  }'

echo "✅ Gitea setup complete!"
echo ""
echo "🌐 Access Gitea at: http://gitea.local:8888"
echo "🔑 Admin credentials: admin1/admin123"
echo "📂 Repository: Cloud-Native-Api"
echo ""
echo "📋 Next steps:"
echo "1. Push your local repository to Gitea"
echo "2. Configure ArgoCD to watch the Gitea repository"
echo ""
