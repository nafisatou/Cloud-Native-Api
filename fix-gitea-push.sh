#!/bin/bash

echo "🔧 Fixing Gitea push issues..."

# Create a fresh lightweight repository for Gitea
mkdir -p /tmp/gitea-clean
cd /tmp/gitea-clean

# Initialize fresh repo
git init
git checkout -b main

# Copy essential files only (exclude large .git history)
cp -r /home/nafisatou/cloud-native-gauntlet/.gitea .
cp /home/nafisatou/cloud-native-gauntlet/README.md .
cp /home/nafisatou/cloud-native-gauntlet/docker-compose*.yaml .
cp /home/nafisatou/cloud-native-gauntlet/setup-*.sh .
cp /home/nafisatou/cloud-native-gauntlet/domain-access-automation.sh .
cp -r /home/nafisatou/cloud-native-gauntlet/app .
cp -r /home/nafisatou/cloud-native-gauntlet/argocd .
cp -r /home/nafisatou/cloud-native-gauntlet/terraform .

# Add and commit
git add .
git commit -m "Initial Cloud-Native Gauntlet setup with workflows"

# Set remote and push
git remote add origin http://admin1:admin123@gitea.local:8888/admin1/cloud-native-api.git
git push -u origin main

echo "✅ Clean repository pushed to Gitea"
