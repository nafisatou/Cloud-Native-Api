#!/bin/bash

echo "🏗️ Setting up complete cloud-native-infra repository..."

# Create complete infrastructure repository
rm -rf /tmp/cloud-native-infra-complete
mkdir -p /tmp/cloud-native-infra-complete
cd /tmp/cloud-native-infra-complete

git init
git checkout -b main

# Copy ALL infrastructure files from main repo
echo "📦 Copying complete infrastructure..."
cp -r /home/nafisatou/cloud-native-gauntlet/terraform .
cp -r /home/nafisatou/cloud-native-gauntlet/argocd .
cp -r /home/nafisatou/cloud-native-gauntlet/k3s-config .
cp -r /home/nafisatou/cloud-native-gauntlet/ansible .
cp -r /home/nafisatou/cloud-native-gauntlet/scripts .

# Copy all setup and automation scripts
cp /home/nafisatou/cloud-native-gauntlet/setup-*.sh .
cp /home/nafisatou/cloud-native-gauntlet/docker-compose*.yaml .
cp /home/nafisatou/cloud-native-gauntlet/domain-access-automation.sh .
cp /home/nafisatou/cloud-native-gauntlet/Vagrantfile .
cp /home/nafisatou/cloud-native-gauntlet/keycloak.yaml .
cp /home/nafisatou/cloud-native-gauntlet/linkerd-viz-config.yaml .
cp /home/nafisatou/cloud-native-gauntlet/*.md .

# Create infrastructure workflow that gets triggered by rust-app
mkdir -p .gitea/workflows
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
          terraform init
          terraform plan
          terraform apply -auto-approve
      
      - name: Update ArgoCD applications
        run: |
          echo "🔄 Updating ArgoCD applications..."
          kubectl apply -f argocd/applications/
      
      - name: Deploy Kubernetes manifests
        run: |
          echo "☸️ Deploying Kubernetes resources..."
          find . -name "*.yaml" -path "*/k8s/*" -exec kubectl apply -f {} \;
      
      - name: Verify deployment
        run: |
          echo "✅ Infrastructure deployment completed"
          kubectl get pods -A
EOF

# Create comprehensive README
cat > README.md << 'EOF'
# Cloud-Native Infrastructure

Complete infrastructure repository for the Cloud-Native Gauntlet project.

## Components

- **Terraform**: Infrastructure as Code for Kubernetes ingress and services
- **ArgoCD**: GitOps application definitions and sync policies  
- **Kubernetes**: Deployment manifests and configurations
- **Ansible**: Configuration management and automation
- **Scripts**: Setup and maintenance automation
- **Docker Compose**: Local development infrastructure

## Structure

```
├── terraform/          # Infrastructure provisioning
├── argocd/             # GitOps applications  
├── k3s-config/         # Kubernetes cluster config
├── ansible/            # Configuration management
├── scripts/            # Automation scripts
├── .gitea/workflows/   # CI/CD pipelines
└── setup-*.sh          # Setup automation
```

## Automatic Deployment

This repository is automatically triggered when changes are pushed to the `cloud-native-api` repository, ensuring infrastructure stays in sync with application changes.

## Services Managed

- ArgoCD Dashboard
- Keycloak Authentication
- Gitea Git Repository
- Linkerd Service Mesh
- Ingress Controllers
- Local Registry
EOF

git add .
git commit -m "Complete infrastructure repository with all components

- Terraform infrastructure as code
- ArgoCD GitOps applications
- Kubernetes manifests and configs
- Ansible automation
- Setup and maintenance scripts
- Automatic deployment triggered by rust-app changes"

echo "✅ Complete infrastructure repository created!"
echo "📁 Location: /tmp/cloud-native-infra-complete"
