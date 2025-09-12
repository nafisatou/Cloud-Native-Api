#!/bin/bash

echo "📦 Creating minimal Gitea repository with essential files only..."

# Create clean directory
rm -rf /tmp/gitea-minimal
mkdir -p /tmp/gitea-minimal
cd /tmp/gitea-minimal

# Initialize fresh repo
git init
git checkout -b main

# Copy only essential files
echo "📋 Adding essential files..."

# Workflows (most important)
mkdir -p .gitea/workflows
cp /home/nafisatou/cloud-native-gauntlet/.gitea/workflows/api-ci.yml .gitea/workflows/

# Core documentation
cp /home/nafisatou/cloud-native-gauntlet/README.md .

# Docker compose files
cp /home/nafisatou/cloud-native-gauntlet/docker-compose.yaml .
cp /home/nafisatou/cloud-native-gauntlet/docker-compose-infra.yaml .

# Setup scripts (essential only)
cp /home/nafisatou/cloud-native-gauntlet/setup-keycloak.sh .
cp /home/nafisatou/cloud-native-gauntlet/domain-access-automation.sh .

# ArgoCD application config
mkdir -p argocd/applications
cp /home/nafisatou/cloud-native-gauntlet/argocd/applications/rust-api-app.yaml argocd/applications/

# Rust API manifests (create minimal structure)
mkdir -p app/rust-api/k8s
cat > app/rust-api/k8s/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rust-api
  namespace: cloud-native-gauntlet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: rust-api
  template:
    metadata:
      labels:
        app: rust-api
    spec:
      containers:
      - name: rust-api
        image: rust-api:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: rust-api-service
  namespace: cloud-native-gauntlet
spec:
  selector:
    app: rust-api
  ports:
  - port: 80
    targetPort: 8080
EOF

# Add and commit
git add .
git commit -m "Essential Cloud-Native Gauntlet files with workflows"

# Set remote and push
git remote add origin http://admin1:admin123@gitea.local:8888/admin1/cloud-native-api.git
git push -u origin main --force

echo "✅ Essential files pushed to Gitea successfully!"
echo "📁 Repository contains:"
echo "  - Gitea workflows (.gitea/workflows/api-ci.yml)"
echo "  - README and documentation"
echo "  - Docker compose files"
echo "  - ArgoCD application config"
echo "  - Rust API Kubernetes manifests"
echo "  - Setup scripts"
