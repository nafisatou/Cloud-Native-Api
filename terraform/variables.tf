variable "domain_suffix" {
  description = "Domain suffix for local services"
  type        = string
  default     = "local"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "cloud-native-gauntlet"
}

variable "rust_api_image" {
  description = "Rust API container image"
  type        = string
  default     = "localhost:5000/rust-api:latest"
}

variable "enable_tls" {
  description = "Enable TLS for ingress"
  type        = bool
  default     = false
}
