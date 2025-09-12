#!/bin/bash

echo "🛑 Completely stopping Apache2 and freeing port 80..."

# Kill all Apache2 processes
pkill -f apache2
sleep 2

# Kill any remaining processes on port 80
fuser -k 80/tcp 2>/dev/null

# Disable Apache2 service (requires sudo, will show instructions if fails)
if command -v systemctl >/dev/null 2>&1; then
    echo "Attempting to disable Apache2 service..."
    sudo systemctl stop apache2 2>/dev/null || echo "Could not stop Apache2 service (needs sudo)"
    sudo systemctl disable apache2 2>/dev/null || echo "Could not disable Apache2 service (needs sudo)"
fi

# Verify port 80 is free
echo "🔍 Checking port 80 status..."
if netstat -tlnp | grep -q ":80 "; then
    echo "❌ Port 80 still in use:"
    netstat -tlnp | grep ":80 "
else
    echo "✅ Port 80 is free"
fi

echo "✅ Apache2 cleanup complete"
