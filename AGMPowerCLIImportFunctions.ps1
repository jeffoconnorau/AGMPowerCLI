Function Import-AGMOnVault ([int]$diskpool,[int]$applianceid,[int]$appid,[switch][alias("f")]$forget,[switch][alias("o")]$ownershiptakeover,[string]$jsonbody,[string]$label) 
{
    <#
    .SYNOPSIS
    Imports or forgets OnVault images
    There is no Forget-AGMOnvault command.   You can do import and forget from this function. 

    .EXAMPLE
    Import-AGMOnVault -diskpool 20060633 -applianceid 1415019931 

    Imports all OnVault images from disk pool 20060633 onto appliance ID 1415019931

    .EXAMPLE
    Import-AGMOnVault -diskpool 20060633 -applianceid 1415019931 -appid 4788
    
    Imports all OnVault images from disk pool 20060633 and appid 4788 onto appliance ID 1415019931

    .EXAMPLE
    Import-AGMOnVault -diskpool 20060633 -applianceid 1415019931 -appid 4788 -owner
    
    Imports all OnVault images from disk pool 20060633 and appid 4788 onto appliance ID 1415019931 and takes ownership

    .EXAMPLE
    Import-AGMOnVault -diskpool 20060633 -applianceid 1415019931 -appid 4788 -forget
    
    Forgets all OnVault images imported from disk pool 20060633 and appid 4788 onto appliance ID 1415019931

    .DESCRIPTION
    A function to import OnVault images
    Learn Appliance ID with Get-AGMAppliance
    Learn Diskpool ID with Get-AGMDiskPool
    Learn Application ID with Get-AGMApplication

    #>

    if (!($diskpool))
    {
        [int]$diskpool = Read-Host "Diskpool to import from"
    }

    if (!($applianceid))
    {
        [int]$applianceid = Read-Host "ApplianceID to import into"
    }

    if ($ownershiptakeover)
    {
        $owner="true"
    }
    else 
    {
        $owner="false"
    }

    if ($forget)
    {
        $action = "forget"
    }
    else 
    {
        $action = "import"
    }


    if($appid)
    {   
        Post-AGMAPIData  -endpoint /diskpool/$diskpool/vaultclusters/$applianceid/$appid?action=$action&owner=$owner&nowait=true
    }
    else 
    {
        Post-AGMAPIData  -endpoint /diskpool/$diskpool/vaultclusters/$applianceid?action=$action&owner=$owner&nowait=true
    }
}
