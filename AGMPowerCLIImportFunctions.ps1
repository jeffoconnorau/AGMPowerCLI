Function Import-AGMOnVault ([string]$diskpoolid,[string]$applianceid,[string]$appid,[switch][alias("f")]$forget,[switch][alias("o")]$ownershiptakeover,[string]$jsonbody,[string]$label) 
{
    <#
    .SYNOPSIS
    Imports or forgets OnVault images
    There is no Forget-AGMOnvault command.   You can do import and forget from this function. 

    .EXAMPLE
    Import-AGMOnVault -diskpoolid 20060633 -applianceid 1415019931 

    Imports all OnVault images from disk pool ID 20060633 onto Appliance ID 1415019931

    .EXAMPLE
    Import-AGMOnVault -diskpoolid 20060633 -applianceid 1415019931 -appid 4788
    
    Imports all OnVault images from disk pool ID 20060633 and App ID 4788 onto Appliance ID 1415019931

    .EXAMPLE
    Import-AGMOnVault -diskpoolid 20060633 -applianceid 1415019931 -appid 4788 -owner
    
    Imports all OnVault images from disk pool ID 20060633 and App ID 4788 onto Appliance ID 1415019931 and takes ownership

    .EXAMPLE
    Import-AGMOnVault -diskpoolid 20060633 -applianceid 1415019931 -appid 4788 -forget
    
    Forgets all OnVault images imported from disk pool ID 20060633 and App ID 4788 onto Appliance ID 1415019931

    .DESCRIPTION
    A function to import OnVault images
    Learn Appliance ID with Get-AGMAppliance
    Learn Diskpool ID with Get-AGMDiskPool
    Learn Application ID with Get-AGMApplication

    #>

    if (!($diskpoolid))
    {
        [string]$diskpoolid = Read-Host "Diskpool ID to import from"
    }

    if (!($applianceid))
    {
        [string]$applianceid = Read-Host "Appliance ID to import into"
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
        $endpoint = "/diskpool/$diskpoolid/vaultclusters/$applianceid/$appid" + "?action=$action&owner=$owner&nowait=true"
        Post-AGMAPIData  -endpoint $endpoint
    }
    else 
    {
        $endpoint = "/diskpool/$diskpoolid/vaultclusters/$applianceid" + "?action=$action&owner=$owner&nowait=true"
        Post-AGMAPIData  -endpoint $endpoint
    }
}
