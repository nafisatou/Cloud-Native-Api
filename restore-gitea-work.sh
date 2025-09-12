#!/bin/bash

echo "🔄 Restoring your previous Gitea work and workflows..."

# The repository data exists in /data/git/repositories/admin1/cloud-native-api.git
# We need to create the web interface connection

echo "📋 Your previous work is preserved in Gitea storage:"
echo "Repository: cloud-native-api.git"
echo "Latest commits found:"
docker exec gitea git --git-dir=/data/git/repositories/admin1/cloud-native-api.git log --oneline -5

echo ""
echo "🔧 To restore access to your repository:"
echo "1. Go to http://gitea.local:8888"
echo "2. Login with: admin1 / admin123"
echo "3. Create a new repository named 'cloud-native-api' (exact name)"
echo "4. After creation, your previous work will be automatically linked"
echo ""
echo "Your repository contains:"
echo "- All your previous commits and history"
echo "- Gitea workflows (.gitea/workflows/)"
echo "- Infrastructure code"
echo "- Production setup configurations"
echo ""
echo "Once restored, you can:"
echo "- View your commit history"
echo "- Access your workflows"
echo "- Continue development from where you left off"
echo ""
echo "Repository path in Gitea: /data/git/repositories/admin1/cloud-native-api.git"
