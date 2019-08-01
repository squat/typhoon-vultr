output "ingress_dns_name" {
  value       = "${vultr_dns_record.ingress-a.0.name}.${var.dns_zone}"
  description = "DNS name for distributing traffic to Ingress controllers"
}

output "public_ipv4_addresses" {
  value       = vultr_instance.workers.*.ipv4_address
  description = "Public IPv4 addresses of the created workers"
}

output "private_ipv4_addresses" {
  value       = data.template_file.private_ipv4_addresses.*.rendered
  description = "Private IPv4 addresses of the created workers"
}
