variable "bosh_director_role" {
  type = "string"
}

variable "bosh_director_group" {
  type = "string"
}

resource "null_resource" "bosh_director_role" {
  provisioner "local-exec" {
    command = <<COMMAND
govc role.create ${var.bosh_director_role} \
  Datastore.AllocateSpace \
  Datastore.Browse \
  Datastore.DeleteFile \
  Datastore.FileManagement \
  Datastore.UpdateVirtualMachineFiles \
  Datastore.UpdateVirtualMachineMetadata \
  Folder.Create \
  Folder.Delete \
  Folder.Move \
  Folder.Rename \
  Global.ManageCustomFields \
  Global.SetCustomField \
  Host.Inventory.EditCluster \
  Host.Local.CreateVM \
  Host.Local.DeleteVM \
  Host.Local.InstallAgent \
  Host.Local.ManageUserGroups \
  Host.Local.ReconfigVM \
  InventoryService.Tagging.AttachTag \
  InventoryService.Tagging.CreateCategory \
  InventoryService.Tagging.CreateTag \
  InventoryService.Tagging.DeleteCategory \
  InventoryService.Tagging.DeleteTag \
  InventoryService.Tagging.EditCategory \
  InventoryService.Tagging.EditTag \
  InventoryService.Tagging.ModifyUsedByForCategory \
  InventoryService.Tagging.ModifyUsedByForTag \
  Network.Assign \
  Network.Config \
  Network.Delete \
  Network.Move \
  Resource.AssignVMToPool \
  Resource.ColdMigrate \
  Resource.HotMigrate \
  System.Anonymous \
  System.Read \
  System.View \
  VApp.ApplicationConfig \
  VApp.AssignResourcePool \
  VApp.AssignVApp \
  VApp.AssignVM \
  VApp.Clone \
  VApp.Create \
  VApp.Delete \
  VApp.Export \
  VApp.ExtractOvfEnvironment \
  VApp.Import \
  VApp.InstanceConfig \
  VApp.ManagedByConfig \
  VApp.Move \
  VApp.PowerOff \
  VApp.PowerOn \
  VApp.Rename \
  VApp.ResourceConfig \
  VApp.Suspend \
  VApp.Unregister \
  VirtualMachine.Config.AddExistingDisk \
  VirtualMachine.Config.AddNewDisk \
  VirtualMachine.Config.AddRemoveDevice \
  VirtualMachine.Config.AdvancedConfig \
  VirtualMachine.Config.Annotation \
  VirtualMachine.Config.CPUCount \
  VirtualMachine.Config.ChangeTracking \
  VirtualMachine.Config.DiskExtend \
  VirtualMachine.Config.DiskLease \
  VirtualMachine.Config.EditDevice \
  VirtualMachine.Config.HostUSBDevice \
  VirtualMachine.Config.ManagedBy \
  VirtualMachine.Config.Memory \
  VirtualMachine.Config.MksControl \
  VirtualMachine.Config.QueryFTCompatibility \
  VirtualMachine.Config.QueryUnownedFiles \
  VirtualMachine.Config.RawDevice \
  VirtualMachine.Config.ReloadFromPath \
  VirtualMachine.Config.RemoveDisk \
  VirtualMachine.Config.Rename \
  VirtualMachine.Config.ResetGuestInfo \
  VirtualMachine.Config.Resource \
  VirtualMachine.Config.Settings \
  VirtualMachine.Config.SwapPlacement \
  VirtualMachine.Config.ToggleForkParent \
  VirtualMachine.Config.Unlock \
  VirtualMachine.Config.UpgradeVirtualHardware \
  VirtualMachine.GuestOperations.Execute \
  VirtualMachine.GuestOperations.Modify \
  VirtualMachine.GuestOperations.ModifyAliases \
  VirtualMachine.GuestOperations.Query \
  VirtualMachine.GuestOperations.QueryAliases \
  VirtualMachine.Interact.AnswerQuestion \
  VirtualMachine.Interact.Backup \
  VirtualMachine.Interact.ConsoleInteract \
  VirtualMachine.Interact.CreateScreenshot \
  VirtualMachine.Interact.CreateSecondary \
  VirtualMachine.Interact.DefragmentAllDisks \
  VirtualMachine.Interact.DeviceConnection \
  VirtualMachine.Interact.DisableSecondary \
  VirtualMachine.Interact.DnD \
  VirtualMachine.Interact.EnableSecondary \
  VirtualMachine.Interact.GuestControl \
  VirtualMachine.Interact.MakePrimary \
  VirtualMachine.Interact.Pause \
  VirtualMachine.Interact.PowerOff \
  VirtualMachine.Interact.PowerOn \
  VirtualMachine.Interact.PutUsbScanCodes \
  VirtualMachine.Interact.Record \
  VirtualMachine.Interact.Replay \
  VirtualMachine.Interact.Reset \
  VirtualMachine.Interact.SESparseMaintenance \
  VirtualMachine.Interact.SetCDMedia \
  VirtualMachine.Interact.SetFloppyMedia \
  VirtualMachine.Interact.Suspend \
  VirtualMachine.Interact.TerminateFaultTolerantVM \
  VirtualMachine.Interact.ToolsInstall \
  VirtualMachine.Interact.TurnOffFaultTolerance \
  VirtualMachine.Inventory.Create \
  VirtualMachine.Inventory.CreateFromExisting \
  VirtualMachine.Inventory.Delete \
  VirtualMachine.Inventory.Move \
  VirtualMachine.Inventory.Register \
  VirtualMachine.Inventory.Unregister \
  VirtualMachine.Namespace.Event \
  VirtualMachine.Namespace.EventNotify \
  VirtualMachine.Namespace.Management \
  VirtualMachine.Namespace.ModifyContent \
  VirtualMachine.Namespace.Query \
  VirtualMachine.Namespace.ReadContent \
  VirtualMachine.Provisioning.Clone \
  VirtualMachine.Provisioning.CloneTemplate \
  VirtualMachine.Provisioning.CreateTemplateFromVM \
  VirtualMachine.Provisioning.Customize \
  VirtualMachine.Provisioning.DeployTemplate \
  VirtualMachine.Provisioning.DiskRandomAccess \
  VirtualMachine.Provisioning.DiskRandomRead \
  VirtualMachine.Provisioning.FileRandomAccess \
  VirtualMachine.Provisioning.GetVmFiles \
  VirtualMachine.Provisioning.MarkAsTemplate \
  VirtualMachine.Provisioning.MarkAsVM \
  VirtualMachine.Provisioning.ModifyCustSpecs \
  VirtualMachine.Provisioning.PromoteDisks \
  VirtualMachine.Provisioning.PutVmFiles \
  VirtualMachine.Provisioning.ReadCustSpecs \
  VirtualMachine.State.CreateSnapshot \
  VirtualMachine.State.RemoveSnapshot \
  VirtualMachine.State.RenameSnapshot \
  VirtualMachine.State.RevertToSnapshot
COMMAND

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${local.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
    }
  }
}

resource "null_resource" "bosh_director_group" {
  provisioner "remote-exec" {
    inline = [
      "/usr/lib/vmware-vmafd/bin/dir-cli ssogroup create --name ${var.bosh_director_group} --description 'Services accounts for BOSH director installations'"
    ]
    connection {
      type     = "ssh"
      user     = "${var.vsphere_user}"
      password = "${var.vsphere_password}"
      host = "${local.vsphere_fqdn}"
    }
  }

  provisioner "local-exec" {
    command = "govc permissions.set -principal ${var.bosh_director_group} -role ${var.bosh_director_role} --group"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${local.vcenter_user}"
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
    command = "security add-generic-password -a root -s '${local.vsphere_fqdn}' -w '${self.result}' -U"
  }
}

resource "null_resource" "bbl_user" {
  provisioner "remote-exec" {
    inline = [
      "/usr/lib/vmware-vmafd/bin/dir-cli user create --account ${username} --user-password ${random_string.bbl_password.result}",
      "/usr/lib/vmware-vmafd/bin/dir-cli group modify --name ${group} --add ${user}"
    ]
    connection {
      type     = "ssh"
      user     = "${var.vsphere_user}"
      password = "${var.vsphere_password}"
      host = "${local.vsphere_fqdn}"
    }
  }

  depends_on = [ "null_resource.bosh_director_group" ]
}
