variable "bosh_director_role" {
  type = "string"
}

variable "bosh_director_group" {
  type = "string"
}

resource "null_resource" "bosh_director_role" {
  provisioner "local-exec" {
    command = <<COMMAND
govc role.create '${var.bosh_director_role}' \
  System.Anonymous \
  System.Read \
  System.View \
  Global.ManageCustomFields \
  StorageProfile.Update \
  StorageProfile.View \
  System.Anonymous \
  System.Read \
  System.View \
  Datastore.AllocateSpace \
  Datastore.Browse \
  Datastore.FileManagement \
  Datastore.DeleteFile \
  Datastore.UpdateVirtualMachineFiles \
  Folder.Delete \
  Folder.Create \
  Folder.Move \
  Folder.Rename \
  Global.SetCustomField \
  Host.Inventory.EditCluster \
  InventoryService.Tagging.CreateTag \
  InventoryService.Tagging.EditTag \
  InventoryService.Tagging.DeleteTag \
  Network.Assign \
  Resource.AssignVMToPool \
  Resource.ColdMigrate \
  Resource.HotMigrate \
  StorageProfile.Update \
  StorageProfile.View \
  VirtualMachine.Config.AddExistingDisk \
  VirtualMachine.Config.AddNewDisk \
  VirtualMachine.Config.AddRemoveDevice \
  VirtualMachine.Config.AdvancedConfig \
  VirtualMachine.Config.CPUCount \
  VirtualMachine.Config.Resource \
  VirtualMachine.Config.ManagedBy \
  VirtualMachine.Config.ChangeTracking \
  VirtualMachine.Config.DiskLease \
  VirtualMachine.Config.MksControl \
  VirtualMachine.Config.DiskExtend \
  VirtualMachine.Config.Memory \
  VirtualMachine.Config.EditDevice \
  VirtualMachine.Config.RawDevice \
  VirtualMachine.Config.ReloadFromPath \
  VirtualMachine.Config.RemoveDisk \
  VirtualMachine.Config.Rename \
  VirtualMachine.Config.ResetGuestInfo \
  VirtualMachine.Config.Annotation \
  VirtualMachine.Config.Settings \
  VirtualMachine.Config.SwapPlacement \
  VirtualMachine.GuestOperations.Execute \
  VirtualMachine.GuestOperations.Modify \
  VirtualMachine.GuestOperations.Query \
  VirtualMachine.Interact.AnswerQuestion \
  VirtualMachine.Interact.SetCDMedia \
  VirtualMachine.Interact.ConsoleInteract \
  VirtualMachine.Interact.DefragmentAllDisks \
  VirtualMachine.Interact.DeviceConnection \
  VirtualMachine.Interact.GuestControl \
  VirtualMachine.Interact.PowerOff \
  VirtualMachine.Interact.PowerOn \
  VirtualMachine.Interact.Reset \
  VirtualMachine.Interact.Suspend \
  VirtualMachine.Interact.ToolsInstall \
  VirtualMachine.Inventory.CreateFromExisting \
  VirtualMachine.Inventory.Create \
  VirtualMachine.Inventory.Move \
  VirtualMachine.Inventory.Register \
  VirtualMachine.Inventory.Delete \
  VirtualMachine.Inventory.Unregister \
  VirtualMachine.Provisioning.DiskRandomAccess \
  VirtualMachine.Provisioning.DiskRandomRead \
  VirtualMachine.Provisioning.GetVmFiles \
  VirtualMachine.Provisioning.PutVmFiles \
  VirtualMachine.Provisioning.CloneTemplate \
  VirtualMachine.Provisioning.Clone \
  VirtualMachine.Provisioning.Customize \
  VirtualMachine.Provisioning.DeployTemplate \
  VirtualMachine.Provisioning.MarkAsTemplate \
  VirtualMachine.Provisioning.MarkAsVM \
  VirtualMachine.Provisioning.ModifyCustSpecs \
  VirtualMachine.Provisioning.PromoteDisks \
  VirtualMachine.Provisioning.ReadCustSpecs \
  VirtualMachine.State.CreateSnapshot \
  VirtualMachine.State.RemoveSnapshot \
  VirtualMachine.State.RenameSnapshot \
  VirtualMachine.State.RevertToSnapshot \
  VApp.Import \
  VApp.ApplicationConfig
COMMAND

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
    }
  }
}

resource "null_resource" "bosh_director_group" {
/*
  provisioner "remote-exec" {
    inline = [
      "/usr/lib/vmware-vmafd/bin/dir-cli ssogroup create --name ${var.bosh_director_group} --description 'Services accounts for BOSH director installations'\""
    ]

    connection {
      type     = "ssh"
      user     = "${data.terraform_remote_state.vsphere.vcenter_user}"
      password = "${data.terraform_remote_state.vsphere.vcenter_password}"
      host = "${local.vcenter_fqdn}"
    }
  }
*/
  provisioner "local-exec" {
    command = "govc permissions.set -principal ${var.bosh_director_group}@${var.domain} -role '${var.bosh_director_role}' --group"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
    }
  }

  depends_on = [ "null_resource.bosh_director_role" ]
}

resource "random_string" "bbl_password" {
  length = 20
  min_upper = 1
  min_lower = 1
  min_numeric = 1
  min_special = 1
  override_special = "!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"

  provisioner "local-exec" {
    command = "security add-generic-password -a 'bbl@crdant.net' -s '${local.vcenter_fqdn} BOSH Bootloader Service Account' -w '${self.result}' -U"
  }
}

resource "null_resource" "bbl_user" {
  provisioner "local-exec" {
    command = "govc sso.user.create -p '${random_string.bbl_password.result}' bbl"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
    }
  }
/*
  provisioner "remote-exec" {
    inline = [
      "/usr/lib/vmware-vmafd/bin/dir-cli group modify --name ${var.bosh_director_group} --add bbl"
    ]
    connection {
      type     = "ssh"
      user     = "${data.terraform_remote_state.vsphere.vcenter_user}"
      password = "${data.terraform_remote_state.vsphere.vcenter_password}"
      host = "${local.vcenter_fqdn}"
    }
  }
*/
  depends_on = [ "null_resource.bosh_director_group" ]
}

output "bbl_password" {
  value = "${random_string.bbl_password.result}"
}
