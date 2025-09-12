#!/bin/bash

# Cloud-Native Gauntlet - Stop Port Forwarding Script

echo "🛑 Stopping all port forwarding processes..."

# Kill all kubectl port-forward processes
pkill -f "kubectl port-forward"

# Clean up log files
rm -f /tmp/port-forward-*.log

echo "✅ All port forwarding processes stopped."
