# important files and directories

key_dir="${BASEDIR}/keys"
work_dir="${BASEDIR}/work"
etc_dir="${BASEDIR}/etc"
manifest_dir="${BASEDIR}/manifests"
state_file=${work_dir}/state.sh

# private Network

cidr="172.16.0.0/12"

# subnet ranges

local_cidr="172.16.0.0/26"
vpn_cidr="172.17.0.0/26"
management_cidr="172.18.0.0/26"
vmware_cidr="172.19.0.0/26"
bootstrap_cidr="172.20.0.0/26"
infrastructure_cidr="172.24.0.0/22"
deployment_cidr="172.25.0.0/22"
load_balancer_cidr="172.26.0.0/26"
tiles_cidr="172.27.0.0/22"
odb_cidr="172.28.0.0/22"

# static hosts

vcenter_host="garundasana.crdant.net"

# vcenter configuration

bosh_service_account=crdant.net\\bosh
vcenter_network=bootstrap-port-group
vcenter_cluster=primary-cluster
vcenter_data_center=home-lab
vcenter_fast_datastore=ssd
vcenter_slow_dataastore=spinning

if [ -f ${state_file} ] ; then
  . ${state_file}
fi
