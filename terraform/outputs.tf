output "service_urls" {
  description = "URLs for accessing services"
  value = {
    argocd   = "http://argocd.local"
    gitea    = "http://gitea.local"
    keycloak = "http://keycloak.local"
    linkerd  = "http://linkerd.local"
    api      = "http://api.local"
  }
}

output "ingress_ip" {
  description = "Ingress controller IP address"
  value = "127.0.0.1"
}
