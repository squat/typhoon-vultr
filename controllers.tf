# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "vultr_dns_record" "etcds" {
  count  = var.controller_count
  domain = var.dns_zone
  name   = format("%s-etcd%d", var.cluster_name, count.index)
  type   = "A"
  data   = lookup(vultr_instance.controllers.*.networks[count.index], vultr_network.cluster.id)
  ttl    = 300
}

# Discrete DNS records for each controller's private IPv4 for cluster usage
resource "vultr_dns_record" "controllers" {
  count  = var.controller_count
  domain = var.dns_zone
  name   = format("%s-controller%d", var.cluster_name, count.index)
  type   = "A"
  data   = lookup(vultr_instance.controllers.*.networks[count.index], vultr_network.cluster.id)
  ttl    = 300
}

resource "vultr_dns_record" "apiserver-a" {
  count  = var.controller_count
  domain = var.dns_zone
  name   = format("%s-api", var.cluster_name)
  type   = "A"
  data   = element(vultr_instance.controllers.*.ipv4_address, count.index)
  ttl    = 300
}

resource "vultr_dns_record" "apiserver-aaaa" {
  count  = var.controller_count
  domain = var.dns_zone
  name   = format("%s-api", var.cluster_name)
  type   = "AAAA"
  data   = element(vultr_instance.controllers.*.ipv6_addresses[count.index], 0)
  ttl    = 300
}

# Controller instances
resource "vultr_instance" "controllers" {
  count              = var.controller_count
  name               = format("%s-controller-%s", var.cluster_name, count.index)
  hostname           = format("%s-controller-%s", var.cluster_name, count.index)
  region_id          = var.region
  plan_id            = var.controller_type
  os_id              = data.vultr_os.custom.id
  tag                = var.cluster_name
  firewall_group_id  = vultr_firewall_group.cluster.id
  user_data          = element(data.ct_config.controller_container_linux_install_configs.*.rendered, count.index)
  startup_script_id  = vultr_startup_script.ipxe.id
  private_networking = true
  network_ids        = [vultr_network.cluster.id]
  ipv6               = true
}

# Find the ID for installing a custom ISO
data "vultr_os" "custom" {
  filter {
    name   = "family"
    values = ["iso"]
  }
}
