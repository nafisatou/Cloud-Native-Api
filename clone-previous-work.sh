#!/bin/bash

echo "🔄 Cloning your previous work from Gitea storage..."

# Create a temporary directory to clone your previous work
mkdir -p /tmp/gitea-restore
cd /tmp/gitea-restore

# Clone your previous repository from Gitea storage
docker exec gitea git clone /data/git/repositories/admin1/cloud-native-api.git cloud-native-api-backup

# Copy the cloned repository to your current directory
docker cp gitea:/tmp/cloud-native-api-backup /tmp/

echo "✅ Previous work cloned to /tmp/cloud-native-api-backup"
echo ""
echo "📋 Your previous repository contains:"
ls -la /tmp/cloud-native-api-backup/ 2>/dev/null || echo "Repository data available in Gitea storage"

echo ""
echo "🔧 Next steps:"
echo "1. Review your previous work in /tmp/cloud-native-api-backup"
echo "2. Merge any changes you want to keep into your current project"
echo "3. Create new Gitea repository through web interface"
echo "4. Push your combined work to the new repository"
