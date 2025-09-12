#!/bin/bash

echo "🔧 Setting up separate repositories: rust-api and cloud-native-infra"

# Create infrastructure repository (terraform, k8s manifests, etc.)
echo "📦 Creating cloud-native-infra repository..."
rm -rf /tmp/cloud-native-infra
mkdir -p /tmp/cloud-native-infra
cd /tmp/cloud-native-infra

git init
git checkout -b main

# Infrastructure files
mkdir -p terraform argocd/applications k8s
cp -r /home/nafisatou/cloud-native-gauntlet/terraform/* terraform/
cp -r /home/nafisatou/cloud-native-gauntlet/argocd/* argocd/
cp /home/nafisatou/cloud-native-gauntlet/docker-compose*.yaml .
cp /home/nafisatou/cloud-native-gauntlet/setup-*.sh .
cp /home/nafisatou/cloud-native-gauntlet/domain-access-automation.sh .

# Create k8s manifests for rust-api
cat > k8s/rust-api-deployment.yaml << 'EOF'
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
        env:
        - name: DATABASE_URL
          value: "postgresql://postgres:password@postgres:5432/todoapp"
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
  type: ClusterIP
EOF

# Infrastructure workflows
mkdir -p .gitea/workflows
cat > .gitea/workflows/infra-ci.yml << 'EOF'
name: Infrastructure CI/CD

on:
  push:
    branches: [ main ]

jobs:
  deploy-infra:
    runs-on: linux-amd64
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Apply Terraform
        run: |
          cd terraform
          terraform init
          terraform plan
          terraform apply -auto-approve
      
      - name: Update ArgoCD
        run: |
          echo "✅ Infrastructure updated"
          kubectl apply -f argocd/applications/
EOF

# README for infra repo
cat > README.md << 'EOF'
# Cloud-Native Infrastructure

This repository contains the infrastructure components for the Cloud-Native Gauntlet:

- **Terraform**: Infrastructure as Code
- **ArgoCD**: GitOps application definitions
- **K8s Manifests**: Kubernetes deployment files
- **Setup Scripts**: Automation scripts

## Structure
```
├── terraform/          # Infrastructure provisioning
├── argocd/             # GitOps applications
├── k8s/                # Kubernetes manifests
├── .gitea/workflows/   # CI/CD pipelines
└── setup-*.sh          # Setup automation
```
EOF

git add .
git commit -m "Initial infrastructure repository setup"

echo "✅ Infrastructure repository created in /tmp/cloud-native-infra"

# Create rust-api repository
echo "📦 Creating rust-api repository..."
rm -rf /tmp/rust-api
mkdir -p /tmp/rust-api
cd /tmp/rust-api

git init
git checkout -b main

# Copy rust-api specific files
cp -r /home/nafisatou/cloud-native-gauntlet/app/rust-api/* . 2>/dev/null || echo "Rust API files not found, creating structure"

# Create basic Rust API structure if not exists
mkdir -p src
cat > Cargo.toml << 'EOF'
[package]
name = "rust-api"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1.0", features = ["full"] }
warp = "0.3"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
EOF

cat > src/main.rs << 'EOF'
use warp::Filter;

#[tokio::main]
async fn main() {
    let health = warp::path("health")
        .map(|| warp::reply::json(&serde_json::json!({"status": "ok"})));

    let routes = health;

    warp::serve(routes)
        .run(([0, 0, 0, 0], 8080))
        .await;
}
EOF

cat > Dockerfile << 'EOF'
FROM rust:1.70 as builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/rust-api /usr/local/bin/rust-api
EXPOSE 8080
CMD ["rust-api"]
EOF

# Rust API workflows
mkdir -p .gitea/workflows
cat > .gitea/workflows/rust-api-ci.yml << 'EOF'
name: Rust API CI/CD

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: linux-amd64
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Build Docker image
        run: |
          docker build -t rust-api:${{ github.sha }} .
          docker tag rust-api:${{ github.sha }} rust-api:latest
      
      - name: Push to registry
        run: |
          docker push localhost:5000/rust-api:${{ github.sha }}
          docker push localhost:5000/rust-api:latest
      
      - name: Update deployment
        run: |
          echo "✅ Rust API built and pushed"
EOF

cat > README.md << 'EOF'
# Rust API

Cloud-Native Todo API built with Rust and Warp framework.

## Features
- RESTful API endpoints
- Health check endpoint
- Docker containerized
- Kubernetes ready

## Development
```bash
cargo run
```

## Docker
```bash
docker build -t rust-api .
docker run -p 8080:8080 rust-api
```
EOF

git add .
git commit -m "Initial Rust API repository setup"

echo "✅ Rust API repository created in /tmp/rust-api"

echo ""
echo "📋 Next steps:"
echo "1. Create 'cloud-native-infra' repository in Gitea"
echo "2. Create 'rust-api' repository in Gitea"
echo "3. Push both repositories"
echo "4. Update ArgoCD applications to use separate repos"
