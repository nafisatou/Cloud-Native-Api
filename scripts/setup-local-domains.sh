#!/bin/bash

# Setup .local domains for cloud-native services
echo "🌐 Setting up .local domain access..."

# Backup current hosts file
sudo cp /etc/hosts /etc/hosts.backup

# Remove existing .local entries
sudo sed -i '/\.local/d' /etc/hosts

# Add all .local domains pointing to 127.0.0.1:30447
echo "127.0.0.1:30447 gitea.local keycloak.local argocd.local linkerd.local rust-api.local registry.local" | sudo tee -a /etc/hosts

echo "✅ Updated /etc/hosts with .local domains"
echo "📋 Services accessible at:"
echo "  - http://gitea.local"
echo "  - http://keycloak.local" 
echo "  - http://argocd.local"
echo "  - http://linkerd.local"
echo "  - http://rust-api.local"
echo "  - http://registry.local"
