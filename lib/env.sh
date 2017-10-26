# identity
email=cdantonio@pivotal.io

# important files and directories

key_dir="${BASEDIR}/keys"
work_dir="${BASEDIR}/work"
etc_dir="${BASEDIR}/etc"
pipeline_dir="${BASEDIR}/pipelines"
ops_dir="${pipeline_dir}/ops"
manifest_dir="${BASEDIR}/manifests"
state_file=${work_dir}/state.sh

# DNS
domain=crdant.net
subdomain=cloud.${domain}
zone_id=Z267SNS3KA0BVO
dns_ttl=60

# NTP
ntp_servers="0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org"

# private Network
cidr="172.16.0.0/12"

# networks
local_cidr="172.16.0.0/26"
vpn_cidr="172.17.0.0/26"
management_cidr="172.18.0.0/26"
vmware_cidr="172.19.0.0/26"
bootstrap_cidr="172.20.0.0/26"
pcf_cidr="172.24.0.0/13"
infrastructure_cidr="172.24.0.0/26"
infrastructure_netmask="255.255.255.192"
deployment_cidr="172.25.0.0/22"
balancer_cidr="172.26.0.0/26"
services_cidr="172.27.0.0/22"
dynamic_cidr="172.28.0.0/22"
container_cidr="172.29.0.0/22"

# static hosts
router_host="savasana.${domain}"
esxi_host="tadasana.${domain}"
vcenter_host="garundasana.${domain}"

# router configuration
router_user=ubnt
vpn_user="${USER}"

# vcenter configuration
vcenter_admin=administrator@${domain}
bucc_service_account=${domain}\\bucc
bosh_director_role="BOSH Director"
bosh_director_group="BoshDirectorServiceAccounts"

vcenter_data_center=home-lab
vcenter_cluster=primary-cluster
vcenter_resource_pool_1=zone-1
vcenter_resource_pool_2=zone-2
vcenter_resource_pool_3=zone-3
vcenter_fast_datastore=ssd
vcenter_slow_datastore=spinning
boostrap_switch=bootstrap-switch
bootstrap_network=bootstrap-port-group
pcf_switch=pcf-switch
infrastructure_network=infra-port-group
deployment_network=deployment-port-group
services_network=services-port-group
dynamic_network=dynamic-port-group
container_network=container-port-group
dns_servers="8.8.8.8,8.8.4.4"
dns_servers_array="[ 172.20.0.0, 8.8.4.4 ]"

# PCF configuration
om_host_name=manager
om_ip_address=$(dig +short ${om_host_name}.${subdomain})
director_host_name=director
om_admin_user=arceus
## Deployment domain names
pcf_system_prefix=system
pcf_apps_prefix=apps

# PCF static IPs
deployment_base=$(echo ${deployment_cidr} | awk -F. '{print $1 "." $2 "." $3}')
router_static_ips=${deployment_base}.240,${deployment_base}.241,${deployment_base}.242
tcp_router_static_ips=${deployment_base}.243,${deployment_base}.244,${deployment_base}.245
brain_static_ips=${deployment_base}.250,${deployment_base}.251,${deployment_base}.252

# Kubo configuration
kubo_director_user=kubo
kubo_storage_user=kubo_storage
kubo_storage_role="Kubernetes Storage"
kubo_storage_group="K8sStorageServiceAccounts"

# git repository for state
git_server=git@github.com
git_user=crdant
kubo_state_repo=kubo-state

if [ -f ${state_file} ] ; then
  . ${state_file}
fi
