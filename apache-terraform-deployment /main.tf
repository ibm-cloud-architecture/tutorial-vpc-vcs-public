# Create an SSH key. The SSH key surfaces in the SoftLayer console under Devices > Manage > SSH Keys.
resource "ibm_compute_ssh_key" "ssh_compute_key" {
  label      = "${var.ssh_key_label}_${var.softlayer_username}"
  notes      = "${var.ssh_key_note} ${var.softlayer_username}"
  public_key = "${var.ssh_public_key}"
}

resource "ibm_compute_vm_instance" "computes" {
  hostname          = "${var.prefix_compute}${count.index}"
  domain            = "${var.domain_name}"
  ssh_key_ids       = ["${ibm_compute_ssh_key.ssh_compute_key.id}"]
  os_reference_code = "${var.os_reference}"
  datacenter        = "${var.datacenter}"
  hourly_billing    = "${var.hourly_billing_compute}"
  network_speed     = "${var.network_speed_compute}"
  cores             = "${var.core_of_compute}"
  memory            = "${var.memory_in_mb_compute}"
  count             = "${var.private_vlan_id > 0 ? 0 : var.image_id > 0 ? 0 : var.number_of_compute}"
  user_metadata = "#!/bin/bash\n${file("scripts/install_apache.sh")}"
  private_network_only        = "${var.master_use_bare_metal ? false : var.use_intranet}"
}


##############################################################################
# Variables
##############################################################################
variable uri_file_entitlement {
  default = "https://iwm.dhe.ibm.com/sdfdl/v2/regs2/nrli/symphony/July/Xa.2/Xb.XvRJVl6Ko8kbHiH3zamTvwRqyEtsZ17kCUROBUbjB-A/Xc.July/sym_adv_ev_entitlement.dat/Xd./Xf.LPr.D1vk/Xg.9899594/Xi.swerpzsw-symphony-3/XY.regsrvs/XZ.rZIyLQLtu2Ynivsgk_fgWicZXso/sym_adv_ev_entitlement.dat"
  description = "The URL to the entitlement file for the software product."
}
variable uri_package_installer {
  default = "https://iwm.dhe.ibm.com/sdfdl/v2/regs2/nrli/symphony/July/Xa.2/Xb.XvRJVl6Ko8kbHiH3zamTvwRqyEtsZ17kCUROBfALFGE/Xc.July/symeval-7.2.1.0_x86_64.bin/Xd./Xf.LPr.D1vk/Xg.9899594/Xi.swerpzsw-symphony-3/XY.regsrvs/XZ.bOVWG1oZTkiUOjIFD_eXXMm1i8o/symeval-7.2.1.0_x86_64.bin"
  description = "The URL to the installation media for the Symphony cluster"
}
variable ssh_public_key {
  description = "The public key contents for the SSH keypair to access cluster nodes."
}
variable uri_package_additional {
  default = "http://url/to/additional"
  description = "The URL to the product package supplement file."
}
variable uri_package_additional2 {
  default = "http://url/to/additional2"
  description = "The URL to an additional product package supplement file."
}
variable product {
  default = "symphony"
  description = "The cluster product to deploy: `symphony`, `cws`, or `lsf`."
}
variable version {
  default = "7.2.1.0"
  description = "The version of the cluster product: `latest`, `7.2.0.0`, `2.2.0.0`, or `10.1`."
}
variable entitlement {
  default = "paste your entitlement content if uri_file_entitlement is not set"
  description = "Entitlement content that enables use of the cluster software."
}
variable os_reference {
  default = "CENTOS_7_64"
  description = "An operating system reference code that is used to provision the cluster nodes."
}
variable image_id {
  default = 0
  description = "specify the vm image id for the resource"
}
variable number_of_compute {
  default = 1
  description = "The number of VM compute nodes to deploy."
}
variable number_of_dehost {
  default = 1
  description = "The number of development nodes to depoy."
}
variable datacenter {
  default = "dal12"
  description = "The datacenter to create resources in."
}
variable private_vlan_id {
  default = 0
  description = "specify the vm vlan to place the resource"
}
variable ssh_key_label {
  default = "ssh_compute_key"
  description = "An identifying label to assign to the SSH key."
}
variable ssh_key_note {
  default = "ssh key for cluster hosts"
  description = "A description to assign to the SSH key."
}
variable cluster_admin {
  default = "egoadmin"
  description = "The administrator account of the cluster: `egoadmin` or `lsfadmin`."
}
variable cluster_name {
  default = "cluster1"
  description = "The name of the cluster."
}
variable cluster_web_admin_password {
  default = "Admin"
  description = "Password for web interface account Admin: `Admin` by default"
}
variable domain_name {
  default = "domain.com"
  description = "The name of the domain for the instance."
}
variable prefix_master {
  default = "master"
  description = "The hostname prefix for the master server."
}
variable prefix_compute {
  default = "compute"
  description = "The hostname prefix for compute nodes."
}
variable prefix_dehost {
  default = "dehost"
  description = "The hostname prefix for Symphony development nodes."
}
variable network_speed_master {
  default = 1000
  description = "The network interface speed for the master nodes."
}
variable network_speed_compute {
  default = 1000
  description = "The network interface speed for the compute nodes."
}
variable core_of_master {
  default = 2
  description = "The number of CPU cores to allocate to the master server."
}
variable core_of_compute {
  default = 1
  description = "The number of CPU cores to allocate to the compute server."
}
variable memory_in_mb_master {
  default = 8192
  description = "The amount of memory (in Mb) to allocate to the master server."
}
variable memory_in_mb_compute {
  default = 4096
  description = "The amount of memory (in Mb) to allocate to the compute server."
}
variable hourly_billing_master {
  default = "true"
  description = "When set to true, the master node is billed on hourly usage. Otherwise, the instance is billed on a monthly basis."
}
variable hourly_billing_compute {
  default = "true"
  description = "When set to true, the computing instance is billed on hourly usage. Otherwise, the instance is billed on a monthly basis."
}
variable post_install_script_uri {
  default = "https://raw.githubusercontent.com/favrecr/spectrum-schematics-cluster/master/scripts/ibm_spectrum_computing_deploy.sh"
  description = "The URL for the deployment script."
}
variable symphony_install_script_uri {
  default = "https://raw.githubusercontent.com/favrecr/spectrum-schematics-cluster/master/scripts/symphony.sh"
  description = "The URL for the Symphony deployment script."
}
variable use_intranet {
  default = "true"
  description = "Specifies whether the cluster resolves hostnames with intranet or internet IP addresses."
}
variable datacenter_bare_metal {
  default = "tor01"
  description = "The datacenter to create bare metal resources in."
}
variable os_reference_bare_metal {
  default = "UBUNTU_16_64"
  description = "An operating system reference code that is used to provision the bare metal server."
}
variable master_use_bare_metal {
  default = "false"
  description = "If set to `true`, bare metal masters are created. If set to `false`, VM masters are created."
}
variable fixed_config_preset {
  default = "S1270_32GB_2X960GBSSD_NORAID"
  description = "The bare metal hardware configuration."
}
variable number_of_compute_bare_metal {
  default = 0
  description = "The number of bare metal compute nodes to deploy"
}
variable prefix_compute_bare_metal {
  default = "bmcompute"
  description = "The hostname prefix for bare metal compute nodes."
}
variable failover_master {
  default = "false"
  description = "If set to `true`, enable failover for masters."
}
