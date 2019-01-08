output "kubeconfig-admin" {
  value = "${module.bootkube.user-kubeconfig}"
}

output "ingress_dns_name" {
  value       = "${module.workers.ingress_dns_name}"
  description = "DNS name for distributing traffic to Ingress controllers"
}

output "kubeconfig" {
  value       = "${module.bootkube.kubeconfig}"
  description = "Cluster Kubeconfig"
}

output "firewall_group_id" {
  value       = "${vultr_firewall_group.cluster.id}"
  description = "Firewall group ID of the cluster"
}

output "network_id" {
  value       = "${vultr_network.cluster.id}"
  description = "Network ID of the cluster"
}

output "startup_script_id" {
  value       = "${vultr_startup_script.ipxe.id}"
  description = "Startup Script ID of the cluster"
}
