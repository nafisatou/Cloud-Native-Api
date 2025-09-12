#!/bin/bash

echo "🏗️ Creating Gitea repositories via API..."

GITEA_URL="http://gitea.local:8888"
USERNAME="admin1"
PASSWORD="admin123"

# Get session token
echo "🔑 Getting session token..."
SESSION=$(curl -c /tmp/gitea_cookies -s "$GITEA_URL/user/login" | grep -o 'name="_csrf" value="[^"]*"' | cut -d'"' -f4)

# Login
curl -b /tmp/gitea_cookies -c /tmp/gitea_cookies -s \
  -X POST "$GITEA_URL/user/login" \
  -d "user_name=$USERNAME" \
  -d "password=$PASSWORD" \
  -d "_csrf=$SESSION" > /dev/null

# Create cloud-native-infra repository
echo "📦 Creating cloud-native-infra repository..."
curl -b /tmp/gitea_cookies -s \
  -X POST "$GITEA_URL/api/v1/user/repos" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "cloud-native-infra",
    "description": "Infrastructure and Terraform files for Cloud-Native Gauntlet",
    "private": false,
    "auto_init": false
  }' | jq -r '.clone_url // "Error creating repo"'

# Create rust-api repository
echo "🦀 Creating rust-api repository..."
curl -b /tmp/gitea_cookies -s \
  -X POST "$GITEA_URL/api/v1/user/repos" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "rust-api",
    "description": "Rust API application for Cloud-Native Gauntlet",
    "private": false,
    "auto_init": false
  }' | jq -r '.clone_url // "Error creating repo"'

echo "✅ Repositories created!"

# Clean up
rm -f /tmp/gitea_cookies

echo ""
echo "📂 Created repositories:"
echo "- http://gitea.local:8888/admin1/cloud-native-infra"
echo "- http://gitea.local:8888/admin1/rust-api"
