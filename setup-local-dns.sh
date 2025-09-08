#!/bin/bash

# Setup local DNS for offline cloud-native gauntlet
# This script adds entries to /etc/hosts for local development

echo "Setting up local DNS for Cloud-Native Gauntlet..."

# Backup existing hosts file
sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d_%H%M%S)

# Add entries for local services
sudo tee -a /etc/hosts << EOF

# Cloud-Native Gauntlet Local Services
192.168.56.10    k3s-master.local
192.168.56.11    k3s-worker.local
192.168.56.10    keycloak.local
192.168.56.10    gitea.local
192.168.56.10    registry.local
192.168.56.10    api.local
EOF

echo "Local DNS setup complete!"
echo "Added entries for:"
echo "  - k3s-master.local -> 192.168.56.10"
echo "  - k3s-worker.local -> 192.168.56.11"
echo "  - keycloak.local -> 192.168.56.10"
echo "  - gitea.local -> 192.168.56.10"
echo "  - registry.local -> 192.168.56.10"
echo "  - api.local -> 192.168.56.10"
echo ""
echo "You can now access services at:"
echo "  - Keycloak: https://keycloak.local"
echo "  - Gitea: http://gitea.local"
echo "  - Registry: http://registry.local:5000"
echo "  - API: http://api.local"
