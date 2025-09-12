#!/bin/bash

echo "📤 Setting up remotes for Gitea and GitHub..."

# Remove existing remotes if they exist
git remote remove gitea 2>/dev/null || true
git remote remove github 2>/dev/null || true

# Add Gitea remote
echo "🔗 Adding Gitea remote..."
git remote add gitea http://admin1:admin123@gitea.local:8888/admin1/cloud-native-api.git

# Add GitHub remote  
echo "🔗 Adding GitHub remote..."
git remote add github https://github.com/nafisatou/Cloud-Native-Api.git

echo "✅ Remotes configured:"
git remote -v

echo ""
echo "📋 Next steps:"
echo "1. Create repository in Gitea web interface first"
echo "2. Then run: git push gitea main"
echo "3. Then run: git push github main"
echo ""
echo "🎉 This will push your restored work to both repositories!"
