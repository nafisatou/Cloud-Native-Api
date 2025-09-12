#!/bin/bash

echo "🏃 Setting up Gitea runner with token..."

RUNNER_TOKEN="A3WkeQbiRj0Lkwh5LvGXB27ks8bdex4zmUiP3o7y"

# Create runner directory
mkdir -p /tmp/gitea-runner
cd /tmp/gitea-runner

# Download Gitea Act Runner
echo "📥 Downloading Gitea Act Runner..."
wget -q https://dl.gitea.com/act_runner/0.2.6/act_runner-0.2.6-linux-amd64 -O act_runner
chmod +x act_runner

# Register runner
echo "🔧 Registering runner with Gitea..."
./act_runner register \
  --instance http://gitea.local:8888 \
  --token "$RUNNER_TOKEN" \
  --name "cloud-native-runner" \
  --labels "linux-amd64:host"

# Create runner config
cat > config.yaml << 'EOF'
log:
  level: info

runner:
  file: .runner
  capacity: 1
  timeout: 3h
  insecure: false
  fetch_timeout: 5s
  fetch_interval: 2s

cache:
  enabled: true
  dir: ""
  host: ""
  port: 0

container:
  network: ""
  privileged: false
  options: ""
  workdir_parent: ""
  valid_volumes: []
  docker_host: ""
  force_pull: false

host:
  workdir_parent: /tmp/gitea-runner-work
EOF

# Create systemd service
sudo tee /etc/systemd/system/gitea-runner.service > /dev/null << EOF
[Unit]
Description=Gitea Actions Runner
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/tmp/gitea-runner
ExecStart=/tmp/gitea-runner/act_runner daemon --config config.yaml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Start runner service
echo "🚀 Starting Gitea runner service..."
sudo systemctl daemon-reload
sudo systemctl enable gitea-runner
sudo systemctl start gitea-runner

echo "✅ Gitea runner setup complete!"
echo ""
echo "📋 Runner details:"
echo "- Name: cloud-native-runner"
echo "- Labels: linux-amd64:host"
echo "- Token: $RUNNER_TOKEN"
echo "- Status: $(sudo systemctl is-active gitea-runner)"
echo ""
echo "🔍 Check runner status:"
echo "sudo systemctl status gitea-runner"
