#!/bin/bash

# Restore Gitea repository with proper setup

echo "🔧 Restoring Gitea repository..."

# Create repository via web interface simulation
echo "Creating repository via Gitea web interface..."

# Get CSRF token and session
CSRF_TOKEN=$(curl -s -c /tmp/gitea_cookies http://gitea.local:8888/user/sign_up | grep -o 'csrf" value="[^"]*' | cut -d'"' -f3)

# Login first
curl -s -b /tmp/gitea_cookies -c /tmp/gitea_cookies \
  -X POST http://gitea.local:8888/user/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "_csrf=$CSRF_TOKEN" \
  -d "user_name=admin1" \
  -d "password=admin123"

# Get new CSRF token for repo creation
CSRF_TOKEN=$(curl -s -b /tmp/gitea_cookies http://gitea.local:8888/repo/create | grep -o 'csrf" value="[^"]*' | cut -d'"' -f3)

# Create repository
curl -s -b /tmp/gitea_cookies -c /tmp/gitea_cookies \
  -X POST http://gitea.local:8888/repo/create \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "_csrf=$CSRF_TOKEN" \
  -d "uid=1" \
  -d "repo_name=Cloud-Native-Api" \
  -d "description=Cloud-Native Gauntlet Infrastructure Repository" \
  -d "repo_template=" \
  -d "issue_labels=" \
  -d "gitignores=" \
  -d "license=" \
  -d "readme=Default" \
  -d "default_branch=main" \
  -d "trust_model=default"

echo "✅ Repository created"

# Now push the code
echo "Pushing local repository to Gitea..."
git remote remove gitea 2>/dev/null || true
git remote add gitea http://admin1:admin123@gitea.local:8888/admin1/Cloud-Native-Api.git

# Push with force to overwrite
git push gitea main --force

echo "✅ Repository restored with all workflows and files"
echo "🌐 Access at: http://gitea.local:8888/admin1/Cloud-Native-Api"
