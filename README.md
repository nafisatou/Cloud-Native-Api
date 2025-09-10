# Cloud-Native Gauntlet 🚀

A complete cloud-native application stack built from scratch, runnable entirely offline using Docker and a local Kubernetes cluster. This project demonstrates modern cloud-native practices including Kubernetes, service mesh, GitOps, and more.

## 🎯 Project Overview

Build a full-stack cloud-native application with:
- **Rust API** with JWT authentication and PostgreSQL
- **Kubernetes (kind)** local cluster
- **CloudNativePG** for database management
- **Keycloak** for authentication
- **Gitea** for GitOps
- **Linkerd** service mesh
- **Argo CD** for GitOps UI
- **Complete offline operation**

## 🏗️ Architecture

```
┌────────────────────────────────────────────┐
│                 Docker Host                │
│ ┌────────────────────────────────────────┐ │
│ │  kind cluster (control-plane container)│ │
│ │  - App pods (Rust API, Postgres)       │ │
│ │  - Linkerd + Linkerd Viz               │ │
│ │  - Argo CD                             │ │
│ └────────────────────────────────────────┘ │
│ ┌──────────────┐  ┌───────────┐  ┌──────┐ │
│ │  Keycloak    │  │  Gitea    │  │ Reg. │ │
│ │  (8082)      │  │  (3000)   │  │5000  │ │
│ └──────────────┘  └───────────┘  └──────┘ │
└────────────────────────────────────────────┘
```

```mermaid
flowchart TB
  subgraph Docker_Host
    subgraph kind_cluster
      API[(Rust API Pods)] -->|TCP 5432| PG[(Postgres Pod)]
      API -->|mTLS| Linkerd[Linkerd Control Plane]
      Linkerd --> Viz[Linkerd Viz]
      Argo[Argo CD]
    end
    Keycloak[(Keycloak Container)]
    Gitea[(Gitea Container)]
    Registry[(Local Registry :5000)]
  end

  Gitea <-. GitOps .-> Argo
  Registry -->|pull/push| API
  Registry --> Keycloak
  Registry --> Gitea
  Registry --> PG
```

## 🚀 Quick Start

### Prerequisites

- **Docker**
- **kubectl**
- **kind** (Kubernetes in Docker)
- 4GB+ RAM available

### Bring up local services

1. **Start infrastructure containers:**
   ```bash
   docker compose -f docker-compose-infra.yaml up -d
   ```

2. **Start app stack (DB + API):**
   ```bash
   docker compose up -d
   ```

3. **Verify containers:**
   ```bash
   docker ps --format '{{.Names}}\t{{.Status}}\t{{.Ports}}'
   ```

4. **Connect kubectl to kind cluster:**
   ```bash
   # one-time: extract and rewrite kubeconfig to host port
   docker inspect cloud-native-gauntlet-control-plane --format '{{json .NetworkSettings.Ports}}' | jq -r '.["6443/tcp"][0].HostPort'
   # assume it prints e.g. 37167; then set KUBECONFIG to kind-kubeconfig-local.yaml if present
   export KUBECONFIG=$(pwd)/kind-kubeconfig-local.yaml
   kubectl get ns
   ```

5. **(Optional) Keep UIs reachable:**
   ```bash
   # Argo CD UI → http://localhost:30080
   kubectl -n argocd port-forward svc/argocd-server 30080:80 &
   # Linkerd Viz UI → http://localhost:30001
   kubectl -n linkerd-viz port-forward svc/web 30001:8084 &
   ```

### Day 3-4: Application Development

The Rust API is already implemented with:
- Actix-web framework
- JWT authentication
- PostgreSQL integration
- Basic task management endpoints

### Day 5: Containerization

Build and push your application:
```bash
cd app/rust-api
docker build -t localhost:5000/rust-api:latest .
docker push localhost:5000/rust-api:latest
```

### Day 6-7: Database & Deployment

Deploy CloudNativePG and your application:
```bash
kubectl apply -f app/rust-api/cnpg-operator.yaml
kubectl apply -f app/rust-api/postgres-cluster.yaml
kubectl apply -f app/rust-api/infra/k8s/
```

## 📁 Project Structure

```
cloud-native-gauntlet/
├── app/rust-api/          # Rust application
│   ├── src/               # Source code
│   ├── k8s/               # Kubernetes manifests
│   ├── infra/             # Infrastructure configs
│   ├── Dockerfile         # Container build file
│   └── Cargo.toml         # Rust dependencies
├── docs/                  # Documentation
├── registry/              # Local registry data
├── docker-compose.yaml    # App services (DB + API)
├── setup-local-dns.sh    # DNS configuration
└── cleanup.sh            # Cleanup script
```

## 🔧 Available Scripts

- **`./setup-local-dns.sh`** - Configure local DNS
- **`./cleanup.sh`** - Clean up everything for fresh start

## 🌐 Local Access Points

- **Keycloak**: http://localhost:8082
- **Gitea**: http://localhost:3000
- **Registry API**: http://localhost:5000/v2/_catalog
- **Rust API (health)**: http://localhost:8081/health
- **Argo CD UI**: http://localhost:30080
- **Linkerd Viz UI**: http://localhost:30001

## ✅ Offline Validation

Use these steps to prove the stack runs without internet:

1. Pre-requisites (already done here):
   - Images mirrored to `localhost:5000`
   - kind node preloaded with required images
   - Manifests use `localhost:5000/...` and `imagePullPolicy: IfNotPresent`

2. Disable internet on your host (Wi‑Fi/Ethernet off).

3. Restart key workloads and wait for Ready:
```bash
KUBECONFIG=$(pwd)/kind-kubeconfig-local.yaml kubectl -n cloud-native-gauntlet \
  rollout restart deploy/postgres deploy/rust-api && \
KUBECONFIG=$(pwd)/kind-kubeconfig-local.yaml kubectl -n cloud-native-gauntlet \
  rollout status deploy/postgres --timeout=180s && \
KUBECONFIG=$(pwd)/kind-kubeconfig-local.yaml kubectl -n cloud-native-gauntlet \
  rollout status deploy/rust-api --timeout=180s
```

4. Verify endpoints (expect 200/307):
```bash
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3000
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8082
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8081/health
curl -s http://localhost:5000/v2/_catalog | jq
```

5. Confirm no external pulls:
```bash
KUBECONFIG=$(pwd)/kind-kubeconfig-local.yaml \
kubectl -n cloud-native-gauntlet get events --sort-by=.lastTimestamp | \
  egrep -i 'pull|image|backoff' || echo "no pull events"
```

## 🎯 Victory Conditions

- ✅ **Offline Runtime**: Everything runs without internet
- ✅ **Idempotence**: Scripts can run multiple times safely
- ✅ **GitOps**: Automated deployment pipeline
- ✅ **Security**: Keycloak protects the application
- ✅ **Service Mesh**: Linkerd provides observability and mTLS
- ✅ **Documentation**: Complete with Mermaid diagrams

## 🆘 Troubleshooting

### Containers / cluster status
```bash
docker ps --format '{{.Names}}\t{{.Status}}\t{{.Ports}}'
kubectl get pods -A
```

### Common issues
```bash
# API container health failing
docker logs cloud-native-gauntlet-api-1 | tail -n 200

# Keycloak or Gitea
docker logs keycloak | tail -n 200
docker logs gitea | tail -n 200

# Port-forward not reachable
pkill -f 'port-forward.*argocd-server' || true
pkill -f 'port-forward.*linkerd-viz' || true
```

## 📚 Next Steps

1. **Day 1-2**: Complete infrastructure setup ✅
2. **Day 3-4**: Enhance Rust application
3. **Day 5**: Containerize application
4. **Day 6-7**: Deploy to Kubernetes
5. **Day 8**: Integrate Keycloak
6. **Day 9-10**: Set up GitOps
7. **Day 11**: Deploy Linkerd
8. **Day 12**: Documentation and testing

### Day 12: Documentation and Testing

- Updated README with:
  - Offline Validation steps (no internet required)
  - Local endpoints and start instructions
  - Architecture diagram and Mermaid graph
- Start script: `./start-local.sh` boots stacks and port-forwards (30001/30080)
- Validate offline:
  - Mirror images to `localhost:5000`, preload into kind
  - Restart `rust-api` and `postgres`; ensure endpoints return 200/307
  - Confirm no image pull/backoff events in `kubectl get events`

---

**Ready to begin your Cloud-Native Gauntlet journey?** 🚀

Run `./setup-infrastructure.sh` to start!
