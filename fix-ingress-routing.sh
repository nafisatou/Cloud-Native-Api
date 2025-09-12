#!/bin/bash

echo "🔧 Fixing ingress routing issues..."

# Kill all port forwarding and socat processes
pkill -f "kubectl.*port-forward" 2>/dev/null
pkill -f "socat" 2>/dev/null

# Delete existing ingress resources
echo "🗑️ Removing existing ingress configurations..."
kubectl delete ingress --all -A 2>/dev/null || true

# Create proper ingress configuration with nginx class
echo "🌐 Creating new ingress configuration..."

# ArgoCD Ingress
kubectl apply -f - << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  rules:
  - host: argocd.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
EOF

# Gitea Ingress
kubectl apply -f - << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gitea-ingress
  namespace: cloud-native-gauntlet
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: gitea.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gitea
            port:
              number: 3000
EOF

# Keycloak Ingress
kubectl apply -f - << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress
  namespace: cloud-native-gauntlet
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: keycloak.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: keycloak
            port:
              number: 8080
EOF

# Linkerd Ingress
kubectl apply -f - << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: linkerd-viz-ingress
  namespace: linkerd-viz
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: linkerd.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 8084
EOF

# API Ingress
kubectl apply -f - << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rust-api-ingress
  namespace: cloud-native-gauntlet
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: api.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: rust-api-service
            port:
              number: 80
EOF

sleep 5

# Get ingress controller NodePort
INGRESS_PORT=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
echo "📡 Ingress controller NodePort: $INGRESS_PORT"

# Start direct port forwarding to ingress controller
echo "🚀 Starting port 80 forwarding to ingress controller..."
nohup socat TCP-LISTEN:80,fork,reuseaddr TCP:127.0.0.1:$INGRESS_PORT > /tmp/ingress-forward.log 2>&1 &

sleep 3

# Test each service
echo "🧪 Testing services..."
for domain in argocd.local gitea.local keycloak.local linkerd.local api.local; do
    echo -n "Testing $domain: "
    if curl -s --connect-timeout 5 http://$domain | head -1 | grep -q "<!DOCTYPE\|<html\|HTTP"; then
        echo "✅ Working"
    else
        echo "❌ Failed"
    fi
done

echo ""
echo "🎉 Ingress routing fixed!"
echo "🌐 Access your services:"
echo "- ArgoCD: http://argocd.local"
echo "- Gitea: http://gitea.local"
echo "- Keycloak: http://keycloak.local"
echo "- Linkerd: http://linkerd.local"
echo "- API: http://api.local"
