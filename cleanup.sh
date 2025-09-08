#!/bin/bash

# Cloud-Native Gauntlet Cleanup Script
# This script cleans up the infrastructure for a fresh start

set -e

echo "🧹 Cleaning up Cloud-Native Gauntlet Infrastructure"
echo "=================================================="

# Stop and destroy VMs
cleanup_vms() {
    echo "🖥️  Stopping and destroying VMs..."
    vagrant destroy -f
    echo "✅ VMs cleaned up!"
}

# Clean up local files
cleanup_files() {
    echo "📁 Cleaning up local files..."
    
    # Remove kubeconfig
    rm -f k3s.yaml
    
    # Remove Vagrant files
    rm -rf .vagrant/
    
    # Remove any temporary files
    rm -f *.log
    
    echo "✅ Local files cleaned up!"
}

# Restore hosts file
restore_hosts() {
    echo "🌐 Restoring hosts file..."
    
    # Find the most recent backup
    LATEST_BACKUP=$(ls -t /etc/hosts.backup.* 2>/dev/null | head -n1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        sudo cp "$LATEST_BACKUP" /etc/hosts
        echo "✅ Hosts file restored from $LATEST_BACKUP"
    else
        echo "⚠️  No hosts backup found. You may need to manually clean /etc/hosts"
    fi
}

# Main execution
main() {
    read -p "Are you sure you want to clean up everything? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        exit 0
    fi
    
    cleanup_vms
    cleanup_files
    restore_hosts
    
    echo ""
    echo "🎉 Cleanup complete!"
    echo "=================================================="
    echo "You can now run ./setup-infrastructure.sh for a fresh start."
}

# Run main function
main "$@"
