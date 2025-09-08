#!/bin/bash

# Cloud-Native Gauntlet Docker Infrastructure Setup Script
# This script sets up the complete infrastructure using Docker containers

set -e

echo "🚀 Starting Cloud-Native Gauntlet Docker Infrastructure Setup"
echo "=============================================================="

# Check if Docker is running
check_docker() {
    echo "📋 Checking Docker..."
    
    if ! docker info >/dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker first."
        exit 1
    fi
    
    echo "✅ Docker is running!"
}

# Create necessary directories
setup_directories() {
    echo "📁 Creating directories..."
    mkdir -p k3s-config
    mkdir -p registry
    echo "✅ Directories created!"
}

# Start infrastructure services
start_infrastructure() {
    echo "🐳 Starting infrastructure services..."
    docker-compose -f docker-compose-infra.yaml up -d
    echo "✅ Infrastructure services started!"
}

# Wait for services to be ready
wait_for_services() {
    echo "⏳ Waiting for services to be ready..."
    
    # Wait for K3s master
    echo "Waiting for K3s master..."
    timeout 300 bash -c 'until docker exec k3s-master kubectl get nodes >/dev/null 2>&1; do sleep 5; done'
    
    # Wait for registry
    echo "Waiting for registry..."
    timeout 60 bash -c 'until curl -s http://localhost:5000/v2/_catalog >/dev/null 2>&1; do sleep 5; done'
    
    # Wait for PostgreSQL
    echo "Waiting for PostgreSQL..."
    timeout 60 bash -c 'until docker exec postgres-dev pg_isready -U admin >/dev/null 2>&1; do sleep 5; done'
    
    echo "✅ All services are ready!"
}

# Configure kubectl
configure_kubectl() {
    echo "🔧 Configuring kubectl..."
    
    # Copy kubeconfig from K3s master
    docker cp k3s-master:/output/kubeconfig.yaml ./k3s-config/kubeconfig.yaml
    
    # Update kubeconfig with correct server IP
    sed -i 's/127.0.0.1/localhost/g' ./k3s-config/kubeconfig.yaml
    
    # Set KUBECONFIG environment variable
    export KUBECONFIG=$(pwd)/k3s-config/kubeconfig.yaml
    
    # Test cluster connectivity
    kubectl get nodes
    echo "✅ kubectl configured and cluster is accessible!"
}

# Pre-pull essential images
prepull_images() {
    echo "📦 Pre-pulling essential images..."
    
    # Pull and tag images for local registry
    docker pull quay.io/keycloak/keycloak:22.0
    docker pull postgres:15
    docker pull gitea/gitea:1.21
    docker pull registry:2
    
    # Tag for local registry
    docker tag quay.io/keycloak/keycloak:22.0 localhost:5000/keycloak:22.0
    docker tag postgres:15 localhost:5000/postgres:15
    docker tag gitea/gitea:1.21 localhost:5000/gitea:1.21
    docker tag registry:2 localhost:5000/registry:2
    
    # Push to local registry
    docker push localhost:5000/keycloak:22.0
    docker push localhost:5000/postgres:15
    docker push localhost:5000/gitea:1.21
    docker push localhost:5000/registry:2
    
    echo "✅ Images pre-pulled and pushed to local registry!"
}

# Setup local DNS
setup_dns() {
    echo "🌐 Setting up local DNS..."
    
    # Add entries to /etc/hosts
    sudo tee -a /etc/hosts << EOF

# Cloud-Native Gauntlet Local Services
127.0.0.1    keycloak.local
127.0.0.1    gitea.local
127.0.0.1    registry.local
127.0.0.1    api.local
EOF
    
    echo "✅ Local DNS configured!"
}

# Verify setup
verify_setup() {
    echo "🔍 Verifying setup..."
    
    # Check if containers are running
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    # Check cluster status
    kubectl get nodes
    
    # Check registry
    curl -s http://localhost:5000/v2/_catalog | jq .
    
    echo "✅ Setup verification complete!"
}

# Main execution
main() {
    check_docker
    setup_directories
    start_infrastructure
    wait_for_services
    configure_kubectl
    prepull_images
    setup_dns
    verify_setup
    
    echo ""
    echo "🎉 Docker infrastructure setup complete!"
    echo "=============================================================="
    echo "Your Cloud-Native Gauntlet infrastructure is ready!"
    echo ""
    echo "Access points:"
    echo "- K3s cluster: kubectl get nodes"
    echo "- Registry: http://localhost:5000"
    echo "- Keycloak: http://localhost:8080"
    echo "- Gitea: http://localhost:3000"
    echo "- PostgreSQL: localhost:5432"
    echo ""
    echo "Next steps:"
    echo "1. Test cluster: kubectl get nodes"
    echo "2. Check registry: curl http://localhost:5000/v2/_catalog"
    echo "3. Proceed to Day 3-4: Application development"
}

# Run main function
main "$@"
