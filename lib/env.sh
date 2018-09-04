# identity
email=cdantonio@pivotal.io
admin_user=arceus
vsphere_user=root

# vsphere
iaas=vsphere

# important files and directories
lib_dir="${BASEDIR}/lib"
key_dir="${BASEDIR}/keys"
work_dir="${BASEDIR}/work"
state_dir="${BASEDIR}/state"
terraform_dir="${BASEDIR}/terraform"
template_dir="${BASEDIR}/templates"

# GCP for configuration remote state and DNS
project=crdant-net
account=chuck@crdant.io
service_account_name=homelab
service_account="${service_account_name}@${project}.iam.gserviceaccount.com"
key_file="${key_dir}/${service_account}.json"
statefile_bucket=homelab-cupboard-maladapt-stammer-dabble
region=us-east1

# software you download before
vcenter_iso_path="${work_dir}/VMware-VCSA-all-6.7.0-8546234.iso"
vcenter_license=${VCENTER_LICENSE}

# DNS
domain=crdant.net
subdomain=cloud.${domain}
dns_ttl=60

# NTP
ntp_servers=( "0.pool.ntp.org" "1.pool.ntp.org" "2.pool.ntp.org" "3.pool.ntp.org" )

# static hosts
router_host="savasana"
outside_host="kapotasana"
vsphere_host="tadasana"
vcenter_host="garundasana"
bigip_management_host="vasisthasana"

# router configuration
router_user=ubnt
vpn_users=( "crdant" )

# vcenter configuration
vcenter_admin=administrator@${domain}
bosh_director_role="BOSH Director"
bosh_director_group="BoshDirectorServiceAccounts"

infra_datastore=vsanDatastore

dns_servers=( "1.1.1.1" "1.0.0.1" "8.8.8.8" )

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
