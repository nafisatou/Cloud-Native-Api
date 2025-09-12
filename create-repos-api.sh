#!/bin/bash

echo "🏗️ Creating Gitea repositories via API..."

GITEA_URL="http://gitea.local:8888"
USERNAME="admin1"
PASSWORD="admin123"

# Get API token first
echo "🔑 Getting API token..."
TOKEN=$(curl -s -X POST "$GITEA_URL/api/v1/users/$USERNAME/tokens" \
  -u "$USERNAME:$PASSWORD" \
  -H "Content-Type: application/json" \
  -d '{"name": "repo-creation-token"}' | jq -r '.sha1 // empty')

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get API token, trying existing tokens..."
  # Try with a generic token approach
  TOKEN="dummy-token"
fi

echo "📦 Creating cloud-native-infra repository..."
INFRA_RESULT=$(curl -s -X POST "$GITEA_URL/api/v1/user/repos" \
  -u "$USERNAME:$PASSWORD" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "cloud-native-infra",
    "description": "Infrastructure and Terraform files for Cloud-Native Gauntlet",
    "private": false,
    "auto_init": false,
    "default_branch": "main"
  }')

echo "🦀 Creating rust-api repository..."
API_RESULT=$(curl -s -X POST "$GITEA_URL/api/v1/user/repos" \
  -u "$USERNAME:$PASSWORD" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "rust-api", 
    "description": "Rust API application for Cloud-Native Gauntlet",
    "private": false,
    "auto_init": false,
    "default_branch": "main"
  }')

echo "✅ Repository creation completed!"
echo ""
echo "📂 Results:"
echo "Infrastructure repo: $(echo $INFRA_RESULT | jq -r '.clone_url // "Check manually"')"
echo "Rust API repo: $(echo $API_RESULT | jq -r '.clone_url // "Check manually"')"
echo ""
echo "🔍 Verify at: http://gitea.local:8888/admin1"
