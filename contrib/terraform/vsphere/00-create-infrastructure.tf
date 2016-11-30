# Configuration for VSphere

# - VSPHERE - #
variable "vsphere_user"
variable "vsphere_password"
variable "vsphere_server"
variable "vsphere_allow_unverified_ssl" {default = true}
variable "ssh_user"
variable "ssh_key"


# - MASTER - #
variable "master_count" {default = 3}
variable "master_prefix" {default = "kube"}
variable "master_vcpu" {default = 4}
variable "master_memory" {default = 6144}
variable "master_network_interface_label" {default = "VM Network"}
variable "master_resource_pool"
variable "master_disk_datastore"
variable "master_disk_template"

# - WORKER - #
variable "worker_count" {default = 6}
variable "worker_prefix" {default = "kube"}
variable "worker_vcpu" {default = 4}
variable "worker_memory" {default = 6144}
variable "worker_network_interface_label" {default = "VM Network"}
variable "worker_resource_pool"
variable "worker_disk_datastore"
variable "worker_disk_template"

# - ETCD - #
variable "etcd_count" {default = 3}
variable "etcd_prefix" {default = "kube"}
variable "etcd_vcpu" {default = 4}
variable "etcd_memory" {default = 6144}
variable "etcd_network_interface_label" {default = "VM Network"}
variable "etcd_resource_pool"
variable "etcd_disk_datastore"
variable "etcd_disk_template"

provider "vsphere" {
    user           = "${var.vsphere_user}"
    password       = "${var.vsphere_password}"
    vsphere_server = "${var.vsphere_server}"
    allow_unverified_ssl = "${var.vsphere_allow_unverified_ssl}"
}

resource "vsphere_virtual_machine" "master" {
    count = "${var.master_count}"
    name =  "${var.master_prefix}-master-${count.index + 1}"
    vcpu = "${var.master_vcpu}"
    memory = "${var.master_memory}"
    resource_pool = "${var.master_resource_pool}"

    network_interface {
        label = "${var.master_network_interface_label}"
    }

    disk {
        datastore = "${var.master_disk_datastore}"
        template = "${var.master_disk_template}"
    }

    connection = {
        user = "${var.ssh_user}"
        private_key = "${file("${var.ssh_key}")}"
        host = "${self.network_interface.0.ipv4_address}"
    }

    provisioner "remote-exec" {
        inline = [ "sudo hostnamectl --static set-hostname ${self.name}" ]
    }
}

resource "vsphere_virtual_machine" "worker" {
    count = "${var.worker_count}"
    name =  "${var.worker_prefix}-worker-${count.index + 1}"
    vcpu = "${var.worker_vcpu}"
    memory = "${var.worker_memory}"
    resource_pool = "${var.worker_resource_pool}"

    network_interface {
        label = "${var.worker_network_interface_label}"
    }

    disk {
        datastore = "${var.worker_disk_datastore}"
        template = "${var.worker_disk_template}"
    }

    connection = {
        user = "${var.ssh_user}"
        private_key = "${file("${var.ssh_key}")}"
        host = "${self.network_interface.0.ipv4_address}"
    }

    provisioner "remote-exec" {
        inline = [ "sudo hostnamectl --static set-hostname ${self.name}" ]
    }
}

resource "vsphere_virtual_machine" "etcd" {
    count = "${var.etcd_count}"
    name =  "${var.etcd_prefix}-etcd-${count.index + 1}"
    vcpu = "${var.etcd_vcpu}"
    memory = "${var.etcd_memory}"
    resource_pool = "${var.etcd_resource_pool}"

    network_interface {
        label = "${var.etcd_network_interface_label}"
    }

    disk {
        datastore = "${var.etcd_disk_datastore}"
        template = "${var.etcd_disk_template}"
    }

    connection = {
        user = "${var.ssh_user}"
        private_key = "${file("${var.ssh_key}")}"
        host = "${self.network_interface.0.ipv4_address}"
    }

    provisioner "remote-exec" {
        inline = [ "sudo hostnamectl --static set-hostname ${self.name}" ]
    }
}
