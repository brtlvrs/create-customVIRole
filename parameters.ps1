# Script Parameters for create-CustomViRole.ps1
<#
    Author             : Bart Lievers
    Last Edit          : BL - 7-12-2016
    Copyright 2015 - CAM IT Solutions
#>

@{
    #-- vSphere vCenter FQDN
        vCenter="000-srv-vmvc-01.paas.camcube.nl" #-- description of param1

    #-- vCenter roles to create
    Roles = @{
        XenDesktopRole=@{
            Name="XenDesktopRoleDemo"
            Privileges=@(
	            "Datastore.AllocateSpace",
	            "Datastore.Browse",
	            "Datastore.FileManagement",
	            "Network.Assign",
	            "Resource.AssignVMToPool",
	            "Task.Create",
	            "VirtualMachine.Config.AddRemoveDevice",
	            "VirtualMachine.Config.AddExistingDisk",
	            "VirtualMachine.Config.AddNewDisk",
	            "VirtualMachine.Config.Advancedconfig",
	            "VirtualMachine.Config.CPUCount",
	            "VirtualMachine.Config.EditDevice",
	            "VirtualMachine.Config.Memory",
	            "VirtualMachine.Config.RemoveDisk",
	            "VirtualMachine.Config.Resource",
	            "VirtualMachine.Config.Settings",
	            "VirtualMachine.Interact.SetCDMedia",
	            "VirtualMachine.Interact.DeviceConnection",
	            "virtualmachine.interact.PowerOff",
	            "virtualmachine.interact.PowerOn",
	            "virtualmachine.interact.Reset",
	            "virtualmachine.interact.Suspend",
	            "VirtualMachine.Inventory.Create",
	            "VirtualMachine.Inventory.CreateFromExisting",
	            "VirtualMachine.Inventory.Delete",
	            "VirtualMachine.Inventory.Register",
	            "VirtualMachine.Provisioning.Clone",
	            "VirtualMachine.Provisioning.DiskRandomAccess",
	            "VirtualMachine.Provisioning.GetVmFiles",
	            "VirtualMachine.Provisioning.PutVmFiles",
	            "VirtualMachine.Provisioning.DeployTemplate",
	            "VirtualMachine.Provisioning.MarkAsVM",
	            "VirtualMachine.State.CreateSnapshot",
	            "VirtualMachine.State.RemoveSnapshot",
	            "VirtualMachine.State.RevertToSnapshot",
	            "Global.ManageCustomFields",
	            "Global.SetCustomField")
            }
        }
}