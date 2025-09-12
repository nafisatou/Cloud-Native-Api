terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "kubernetes" {
  config_path = "../kind-kubeconfig-local.yaml"
}

provider "helm" {
  kubernetes {
    config_path = "../kind-kubeconfig-local.yaml"
  }
}

# Ingress resources for domain-based routing
resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "false"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    rule {
      host = "argocd.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "gitea" {
  metadata {
    name      = "gitea-ingress"
    namespace = "cloud-native-gauntlet"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    rule {
      host = "gitea.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "gitea"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "keycloak" {
  metadata {
    name      = "keycloak-ingress"
    namespace = "cloud-native-gauntlet"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    rule {
      host = "keycloak.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "keycloak"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "linkerd_viz" {
  metadata {
    name      = "linkerd-viz-ingress"
    namespace = "linkerd-viz"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    rule {
      host = "linkerd.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "web"
              port {
                number = 8084
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "rust_api" {
  metadata {
    name      = "rust-api-ingress"
    namespace = "cloud-native-gauntlet"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    rule {
      host = "api.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "rust-api-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
