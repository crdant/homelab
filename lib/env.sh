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
cloud_config_dir="${BASEDIR}/cloud-config"
pipelines_dir="${BASEDIR}/pipelines"

# GCP for configuration remote state and DNS
project=crdant-net
account=chuck@crdant.io
service_account_name=homelab
service_account="${service_account_name}@${project}.iam.gserviceaccount.com"
key_file="${key_dir}/${service_account}.json"
statefile_bucket=homelab-oozy-virus-raze-utah
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

# some golang CLI tools still not accepting Let's Encrypt certs
ca_cert_file="${key_dir}/letsencrypt.pem"

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

# concourse
concourse_stemcell_os=ubuntu-xenial
concourse_stemcell_version=97.15
concourse_stemcell_sha=f3fa12c62892de8df5d404a6fb0875a3fb340569
concourse_main_github_user=crdant
concourse_main_github_org=FlyingMist

# PCF configuration
om_datastore=vsanDatastore
om_host_name=manager
om_ip_address=$(dig +short ${om_host_name}.${subdomain})
director_host_name=director
om_admin_user=arceus
pcf_datastore=vsanDatastore

# leverage the env_id from BBL
if [ -f "${state_dir}/bbl-state.json" ] ; then
  env_id=`bbl env-id --state-dir ${state_dir}`
fi

# leverage the various YML files BBL creates to add environment variables
bbl_vars_entries="$(cat ${state_dir}/vars/*.yml 2> /dev/null | sort | uniq )"
variables=( uaa_admin_client_secret concourse_url concourse_main_local_user concourse_main_local_password concourse_pcf_local_user concourse_pcf_local_password om_install_pipeline om_upgrade_pipeline )
regex="$(printf "^%s\|" ${variables[@]})"
regex="${regex%??}"
if [ -n "${bbl_vars_entries}" ] ; then
  set +e
  bbl_vars=$(echo "${bbl_vars_entries}" | grep "$regex" | sed -e 's/:[^:\/\/]/="/;' | sed -e 's/$/"/;')
  set -e
  if [ -n "${bbl_vars}" ] ; then
    eval "${bbl_vars}"
  fi
  short_id=${short_env_id}
fi
