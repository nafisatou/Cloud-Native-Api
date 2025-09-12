#!/bin/bash

# Cloud-Native Gauntlet - Port Forwarding Script
# This script sets up persistent port forwarding for all services

echo "🚀 Starting Cloud-Native Gauntlet Port Forwarding..."

# Function to start port forwarding in background with nohup
start_forwarding() {
    local service=$1
    local namespace=$2
    local local_port=$3
    local remote_port=$4
    local log_file="/tmp/port-forward-${service}.log"
    
    echo "Starting port forwarding for $service on port $local_port..."
    nohup kubectl port-forward -n $namespace service/$service $local_port:$remote_port > $log_file 2>&1 &
    echo "Port forwarding for $service started (PID: $!) - logs: $log_file"
}

# Kill existing port forwarding processes
echo "Stopping existing port forwarding processes..."
pkill -f "kubectl port-forward" || true
sleep 2

# Start all port forwarding services
start_forwarding "argocd-server" "argocd" "30080" "80"
start_forwarding "web" "linkerd-viz" "30002" "8084"  
start_forwarding "rust-api-nodeport" "cloud-native-gauntlet" "8081" "8081"

echo ""
echo "✅ Port forwarding setup complete!"
echo ""
echo "🌐 Access your services at:"
echo "  • ArgoCD Dashboard: http://localhost:30080"
echo "  • Linkerd Viz: http://localhost:30002"
echo "  • Keycloak: http://localhost:8080 (Docker)"
echo "  • Gitea: http://localhost:3000 (Docker)"
echo "  • Rust API: http://localhost:8081"
echo ""
echo "📋 To stop all port forwarding: ./scripts/stop-port-forwarding.sh"
echo "📋 To check status: ./scripts/check-port-forwarding.sh"
