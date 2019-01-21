locals {
  # coreos-stable -> coreos flavor, stable channel
  # flatcar-stable -> flatcar flavor, stable channel
  flavor = "${element(split("-", var.os_image), 0)}"

  channel = "${element(split("-", var.os_image), 1)}"

  baseurl = "${local.flavor == "coreos" ? "http://${local.channel}.release.core-os.net/amd64-usr/current" : "http://${local.channel}.release.flatcar-linux.net/amd64-usr/current"}"
}

data "ct_config" "container_linux_install_configs" {
  count = "${var.count}"

  pretty_print = false
  content      = "${element(data.template_file.container_linux_install_configs.*.rendered, count.index)}"
}

data "template_file" "container_linux_install_configs" {
  count = "${var.count}"

  template = "${file("${path.module}/cl/install.yaml.tmpl")}"

  vars {
    os_flavor          = "${local.flavor}"
    os_channel         = "${local.channel}"
    ignition           = "${element(data.ct_config.worker_ignitions.*.rendered, count.index)}"
    install_disk       = "${var.install_disk}"
    ssh_authorized_key = "${var.ssh_authorized_key}"
  }
}

data "ct_config" "worker_ignitions" {
  count        = "${var.count}"
  content      = "${element(data.template_file.worker_configs.*.rendered, count.index)}"
  pretty_print = false
  snippets     = ["${var.clc_snippets}"]
}

data "template_file" "worker_configs" {
  count = "${var.count}"

  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars {
    # Cannot use cyclic dependencies on workers or their DNS records
    domain_name            = "${var.name}-worker${count.index}.${var.dns_zone}"
    cluster_dns_service_ip = "${cidrhost(var.service_cidr, 10)}"
    kubeconfig             = "${indent(10, var.kubeconfig)}"
    cluster_domain_suffix  = "${var.cluster_domain_suffix}"
    ssh_authorized_key     = "${var.ssh_authorized_key}"
    network_prefix         = "${element(split("/", data.vultr_network.cluster.cidr_block), 1)}"
  }
}

data vultr_network "cluster" {
  filter = {
    name   = "NETWORKID"
    values = ["${var.network_id}"]
  }
}
