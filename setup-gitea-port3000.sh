#!/bin/bash

# Setup Gitea admin user on port 3000

echo "📂 Setting up Gitea admin user..."

# Wait for Gitea to be ready
echo "Waiting for Gitea to be ready..."
until curl -s http://localhost:3000 > /dev/null; do
    echo "Waiting for Gitea..."
    sleep 2
done

echo "Gitea is ready!"

# Try to create admin user via first-time setup
echo "Creating admin user admin1..."
curl -X POST http://localhost:3000/user/sign_up \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "user_name=admin1" \
  -d "email=admin@cloudnative.local" \
  -d "password=admin123" \
  -d "retype=admin123" \
  -v

echo ""
echo "✅ Gitea admin user setup attempted!"
echo "🔑 Credentials: admin1/admin123"
