#!/bin/bash

# Cloud-Native Gauntlet Docker Cleanup Script
# This script cleans up the Docker infrastructure

set -e

echo "🧹 Cleaning up Cloud-Native Gauntlet Docker Infrastructure"
echo "=========================================================="

# Stop and remove containers
cleanup_containers() {
    echo "🐳 Stopping and removing containers..."
    docker-compose -f docker-compose-infra.yaml down -v
    echo "✅ Containers cleaned up!"
}

# Clean up local files
cleanup_files() {
    echo "📁 Cleaning up local files..."
    
    # Remove kubeconfig
    rm -rf k3s-config/
    
    # Remove any temporary files
    rm -f *.log
    
    echo "✅ Local files cleaned up!"
}

# Restore hosts file
restore_hosts() {
    echo "🌐 Restoring hosts file..."
    
    # Remove our entries from /etc/hosts
    sudo sed -i '/# Cloud-Native Gauntlet Local Services/,+5d' /etc/hosts
    
    echo "✅ Hosts file restored!"
}

# Main execution
main() {
    read -p "Are you sure you want to clean up everything? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        exit 0
    fi
    
    cleanup_containers
    cleanup_files
    restore_hosts
    
    echo ""
    echo "🎉 Cleanup complete!"
    echo "=========================================================="
    echo "You can now run ./setup-docker-infra.sh for a fresh start."
}

# Run main function
main "$@"
