# Discrete DNS records for each worker's private IPv4
resource "vultr_dns_record" "workers" {
  count  = var.worker_count
  domain = var.dns_zone
  name   = format("%s-worker%d", var.name, count.index)
  type   = "A"
  data   = lookup(vultr_instance.workers.*.networks[count.index], var.network_id)
  ttl    = 300
}

resource "vultr_dns_record" "ingress-a" {
  count  = var.worker_count
  domain = var.dns_zone
  name   = var.name
  type   = "A"
  data   = element(vultr_instance.workers.*.ipv4_address, count.index)
  ttl    = 300
}

resource "vultr_dns_record" "ingress-aaaa" {
  count  = var.worker_count
  domain = var.dns_zone
  name   = var.name
  type   = "AAAA"
  data   = element(vultr_instance.workers.*.ipv6_addresses[count.index], 0)
  ttl    = 300
}

# Worker instances
resource "vultr_instance" "workers" {
  count              = var.worker_count
  name               = "${var.name}-worker-${count.index}"
  hostname           = "${var.name}-worker-${count.index}"
  region_id          = var.region
  plan_id            = var.type
  os_id              = data.vultr_os.custom.id
  tag                = var.name
  firewall_group_id  = var.firewall_group_id
  user_data          = element(data.ct_config.container_linux_install_configs.*.rendered, count.index)
  startup_script_id  = var.startup_script_id
  private_networking = true
  network_ids        = [var.network_id]
  ipv6               = true
}

# Hack to make a list of values from a list of maps
data "template_file" "private_ipv4_addresses" {
  count    = length(var.worker_count)
  template = lookup(vultr_instance.workers.*.networks[count.index], var.network_id)
}

# Find the ID for installing a custom ISO
data "vultr_os" "custom" {
  filter {
    name   = "family"
    values = ["iso"]
  }
}
