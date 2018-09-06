variable "opsman_version_regex" {
  type = "string"
  default = "^2\.1\..*$"
}

variable "opsman_admin_username" {
  type = "string"
  default = "arceus"
}

local {
  opsman_fqdn = "manager.pcf.${var.domain}"
}

data "template_file" "opsman_install_vars" {
  template = "${file("${var.template_dir}/pipelines/opsman-vars.yml")}"
  vars {
    version_number =  "${var.opsman_version_regex}"

    # opsman network info
    opsman_domain = "${local.opsman_domain}"
    opsman_dns_servers = "${opsman_dns_servers}"
    opsman_gateway = "${opsman_gateway}"
    opsman_ip_address = "${local.opsman_ip}"
    opsman_netmask = "${opsman_netmask}"
    opsman_ntp_servers = "${opsman_ntp_servers}"
    ntp_servers = "${ntp_servers}"

    # opsman vm parameters config
    opsman_resource_pool = "${opsman_resource_pool}"
    opsman_vm_folder = "${opsman_vm_folder}"
    opsman_vm_host = "${opsman_vm_host}"
    opsman_vm_name = "${opsman_vm_name}"
    opsman_vm_network = "${opsman_vm_network}"
    opsman_vm_power_state = true
    opsman_disk_type = "${opsman_disk_type}"

    # directory vsphere configuration

    # vCenter configuration
    vcenter_host = "${vcenter_host}"
    vcenter_datastore = "${vcenter_datastore}"        # vCenter datastore name to deploy Ops Manager in
    vcenter_datacenter = "${vcenter_datacenter}"
    vcenter_insecure = "${vcenter_insecure}"  # true or false
    vm_disk_type = "${vm_disk_type}"
    vcenter_ca_cert = "${vcenter_ca_cert}"
    ephemeral_storage_names = "${ephemeral_storage_names}" # Ephemeral Storage names in vCenter for use by PCF. e.g. a-xio, b-xio, c-xio
    persistent_storage_names = "${persistent_storage_names}" # Persistent Storage names in vCenter for use by PCF, e.g. a-xio, b-xio, c-xio

    # availability zones for the director
    az_1_cluster_name = "${az_1_cluster_name}"
    az_1_rp_name = "${az_1_rp_name}"
    az_2_cluster_name = "${az_2_cluster_name}"
    az_2_rp_name = "${az_2_rp_name}"
    az_3_cluster_name = "${az_3_cluster_name}"
    az_3_rp_name = "${az_3_rp_name}"

    # director vsphere inventory
    bosh_disk_path = "${bosh_disk_path}"
    bosh_template_folder = "${bosh_template_folder}"
    bosh_vm_folder = "${bosh_vm_folder}"

    # director networks
    infra_vsphere_network = "${infra_vsphere_network}"
    infra_nw_cidr = "${infra_nw_cidr}"
    infra_excluded_range = "${infra_excluded_range}"
    infra_nw_dns = "${infra_nw_dns}"
    infra_nw_gateway = "${infra_nw_gateway}"

    deployment_vsphere_network = "${deployment_vsphere_network}"
    deployment_nw_cidr = "${deployment_nw_cidr}"
    deployment_excluded_range = "${deployment_excluded_range}"
    deployment_nw_dns = "${deployment_nw_dns}"
    deployment_nw_gateway = "${deployment_nw_gateway}"

    services_vsphere_network = "${services_vsphere_network}"
    services_nw_cidr = "${services_nw_cidr}"
    services_excluded_range = "${services_excluded_range}"
    services_nw_dns = "${services_nw_dns}"
    services_nw_gateway = "${services_nw_gateway}"

    dynamic_services_vsphere_network = "${dynamic_services_vsphere_network}"
    dynamic_services_nw_cidr = "${dynamic_services_nw_cidr}"
    dynamic_services_excluded_range = "${dynamic_services_excluded_range}"
    dynamic_services_nw_dns = "${dynamic_services_nw_dns}"
    dynamic_services_nw_gateway = "${dynamic_services_nw_gateway}"
  }
}

resource "random_pet" "credhub_encryption_keys" {
  count = "${data.template_file.credhub_encryption_keys.count}"
  length = 6
}

data "template_file" "credhub_encryption_keys" {
  count = 3
  template = "${file("${var.template_dir}"/pipelines/opsman-vars.yml")}"
  vars {
    key_name = "Encryption Key ${count.index}"
    key = "${random_pet.credhub_encryption_keys.*.id}"
  }
}

resource "random_pet" "opsman_admin_password" {
  length = 4
}

resource "random_pet" "opsman_ssh_password" {
  length = 4
}

resource "random_pet" "opsman_decryption_password" {
  length = 4
}

data "template_file" "opsman_install_secrets" {
  template = "${file("${var.template_dir}"/pipelines/opsman-secrets.yml")}"

  vars {
    # Leave opsman_client_id/opsman_client_secret blank; opsman_admin_username/opsman_admin_password needs to be specified
    opsman_admin_username = "${var.opsman_admin_username}"
    opsman_admin_password = "${random_pet.opsman_admin_password.id}"
    opsman_ssh_password = "${random_pet.opsman_ssh_password.id}"
    opsman_decryption_pwd = "${random_pet.opsman_decryption_password.id}"

    vcenter_username = "${data.terraform_remote_state}"
    vcenter_password = "${vcenter_password}"

    # For credhub integration, replace dummy values in the following structure
    # and set the number of credhub instances in resource config to 2
    credhub_encryption_keys = "${data.template_file.credhub_encryption_keys.rendered}"

    # Optional PEM-encoded certificates to add to BOSH director
    trusted_certificates = "${trusted_certificates}"
  }
}
