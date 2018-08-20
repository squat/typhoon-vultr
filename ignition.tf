locals {
  # coreos-stable -> coreos flavor, stable channel
  # flatcar-stable -> flatcar flavor, stable channel
  flavor = "${element(split("-", var.os_image), 0)}"

  channel = "${element(split("-", var.os_image), 1)}"

  baseurl = "${local.flavor == "coreos" ? "http://${local.channel}.release.core-os.net/amd64-usr/current" : "http://${local.channel}.release.flatcar-linux.net/amd64-usr/current"}"
}

resource "vultr_startup_script" "ipxe" {
  type    = "pxe"
  name    = "${var.cluster_name}"
  content = "${data.template_file.ipxe.rendered}"
}

data "template_file" "ipxe" {
  template = "${file("${path.module}/cl/ipxe.tmpl")}"

  vars {
    initrd      = "${local.baseurl}/${local.flavor}_production_pxe_image.cpio.gz"
    kernel      = "${local.baseurl}/${local.flavor}_production_pxe.vmlinuz"
    kernel_args = "${join(" ", var.kernel_args)}"
    flavor      = "${local.flavor}"
  }
}

data "ct_config" "controller_container_linux_install_configs" {
  count = "${var.controller_count}"

  pretty_print = false
  content      = "${element(data.template_file.controller_container_linux_install_configs.*.rendered, count.index)}"
}

data "template_file" "controller_container_linux_install_configs" {
  count = "${var.controller_count}"

  template = "${file("${path.module}/cl/install.yaml.tmpl")}"

  vars {
    os_flavor          = "${local.flavor}"
    os_channel         = "${local.channel}"
    ignition           = "${element(data.ct_config.controller_ignitions.*.rendered, count.index)}"
    install_disk       = "${var.install_disk}"
    ssh_authorized_key = "${var.ssh_authorized_key}"
  }
}

data "ct_config" "controller_ignitions" {
  count        = "${var.controller_count}"
  content      = "${element(data.template_file.controller_configs.*.rendered, count.index)}"
  pretty_print = false
  snippets     = ["${var.controller_clc_snippets}"]
}

data "template_file" "controller_configs" {
  count = "${var.controller_count}"

  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars {
    # Cannot use cyclic dependencies on controllers or their DNS records
    domain_name = "${var.cluster_name}-controller${count.index}.${var.dns_zone}"
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"

    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster  = "${join(",", formatlist("%s=https://%s:2380", null_resource.repeat.*.triggers.name, null_resource.repeat.*.triggers.domain))}"
    k8s_dns_service_ip    = "${module.bootkube.cluster_dns_service_ip}"
    kubeconfig            = "${indent(10, module.bootkube.kubeconfig)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
    network_prefix        = "${element(split("/", vultr_network.cluster.cidr_block), 1)}"
  }
}

# Horrible hack to generate a Terraform list of a desired length without dependencies.
# Ideal ${repeat("etcd", 3) -> ["etcd", "etcd", "etcd"]}
resource null_resource "repeat" {
  count = "${var.controller_count}"

  triggers {
    name   = "etcd${count.index}"
    domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
  }
}
