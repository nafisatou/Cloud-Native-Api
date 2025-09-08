# Cloud-Native Gauntlet 🚀

A complete cloud-native application stack built from scratch, running entirely offline on local VMs. This project demonstrates modern cloud-native practices including Kubernetes, service mesh, GitOps, and more.

## 🎯 Project Overview

Build a full-stack cloud-native application with:
- **Rust API** with JWT authentication and PostgreSQL
- **K3s cluster** on local VMs (Vagrant)
- **CloudNativePG** for database management
- **Keycloak** for authentication
- **Gitea** for GitOps
- **Linkerd** service mesh
- **Complete offline operation**

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Master VM     │    │   Worker VM     │
│   (192.168.56.10)│    │   (192.168.56.11)│
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ K3s Master  │ │    │ │ K3s Worker  │ │
│ │ Keycloak    │ │    │ │ App Pods    │ │
│ │ Gitea       │ │    │ │ DB Pods     │ │
│ │ Registry    │ │    │ │             │ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Vagrant** (for VM management)
- **VirtualBox** (VM provider)
- **Ansible** (for automation)
- **4GB+ RAM** available for VMs

### Day 1-2: Infrastructure Setup

1. **Start the infrastructure:**
   ```bash
   ./setup-infrastructure.sh
   ```

2. **Verify the setup:**
   ```bash
   export KUBECONFIG=$(pwd)/k3s.yaml
   kubectl get nodes
   ```

3. **Test local registry:**
   ```bash
   curl http://registry.local:5000/v2/_catalog
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
├── ansible/                 # Infrastructure automation
│   ├── inventory.ini       # VM inventory
│   └── site.yml           # K3s installation
├── app/rust-api/          # Rust application
│   ├── src/               # Source code
│   ├── infra/k8s/         # Kubernetes manifests
│   └── offline-images/    # Pre-pulled images
├── docs/                  # Documentation
├── registry/              # Local registry data
├── Vagrantfile           # VM configuration
├── setup-infrastructure.sh # Main setup script
├── setup-local-dns.sh    # DNS configuration
└── cleanup.sh            # Cleanup script
```

## 🔧 Available Scripts

- **`./setup-infrastructure.sh`** - Complete infrastructure setup
- **`./setup-local-dns.sh`** - Configure local DNS
- **`./cleanup.sh`** - Clean up everything for fresh start

## 🌐 Local Access Points

- **Keycloak**: https://keycloak.local
- **Gitea**: http://gitea.local
- **Registry**: http://registry.local:5000
- **API**: http://api.local
- **K3s Master**: vagrant ssh master
- **K3s Worker**: vagrant ssh worker

## 🎯 Victory Conditions

- ✅ **Offline Runtime**: Everything runs without internet
- ✅ **Idempotence**: Scripts can run multiple times safely
- ✅ **GitOps**: Automated deployment pipeline
- ✅ **Security**: Keycloak protects the application
- ✅ **Service Mesh**: Linkerd provides observability and mTLS
- ✅ **Documentation**: Complete with Mermaid diagrams

## 🆘 Troubleshooting

### VMs won't start
```bash
# Check VirtualBox status
VBoxManage list runningvms

# Restart VirtualBox service
sudo systemctl restart vboxdrv
```

### K3s cluster issues
```bash
# Check cluster status
kubectl get nodes

# Restart K3s on master
vagrant ssh master -c "sudo systemctl restart k3s"
```

### Registry issues
```bash
# Check registry status
vagrant ssh master -c "docker ps | grep registry"

# Restart registry
vagrant ssh master -c "docker restart registry"
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

---

**Ready to begin your Cloud-Native Gauntlet journey?** 🚀

Run `./setup-infrastructure.sh` to start!
