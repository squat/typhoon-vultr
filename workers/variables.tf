variable "name" {
  type        = string
  description = "Unique name for the worker pool"
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

variable "network_id" {
  type        = string
  description = "Must be set to `network_id` output by cluster"
}

variable "firewall_group_id" {
  type        = string
  description = "Must be set to `firewall_group_id` output by cluster"
}

variable "startup_script_id" {
  type        = string
  description = "Must be set to `startup_script_id` output by cluster"
}

# instances

variable "worker_count" {
  type        = string
  default     = "1"
  description = "Number of instances"
}

variable "type" {
  type        = string
  description = "Vultr plan ID for workers"
}

variable "os_image" {
  type        = string
  default     = "coreos-stable"
  description = "AMI channel for a Container Linux derivative (coreos-stable, coreos-beta, coreos-alpha, flatcar-stable, flatcar-beta, flatcar-alpha)"
}

variable "clc_snippets" {
  type        = list(string)
  description = "Container Linux Config snippets"
  default     = []
}

# configuration

variable "kubeconfig" {
  type        = string
  description = "Must be set to `kubeconfig` output by cluster"
}

variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key for user 'core'"
}

variable "service_cidr" {
  type    = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD

  default = "10.3.0.0/16"
}

variable "cluster_domain_suffix" {
  type        = string
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  default     = "cluster.local"
}

variable "install_disk" {
  type        = string
  default     = "/dev/vda"
  description = "Disk device to which the install profiles should install Container Linux (e.g. /dev/sda)"
}
