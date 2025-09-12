#!/bin/bash

# Cloud-Native Gauntlet - Production Setup Script
# This script sets up the complete production environment with domain names

set -e

echo "🚀 Setting up Cloud-Native Gauntlet Production Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    command -v docker >/dev/null 2>&1 || { print_error "Docker is required but not installed."; exit 1; }
    command -v kubectl >/dev/null 2>&1 || { print_error "kubectl is required but not installed."; exit 1; }
    command -v kind >/dev/null 2>&1 || { print_error "kind is required but not installed."; exit 1; }
    command -v terraform >/dev/null 2>&1 || { print_error "Terraform is required but not installed."; exit 1; }
    
    print_status "All prerequisites are installed"
}

# Setup local DNS
setup_local_dns() {
    print_info "Setting up local DNS entries..."
    
    # Backup /etc/hosts
    sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d_%H%M%S)
    
    # Remove existing entries
    sudo sed -i '/# Cloud-Native Gauntlet/d' /etc/hosts
    sudo sed -i '/argocd.local/d' /etc/hosts
    sudo sed -i '/gitea.local/d' /etc/hosts
    sudo sed -i '/keycloak.local/d' /etc/hosts
    sudo sed -i '/linkerd.local/d' /etc/hosts
    sudo sed -i '/api.local/d' /etc/hosts
    
    # Add new entries
    echo "" | sudo tee -a /etc/hosts
    echo "# Cloud-Native Gauntlet - Local Development Domains" | sudo tee -a /etc/hosts
    echo "127.0.0.1 argocd.local" | sudo tee -a /etc/hosts
    echo "127.0.0.1 gitea.local" | sudo tee -a /etc/hosts
    echo "127.0.0.1 keycloak.local" | sudo tee -a /etc/hosts
    echo "127.0.0.1 linkerd.local" | sudo tee -a /etc/hosts
    echo "127.0.0.1 api.local" | sudo tee -a /etc/hosts
    
    print_status "Local DNS configured"
}

# Start infrastructure
start_infrastructure() {
    print_info "Starting infrastructure containers..."
    
    docker compose -f docker-compose-infra.yaml up -d
    docker compose up -d
    
    # Wait for containers to be ready
    print_info "Waiting for containers to be ready..."
    sleep 30
    
    print_status "Infrastructure containers started"
}

# Apply Terraform configuration
apply_terraform() {
    print_info "Applying Terraform configuration..."
    
    cd terraform
    terraform init
    terraform plan
    terraform apply -auto-approve
    cd ..
    
    print_status "Terraform configuration applied"
}

# Deploy ArgoCD applications
deploy_argocd_apps() {
    print_info "Deploying ArgoCD applications..."
    
    kubectl apply -f argocd/applications/
    
    # Wait for applications to sync
    print_info "Waiting for ArgoCD applications to sync..."
    sleep 60
    
    print_status "ArgoCD applications deployed"
}

# Stop port forwarding
stop_port_forwarding() {
    print_info "Stopping existing port forwarding..."
    ./scripts/stop-port-forwarding.sh || true
    print_status "Port forwarding stopped"
}

# Get ingress IP and configure
configure_ingress() {
    print_info "Configuring ingress controller..."
    
    # Wait for ingress controller to be ready
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    
    print_status "Ingress controller ready"
}

# Main execution
main() {
    echo "🎯 Cloud-Native Gauntlet Production Setup"
    echo "========================================="
    
    check_prerequisites
    setup_local_dns
    start_infrastructure
    stop_port_forwarding
    configure_ingress
    apply_terraform
    deploy_argocd_apps
    
    echo ""
    echo "🎉 Production Environment Setup Complete!"
    echo "=========================================="
    echo ""
    echo "🌐 Access your services at:"
    echo "  • ArgoCD Dashboard: http://argocd.local"
    echo "  • Gitea Repository: http://gitea.local"
    echo "  • Keycloak Auth: http://keycloak.local"
    echo "  • Linkerd Viz: http://linkerd.local"
    echo "  • Rust API: http://api.local"
    echo ""
    echo "🚀 GitOps Pipeline:"
    echo "  • Push to GitHub → GitHub Actions builds image"
    echo "  • ArgoCD automatically syncs deployments"
    echo "  • Check ArgoCD dashboard for deployment status"
    echo ""
    echo "📋 Next Steps:"
    echo "  1. Push your code to GitHub to trigger the CI/CD pipeline"
    echo "  2. Monitor deployments in ArgoCD at http://argocd.local"
    echo "  3. Access your API at http://api.local"
    echo ""
    print_status "Your Cloud-Native Gauntlet is production-ready! 🚀"
}

# Run main function
main "$@"
