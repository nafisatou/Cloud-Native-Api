#!/bin/bash

echo "📤 Pushing separate repositories to Gitea..."

# Push infrastructure repository
echo "🏗️ Pushing cloud-native-infra repository..."
cd /tmp/cloud-native-infra

git remote add origin http://admin1:admin123@gitea.local:8888/admin1/cloud-native-infra.git
git push -u origin main

echo "✅ Infrastructure repository pushed"

# Push rust-api repository  
echo "🦀 Pushing rust-api repository..."
cd /tmp/rust-api

git remote add origin http://admin1:admin123@gitea.local:8888/admin1/rust-api.git
git push -u origin main

echo "✅ Rust API repository pushed"

echo ""
echo "🎉 Both repositories successfully pushed to Gitea!"
echo ""
echo "📂 Repositories created:"
echo "- http://gitea.local:8888/admin1/cloud-native-infra (Infrastructure & Terraform)"
echo "- http://gitea.local:8888/admin1/rust-api (Rust application code)"
echo ""
echo "📋 Next steps:"
echo "1. Create the repositories in Gitea web interface first"
echo "2. Run this script to push the code"
echo "3. Set up the Gitea runner"
echo "4. Update ArgoCD to watch both repositories"
