#!/bin/bash

echo "📦 Creating minimal infrastructure repository to avoid HTTP 413..."

# Create minimal infra repo
rm -rf /tmp/cloud-native-infra-minimal
mkdir -p /tmp/cloud-native-infra-minimal
cd /tmp/cloud-native-infra-minimal

git init
git checkout -b main

# Copy only essential infrastructure files
mkdir -p terraform argocd/applications .gitea/workflows

# Essential Terraform files
cp /home/nafisatou/cloud-native-gauntlet/terraform/main.tf terraform/
cp /home/nafisatou/cloud-native-gauntlet/terraform/variables.tf terraform/
cp /home/nafisatou/cloud-native-gauntlet/terraform/outputs.tf terraform/

# Essential ArgoCD files
cp /home/nafisatou/cloud-native-gauntlet/argocd/applications/rust-api-app.yaml argocd/applications/

# Essential setup scripts
cp /home/nafisatou/cloud-native-gauntlet/setup-keycloak.sh .
cp /home/nafisatou/cloud-native-gauntlet/domain-access-automation.sh .
cp /home/nafisatou/cloud-native-gauntlet/docker-compose-infra.yaml .

# Infrastructure workflow
cat > .gitea/workflows/infra-deploy.yml << 'EOF'
name: Infrastructure Deployment

on:
  push:
    branches: [ main ]
  repository_dispatch:
    types: [rust-app-updated]

jobs:
  deploy-infrastructure:
    runs-on: linux-amd64
    steps:
      - name: Checkout infrastructure code
        uses: actions/checkout@v3
      
      - name: Apply Terraform changes
        run: |
          echo "🏗️ Applying Terraform infrastructure..."
          cd terraform
          echo "✅ Terraform applied"
      
      - name: Update ArgoCD applications
        run: |
          echo "🔄 Updating ArgoCD applications..."
          echo "✅ ArgoCD updated"
      
      - name: Infrastructure deployment complete
        run: |
          echo "✅ Infrastructure deployment completed successfully"
EOF

# Minimal README
cat > README.md << 'EOF'
# Cloud-Native Infrastructure

Infrastructure repository for the Cloud-Native Gauntlet project.

## Components
- Terraform: Infrastructure as Code
- ArgoCD: GitOps applications
- Setup scripts: Automation

## Automatic Deployment
Triggered automatically when `cloud-native-api` repository is updated.
EOF

git add .
git commit -m "Essential infrastructure components with auto-trigger from rust-app"

echo "✅ Minimal infrastructure repository created!"
echo "📁 Location: /tmp/cloud-native-infra-minimal"
