<#
.SYNOPSIS
   Create custom vCenter Roles
.DESCRIPTION
   Create custom vCenter Roles by vCenter roles defined in parameters.ps1
   If the role already exists the script asks if it is allowed to continue.
   If allowed, script will remove the existing rule and re-create it
.EXAMPLE
    One or more examples for how to use this script
.NOTES
    File Name          : create-CustomViRole.ps1
    Author             : Bart Lievers
    Prerequisite       : Min. PowerShell version : 2.0
                            PowerCLI - 6.5 R2
    Version/GIT Tag    : develop/v0.0.5
    Last Edit          : BL - 7-12-2016
    Copyright 2016 - CAM IT Solutions
#>
[CmdletBinding()]

Param(
    #-- Define Powershell input parameters (optional)
    [string]$text

)

Begin{
    #-- initialize environment
    $DebugPreference="SilentlyContinue"
    $VerbosePreference="SilentlyContinue"
    $ErrorActionPreference="Continue"
    $WarningPreference="Continue"
    clear-host #-- clear CLi
    $ts_start=get-date #-- note start time of script
    if ($finished_normal) {Remove-Variable -Name finished_normal -Confirm:$false }

	#-- determine script location and name
	$scriptpath=get-item (Split-Path -parent $MyInvocation.MyCommand.Definition)
	$scriptname=(Split-Path -Leaf $MyInvocation.mycommand.path).Split(".")[0]

    #-- Load Parameterfile
    if (!(test-path -Path $scriptpath\parameters.ps1 -IsValid)) {
        write-warning "parameters.ps1 niet gevonden. Script kan niet verder."
        exit
    } 
    $P = & $scriptpath\parameters.ps1

    #-- load functions
    import-module $scriptpath\functions\functions.psm1 #-- the module scans the functions subfolder and loads them as functions
    #-- add code to execute during exit script. Removing functions module
    $p.Add("cleanUpCodeOnExit",{remove-module -Name functions -Force -Confirm:$false})


#region for Private script functions
    #-- note: place any specific function in this region

   



#endregion
}

Process{
#-- note: area to write script code.....
    import-powercli
    if(connect-viserver $p.vcenter) {
        write-host "Connected to vCenter"
    }else {
        write-host "Verbinding naar vCenter mislukt."
        exit-script
    }

    $p.Roles.GetEnumerator() | %{
        $role=$_.value

        #-- Create new role
        if ((Get-VIRole | ?{$_.name -ilike $role.name} ) -ne $null) {
            do {
                 $action = Read-Host ("Waarschuwing !! Er bestaat al een "+ $role.name+ " rol. Doorgaan ? [N/j]")
                 switch ($action) {
                    "" {
                        #-- Geen input gegeven, dus gebruik default
                        $action="N"
                        break        
                        }
                    "Y|y|j|J" {
                        break        
                        }
                    "[^yYjJnN]" {
                        write-host "Onbekende input"
                        break
                        } 
                 }
            }
            while ( $action -eq $null -or $action -notmatch "j|J|y|Y|n|N")
            if ($action -match "n|N") {   
                $finished_normal=$true
                exit-script
            }
            Remove-VIRole $role.name -Confirm:$false | Out-Null
        }
        New-VIRole -name $role.name -Confirm:$false | Out-Null
        write-host ($role.Name + " is aangemaakt.")

        $i=0
        $role.privileges | %{ 
            $i++
            $privilege=$_
            Set-VIRole -Role $role.name -AddPrivilege (Get-VIPrivilege -id $privilege)| Out-Null
            Write-Progress -Activity ("Configure "+$role.name+" role") -Status $_ -PercentComplete (($i/$role.privileges.count)*100)
            }
        #list privileges of rule
        Write-host "Privileges toegevoegd. Deze zijn: "
        (Get-VIRole -Name $role.name).privilegelist | ft -AutoSize
        }
}

End{
    #-- we made it, exit script.
    $finished_normal=$true
    exit-script
}