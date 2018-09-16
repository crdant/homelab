***Lots more to come here, this is just a quick placeholder***

Start with ESXi on your single host along with a datastore. Also an EdgeRouter X.

1. Run `prepare` to set up GCP and your local working directory.
2. Download the vCenter installer and the BIGIP Virtual Edition installer. Put them in the work directory.
2. Run `router` to prepare the configuration for your EdgeRouter X.
3. Run `vsphere` to prepare your ESXi environment for vCenter and install the vCenter appliance.
4. Run `pave` to prepare vCenter for your installation.
5. Run `bootstrap` to configure a bootstrapping environment with a BOSH deployed cocourse using `bbl` and the standard BOSH install for Concourse.
6. Use `pipelines` to prepare Concourse to deploy your PCF environment.
