# Discrete DNS records for each worker's private IPv4
resource "vultr_dns_record" "workers" {
  count  = "${var.worker_count}"
  domain = "${var.dns_zone}"
  name   = "${format("%s-worker%d", var.cluster_name, count.index)}"
  type   = "A"
  data   = "${lookup(vultr_instance.workers.*.networks[count.index], vultr_network.cluster.id)}"
  ttl    = 300
}

resource "vultr_dns_record" "ingress" {
  count  = "${var.worker_count}"
  domain = "${var.dns_zone}"
  name   = "${var.cluster_name}"
  type   = "A"
  data   = "${element(vultr_instance.workers.*.ipv4_address, count.index)}"
  ttl    = 300
}

# Controller instances
resource "vultr_instance" "workers" {
  count              = "${var.worker_count}"
  name               = "${var.cluster_name}-worker-${count.index}"
  hostname           = "${var.cluster_name}-worker-${count.index}"
  region_id          = "${var.region}"
  plan_id            = "${var.worker_type}"
  os_id              = "${data.vultr_os.custom.id}"
  tag                = "${var.cluster_name}"
  firewall_group_id  = "${vultr_firewall_group.cluster.id}"
  user_data          = "${element(data.ct_config.container-linux-install-configs.*.rendered, var.controller_count + count.index)}"
  startup_script_id  = "${vultr_startup_script.ipxe.id}"
  private_networking = true
  network_ids        = ["${vultr_network.cluster.id}"]
}
