module "workers" {
  source = "./workers"
  name   = "${var.cluster_name}"

  # Vultr
  region            = "${var.region}"
  dns_zone          = "${var.dns_zone}"
  network_id        = "${vultr_network.cluster.id}"
  firewall_group_id = "${vultr_firewall_group.cluster.id}"
  count             = "${var.worker_count}"
  type              = "${var.worker_type}"
  os_image          = "${var.os_image}"
  startup_script_id = "${vultr_startup_script.ipxe.id}"

  # configuration
  kubeconfig            = "${module.bootkube.kubeconfig-kubelet}"
  ssh_authorized_key    = "${var.ssh_authorized_key}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  clc_snippets          = "${var.worker_clc_snippets}"
}
