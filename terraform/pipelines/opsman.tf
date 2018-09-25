variable "opsman_version_regex" {
  type = "string"
  default = "^2\\.3\\..*$$"
}

variable "vm_disk_type" {
  type = "string"
  default = "thin"
}

variable "credhub_encryption_key_name" {
  type = "string"
  default = "CredHub Key"
}

variable "trusted_certificates" {
  type = "string"
}

locals {
  opsman_fqdn = "manager.pcf.${var.domain}"
  director_fqdn = "director.pcf.${var.domain}"
}

locals {
  opsman_vm_name = "${var.env_id}-ops-manager"

  infrastructure_excluded = "${cidrhost(local.infrastructure_cidr,1)}-${cidrhost(local.infrastructure_cidr,10)}"
  deployment_excluded = "${cidrhost(local.deployment_cidr,1)}-${cidrhost(local.deployment_cidr,10)}"
  services_excluded = "${cidrhost(local.services_cidr,1)}-${cidrhost(local.services_cidr,10)}"
  pks_clusters_excluded = "${cidrhost(local.container_cidr,1)}-${cidrhost(local.container_cidr,10)}"
}


data "template_file" "opsman_install_vars" {
  template = "${file("${var.template_dir}/pipelines/opsman/vars.yml")}"
  vars {
    opsman_version_regex =  "${var.opsman_version_regex}"

    # opsman network info
    opsman_domain = "${local.opsman_fqdn}"
    opsman_dns_servers = "${join(",", var.dns_servers)}"
    opsman_gateway = "${local.infrastructure_gateway}"
    opsman_ip_address = "${local.opsman_ip}"
    opsman_netmask = "${local.infrastructure_netmask}"
    opsman_ntp_servers = "${join(",", var.ntp_servers)}"

    # opsman vm parameters config
    opsman_resource_pool = "${data.terraform_remote_state.pave.om_resource_pool}"
    opsman_vm_folder = "${data.terraform_remote_state.bbl.opsman_vm_folder}"
    opsman_vm_name = "${local.opsman_vm_name}"
    opsman_vm_host = "${data.terraform_remote_state.pave.vsphere_host}"
    opsman_vm_network = "${data.terraform_remote_state.pave.infrastructure_network}"
    opsman_vm_power_state = true
    opsman_disk_type = "${var.vm_disk_type}"

    # director vsphere configuration

    # vCenter configuration
    vcenter_host = "${data.terraform_remote_state.bbl.vcenter_ip}"
    vcenter_datastore = "${data.terraform_remote_state.bbl.vcenter_ds}"        # vCenter datastore name to deploy Ops Manager in
    vcenter_datacenter = "${data.terraform_remote_state.bbl.vcenter_dc}"
    vcenter_insecure = true  # true or false
    vm_disk_type = "${var.vm_disk_type}"
    vcenter_ca_cert = ""
    ephemeral_storage_names = "${data.terraform_remote_state.bbl.vcenter_ds}"  # Ephemeral Storage names in vCenter for use by PCF. e.g. a-xio, b-xio, c-xio
    persistent_storage_names = "${data.terraform_remote_state.bbl.vcenter_ds}" # Persistent Storage names in vCenter for use by PCF, e.g. a-xio, b-xio, c-xio

    # Optional DNS name for Ops Director. Should be reachable from all networks.
    director_host = "${local.director_fqdn}"

    # availability zones for the director
    az_1_name = "${var.availability_zones[0]}"
    az_1_cluster_name = "${data.terraform_remote_state.pave.director_cluster}"
    az_1_rp_name = "${data.terraform_remote_state.pave.director_resource_pool_names[0]}"
    az_2_name = "${var.availability_zones[1]}"
    az_2_cluster_name = "${data.terraform_remote_state.pave.director_cluster}"
    az_2_rp_name = "${data.terraform_remote_state.pave.director_resource_pool_names[1]}"
    az_3_name = "${var.availability_zones[2]}"
    az_3_cluster_name = "${data.terraform_remote_state.pave.director_cluster}"
    az_3_rp_name = "${data.terraform_remote_state.pave.director_resource_pool_names[2]}"

    # director vsphere inventory
    bosh_disk_path = "${data.terraform_remote_state.bbl.pcf_disk_folder}"
    bosh_template_folder = "${data.terraform_remote_state.bbl.pcf_template_folder}"
    bosh_vm_folder = "${data.terraform_remote_state.bbl.pcf_inventory_folder}"

    # director networks
    ntp_servers = "${join(",", var.ntp_servers)}"

    infra_vsphere_network = "${data.terraform_remote_state.pave.infrastructure_network}"
    infra_nw_cidr = "${local.infrastructure_cidr}"
    infra_excluded_range = "${local.infrastructure_excluded}"
    infra_nw_dns = "${join(",", var.dns_servers)}"
    infra_nw_gateway = "${local.infrastructure_gateway}"

    deployment_vsphere_network = "${data.terraform_remote_state.pave.deployment_network}"
    deployment_nw_cidr = "${local.deployment_cidr}"
    deployment_excluded_range = "${local.deployment_excluded}"
    deployment_nw_dns = "${join(",", var.dns_servers)}"
    deployment_nw_gateway = "${local.deployment_gateway}"

    services_vsphere_network = "${data.terraform_remote_state.pave.services_network}"
    services_nw_cidr = "${local.services_cidr}"
    services_excluded_range = "${local.services_excluded}"
    services_nw_dns = "${join(",", var.dns_servers)}"
    services_nw_gateway = "${local.services_gateway}"

    dynamic_services_vsphere_network = "${data.terraform_remote_state.pave.pks_clusters_network}"
    dynamic_services_nw_cidr = "${local.container_cidr}"
    dynamic_services_excluded_range = "${local.pks_clusters_excluded}"
    dynamic_services_nw_dns = "${join(",", var.dns_servers)}"
    dynamic_services_nw_gateway = "${local.pks_clusters_gateway}"
  }
}

resource "local_file" "opsman_install_vars" {
  content  = "${data.template_file.opsman_install_vars.rendered}"
  filename = "${var.work_dir}/pipelines/opsman/vars.yml"
}

resource "random_pet" "opsman_ssh_password" {
  length = 4
}

resource "random_pet" "opsman_decryption_password" {
  length = 4
}

resource "random_pet" "credhub_encryption_key" {
  count = 3
  length = 6
}

data "template_file" "opsman_install_secrets" {
  template = "${file("${var.template_dir}/pipelines/opsman/secrets.yml")}"

  vars {
    pipeline_secret_root = "${local.install_om_secret_root}"
    opsman_ssh_password = "${random_pet.opsman_ssh_password.id}"
    opsman_decryption_pwd = "${random_pet.opsman_decryption_password.id}"

    vcenter_username = "${data.terraform_remote_state.bbl.pcf_vcenter_user}"
    vcenter_password = "${data.terraform_remote_state.bbl.pcf_vcenter_password}"

    # For credhub integration, replace dummy values in the following structure
    # and set the number of credhub instances in resource config to 2
    credhub_encryption_key_name1 = "${var.credhub_encryption_key_name} 1"
    credhub_encryption_key_secret1 = "${random_pet.credhub_encryption_key.0.id}"
    credhub_encryption_key_name2 = "${var.credhub_encryption_key_name} 2"
    credhub_encryption_key_secret2 = "${random_pet.credhub_encryption_key.1.id}"
    credhub_encryption_key_name3 = "${var.credhub_encryption_key_name} 3"
    credhub_encryption_key_secret3 = "${random_pet.credhub_encryption_key.2.id}"

    # Optional PEM-encoded certificates to add to BOSH director
    trusted_certificates = "${replace(var.trusted_certificates, "\n", "\n    ")}"
  }

}

resource "local_file" "opsman_install_secrets" {
  content  = "${data.template_file.opsman_install_secrets.rendered}"
  filename = "${var.key_dir}/pipelines/opsman/secrets.yml"

  provisioner "local-exec" {
    command =<<COMMAND
eval "$(bbl print-env)"
credhub import --file ${self.filename}
COMMAND
  }
}

data "template_file" "opsman_upgrade_vars" {
  template = "${file("${var.template_dir}/pipelines/opsman/upgrade-vars.yml")}"
  vars {
    opsman_version_regex =  "${var.opsman_version_regex}"

    # opsman network info
    opsman_domain = "${local.opsman_fqdn}"
    opsman_dns_servers = "${join(",", var.dns_servers)}"
    opsman_gateway = "${local.infrastructure_gateway}"
    opsman_ip_address = "${local.opsman_ip}"
    opsman_netmask = "${local.infrastructure_netmask}"
    opsman_ntp_servers = "${join(",", var.ntp_servers)}"

    # opsman vm parameters config
    opsman_resource_pool = "${data.terraform_remote_state.pave.om_resource_pool}"
    opsman_vm_folder = "${data.terraform_remote_state.pave.infrastructure_folder}"
    opsman_vm_network = "${data.terraform_remote_state.pave.infrastructure_network}"
    opsman_disk_type = "${var.vm_disk_type}"

    # vCenter configuration
    vcenter_host = "${data.terraform_remote_state.bbl.vcenter_ip}"
    vcenter_datastore = "${data.terraform_remote_state.bbl.vcenter_ds}"        # vCenter datastore name to deploy Ops Manager in
    vcenter_datacenter = "${data.terraform_remote_state.bbl.vcenter_dc}"
    vcenter_insecure = true  # true or false
    vcenter_ca_cert = ""
    vm_disk_type = "${var.vm_disk_type}"
  }
}

resource "local_file" "opsman_upgrade_vars" {
  content  = "${data.template_file.opsman_upgrade_vars.rendered}"
  filename = "${var.work_dir}/pipelines/opsman/upgrade-vars.yml"
}

data "template_file" "opsman_upgrade_secrets" {
  template = "${file("${var.template_dir}/pipelines/opsman/upgrade-secrets.yml")}"

  vars {
    pipeline_secret_root = "${local.upgrade_om_secret_root}"
    # Leave opsman_client_id/opsman_client_secret blank; opsman_admin_username/opsman_admin_password needs to be specified
    opsman_admin_username = "${var.opsman_admin_username}"
    opsman_admin_password = "${random_pet.opsman_admin_password.id}"
    opsman_ssh_password = "${random_pet.opsman_ssh_password.id}"
    opsman_decryption_pwd = "${random_pet.opsman_decryption_password.id}"

    vcenter_username = "${data.terraform_remote_state.bbl.pcf_vcenter_user}"
    vcenter_password = "${data.terraform_remote_state.bbl.pcf_vcenter_password}"

    # Optional PEM-encoded certificates to add to BOSH director
    trusted_certificates = "${replace(var.trusted_certificates, "\n", "\n    ")}"
  }

}

resource "local_file" "opsman_upgrade_secrets" {
  content  = "${data.template_file.opsman_upgrade_secrets.rendered}"
  filename = "${var.key_dir}/pipelines/opsman/upgrade-secrets.yml"

  provisioner "local-exec" {
    command =<<COMMAND
eval "$(bbl print-env)"
credhub import --file ${self.filename}
COMMAND
  }
}
