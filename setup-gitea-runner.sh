#!/bin/bash

echo "🏃 Setting up Gitea runner with token..."

RUNNER_TOKEN="7A180TvcdasqJoB8coHpdA2d7a4aufmOk2LLA4EM"

# Create runner directory
mkdir -p /tmp/gitea-runner
cd /tmp/gitea-runner

# Download Gitea Act Runner
echo "📥 Downloading Gitea Act Runner..."
wget -q https://dl.gitea.com/act_runner/0.2.6/act_runner-0.2.6-linux-amd64 -O act_runner
chmod +x act_runner

# Register runner
echo "🔧 Registering runner with Gitea..."
echo -e "http://gitea.local:8888\n$RUNNER_TOKEN\ncloud-native-runner\nlinux-amd64:host" | ./act_runner register --no-interactive

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

# Start runner in background
echo "🚀 Starting Gitea runner daemon..."
nohup ./act_runner daemon --config config.yaml > runner.log 2>&1 &
RUNNER_PID=$!

echo "✅ Gitea runner setup complete!"
echo ""
echo "📋 Runner details:"
echo "- Name: cloud-native-runner"
echo "- Labels: linux-amd64:host"
echo "- Token: $RUNNER_TOKEN"
echo "- PID: $RUNNER_PID"
echo "- Log: /tmp/gitea-runner/runner.log"
echo ""
echo "🔍 Check runner status:"
echo "ps aux | grep act_runner"
echo "tail -f /tmp/gitea-runner/runner.log"
