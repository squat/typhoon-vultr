variable "cluster_name" {
  type        = string
  description = "Unique cluster name"
}

# Vultr

variable "region" {
  type        = string
  description = "Vultr region ID (e.g. 1, see `curl https://api.vultr.com/v1/regions/list`)"
}

variable "dns_zone" {
  type        = string
  description = "Vultr DNS Zone (e.g. vultr.example.com)"
}

# instances

variable "controller_count" {
  type        = string
  default     = "1"
  description = "Number of controllers (i.e. masters)"
}

variable "worker_count" {
  type        = string
  default     = "1"
  description = "Number of workers"
}

variable "controller_type" {
  type        = string
  description = "Vultr plan ID for controllers"
}

variable "worker_type" {
  type        = string
  description = "Vultr plan ID for workers"
}

variable "os_image" {
  type        = string
  default     = "coreos-stable"
  description = "Container Linux derivative image (coreos-stable, coreos-beta, coreos-alpha, flatcar-stable, flatcar-beta, flatcar-alpha, flatcar-edge)"
}

variable "controller_clc_snippets" {
  type        = list(string)
  description = "Controller Container Linux Config snippets"
  default     = []
}

variable "worker_clc_snippets" {
  type        = list(string)
  description = "Worker Container Linux Config snippets"
  default     = []
}

# configuration

variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key for user 'core'"
}

variable "asset_dir" {
  type        = string
  description = "Path to a directory where generated assets should be placed (contains secrets)"
}

variable "networking" {
  type        = string
  description = "Choice of networking provider (flannel or calico)"
  default     = "calico"
}

variable "network_ip_autodetection_method" {
  type        = string
  description = "Method to autodetect the host IPv4 address (applies to calico only)"
  default     = "first-found"
}

variable "pod_cidr" {
  type        = string
  description = "CIDR IPv4 range to assign Kubernetes pods"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  type        = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD

  default = "10.3.0.0/16"
}

# optional

variable "cluster_domain_suffix" {
  type = string
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local)"
  default = "cluster.local"
}

variable "download_protocol" {
  type = string
  default = "https"
  description = "Protocol iPXE should use to download the kernel and initrd. Defaults to https, which requires iPXE compiled with crypto support. Unused if cached_install is true."
}

variable "enable_reporting" {
  type = string
  description = "Enable usage or analytics reporting to upstreams (Calico)"
  default = "false"
}

variable "enable_aggregation" {
  type = string
  description = "Enable the Kubernetes Aggregation Layer (defaults to false)"
  default = "false"
}

variable "install_disk" {
  type = string
  default = "/dev/vda"
  description = "Disk device to which the install profiles should install Container Linux (e.g. /dev/sda)"
}

variable "kernel_args" {
  type = list(string)
  description = "Additional kernel arguments to provide at PXE boot"
  default = []
}
