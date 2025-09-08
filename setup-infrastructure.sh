#!/bin/bash

# Cloud-Native Gauntlet Infrastructure Setup Script
# This script sets up the complete infrastructure for the project

set -e

echo "🚀 Starting Cloud-Native Gauntlet Infrastructure Setup"
echo "=================================================="

# Check if required tools are installed
check_requirements() {
    echo "📋 Checking requirements..."
    
    if ! command -v vagrant &> /dev/null; then
        echo "❌ Vagrant is not installed. Please install Vagrant first."
        exit 1
    fi
    
    if ! command -v ansible &> /dev/null; then
        echo "❌ Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    
    if ! command -v virtualbox &> /dev/null; then
        echo "❌ VirtualBox is not installed. Please install VirtualBox first."
        exit 1
    fi
    
    echo "✅ All requirements met!"
}

# Start VMs
start_vms() {
    echo "🖥️  Starting VMs..."
    vagrant up
    echo "✅ VMs started successfully!"
}

# Setup local DNS
setup_dns() {
    echo "🌐 Setting up local DNS..."
    ./setup-local-dns.sh
    echo "✅ Local DNS configured!"
}

# Install K3s cluster
install_k3s() {
    echo "☸️  Installing K3s cluster..."
    ansible-playbook -i ansible/inventory.ini ansible/site.yml
    echo "✅ K3s cluster installed!"
}

# Configure kubectl
configure_kubectl() {
    echo "🔧 Configuring kubectl..."
    
    # Update kubeconfig with correct server IP
    sed -i 's/127.0.0.1/192.168.56.10/g' k3s.yaml
    
    # Set KUBECONFIG environment variable
    export KUBECONFIG=$(pwd)/k3s.yaml
    
    # Test cluster connectivity
    kubectl get nodes
    echo "✅ kubectl configured and cluster is accessible!"
}

# Verify setup
verify_setup() {
    echo "🔍 Verifying setup..."
    
    # Check if nodes are ready
    kubectl get nodes
    
    # Check if local registry is running
    vagrant ssh master -c "docker ps | grep registry"
    
    # Check if images are available
    vagrant ssh master -c "docker images | grep localhost:5000"
    
    echo "✅ Setup verification complete!"
}

# Main execution
main() {
    check_requirements
    start_vms
    setup_dns
    install_k3s
    configure_kubectl
    verify_setup
    
    echo ""
    echo "🎉 Infrastructure setup complete!"
    echo "=================================================="
    echo "Your Cloud-Native Gauntlet infrastructure is ready!"
    echo ""
    echo "Next steps:"
    echo "1. Test cluster: kubectl get nodes"
    echo "2. Check registry: curl http://registry.local:5000/v2/_catalog"
    echo "3. Proceed to Day 3-4: Application development"
    echo ""
    echo "Access points:"
    echo "- Master node: vagrant ssh master"
    echo "- Worker node: vagrant ssh worker"
    echo "- Kubeconfig: export KUBECONFIG=\$(pwd)/k3s.yaml"
}

# Run main function
main "$@"
