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


#region for Private script functions
    #-- note: place any specific function in this region

    function exit-script {
        <#
        .DESCRIPTION
            Clean up actions before we exit the script.
        .PARAMETER unloadCcModule
            [switch] Unload the CC-function module
        .PARAMETER defaultcleanupcode
            [scriptblock] Unique code to invoke when exiting script.
        #>
        [CmdletBinding()]
        param()

        #-- check why script is called and react apropiatly
        if ($finished_normal) {
            $msg= "Hooray.... finished without any bugs....."
            if ($log) {$log.verbose($msg)} else {Write-Verbose $msg}
        } else {
            $msg= "(1) Script ended with errors."
            if ($log) {$log.error($msg)} else {Write-Error $msg}
        }

        #-- General cleanup actions
        #-- disconnect vCenter connections if they exist
        if (Get-Variable -Scope global -Name DefaultVIServers -ErrorAction SilentlyContinue ) {
            Disconnect-VIServer -server * -Confirm:$false
        }
        #-- Output runtime and say greetings
        $ts_end=get-date
        $msg="Runtime script: {0:hh}:{0:mm}:{0:ss}" -f ($ts_end- $ts_start)  
        write-host $msg
        read-host "The End <press Enter to close window>."
        exit
    }

    function import-PowerCLI {
    <#
    .SYNOPSIS
       Loading of all VMware modules and power snapins
    .DESCRIPTION
  
    .EXAMPLE
        One or more examples for how to use this script
    .NOTES
        File Name          : import-PowerCLI.ps1
        Author             : Bart Lievers
        Prerequisite       : <Preruiqisites like
                             Min. PowerShell version : 2.0
                             PS Modules and version : 
                                PowerCLI - 6.0 R2
        Version/GIT Tag    : 1.0.0
        Last Edit          : BL - 3-1-2016
        CC-release         : 
        Copyright 2016 - CAM IT Solutions
    #>
    [CmdletBinding()]

    Param(
    )

    Begin{
 
    }

    Process{
        #-- make up inventory and check PowerCLI installation
        $RegisteredModules=Get-Module -Name vmware* -ListAvailable -ErrorAction ignore | % {$_.Name}
        $RegisteredSnapins=get-pssnapin -Registered vmware* -ErrorAction Ignore | %{$_.name}
        if (($RegisteredModules.Count -eq 0 ) -and ($RegisteredSnapins.count -eq 0 )) {
            #-- PowerCLI is not installed
            if ($log) {$log.warning("Cannot load PowerCLI, no VMware Powercli Modules and/or Snapins found.")}
            else {
            write-warning "Cannot load PowerCLI, no VMware Powercli Modules and/or Snapins found."}
            #-- exit function
            return $false
        }

        #-- load modules
        if ($RegisteredModules) {
            #-- make inventory of already loaded VMware modules
            $loaded = Get-Module -Name vmware* -ErrorAction Ignore | % {$_.Name}
            #-- make inventory of available VMware modules
            $registered = Get-Module -Name vmware* -ListAvailable -ErrorAction Ignore | % {$_.Name}
            #-- determine which modules needs to be loaded, and import them.
            $notLoaded = $registered | ? {$loaded -notcontains $_}

            foreach ($module in $registered) {
                if ($loaded -notcontains $module) {
                    Import-Module $module
                }
            }
        }

        #-- load Snapins
        if ($RegisteredSnapins) {      
            #-- Exlude loaded modules from additional snappins to load
            $snapinList=Compare-Object -ReferenceObject $RegisteredModules -DifferenceObject $RegisteredSnapins | ?{$_.sideindicator -eq "=>"} | %{$_.inputobject}
            #-- Make inventory of loaded VMware Snapins
            $loaded = Get-PSSnapin -Name $snapinList -ErrorAction Ignore | % {$_.Name}
            #-- Make inventory of VMware Snapins that are registered
            $registered = Get-PSSnapin -Name $snapinList -Registered -ErrorAction Ignore  | % {$_.Name}
            #-- determine which snapins needs to loaded, and import them.
            $notLoaded = $registered | ? {$loaded -notcontains $_}

            foreach ($snapin in $registered) {
                if ($loaded -notcontains $snapin) {
                    Add-PSSnapin $snapin
                }
            }
        }
        #-- show loaded vmware modules and snapins
        if ($RegisteredModules) {get-module -Name vmware* | select name,version,@{N="type";E={"module"}} | ft -AutoSize}
          if ($RegisteredSnapins) {get-pssnapin -Name vmware* | select name,version,@{N="type";E={"snapin"}} | ft -AutoSize}

    }


    End{

    }



#endregion
}
}

Process{
#-- note: area to write script code.....
    import-powercli
    if(Connect-VIServer $p.vCenter) {
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