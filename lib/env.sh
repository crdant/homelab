# identity
email=cdantonio@pivotal.io
admin_user=arceus
vpn_user=crdant
vsphere_user=root

# important files and directories

key_dir="${BASEDIR}/keys"
work_dir="${BASEDIR}/work"
etc_dir="${BASEDIR}/etc"
state_dir="${BASEDIR}/state"
pipeline_dir="${BASEDIR}/pipelines"
ops_dir="${pipeline_dir}/ops"
manifest_dir="${BASEDIR}/manifests"
terraform_dir="${BASEDIR}/terraform"
template_dir="${BASEDIR}/templates"

# s3 buckets
state_bucket=homelab-dewberry-word-momento-par

# software you download before
vcenter_iso_path="${work_dir}/VMware-VCSA-all-6.7.0-8546234.iso"
vcenter_license=${VCENTER_LICENSE}

# certificate configuration
certbot_dir=/usr/local/etc/certbot
ca_dir=${certbot_dir}/live
ca_cert_file=${key_dir}/letsencrypt.pem

# DNS
domain=crdant.net
subdomain=cloud.${domain}
zone_id=Z267SNS3KA0BVO
dns_ttl=60

# NTP
ntp_servers="0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org"

# static hosts
router_host="savasana"
outside_host="kapotasana"
vsphere_host="tadasana"
vcenter_host="garundasana"

# router configuration
router_user=ubnt
vpn_user="${USER}"

# vcenter configuration
vcenter_admin=administrator@${domain}
bucc_service_account=${domain}\\bucc
bosh_director_role="BOSH Director"
bosh_director_group="BoshDirectorServiceAccounts"

infra_datastore=vsanDatastore
vcenter_data_center=home-lab
vcenter_cluster=primary-cluster
vcenter_resource_pool_1=zone-1
vcenter_resource_pool_2=zone-2
vcenter_resource_pool_3=zone-3
boostrap_switch=bootstrap-switch
bootstrap_network=bootstrap-port-group
pcf_switch=pcf-switch
infrastructure_network=infra-port-group
deployment_network=deployment-port-group
services_network=services-port-group
dynamic_network=dynamic-port-group
container_network=container-port-group
balancer_internal_network=lb-internal-port-group
balancer_external_network=lb-external-port-group
dns_servers="8.8.8.8,8.8.4.4"
dns_servers_array="[ 172.20.0.0, 8.8.4.4 ]"

# PCF configuration
om_datastore=vsanDatastore
om_host_name=manager
om_ip_address=$(dig +short ${om_host_name}.${subdomain})
director_host_name=director
om_admin_user=arceus
pcf_datastore=vsanDatastore
## Deployment domain names
pcf_system_prefix=run
pcf_apps_prefix=apps
pcf_tcp_prefix=tcp
