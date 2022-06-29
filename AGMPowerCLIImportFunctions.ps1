# Copyright 2022 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Function Import-AGMOnVault ([string]$diskpoolid,[string]$applianceid,[string]$appid,[switch][alias("f")]$forget,[switch][alias("o")]$ownershiptakeover,[string]$jsonbody,[string]$label) 
{
    <#
    .SYNOPSIS
    Imports or forgets OnVault images
    There is no Forget-AGMOnvault command.   You perform both import and forget from this function. 

    .EXAMPLE
    Import-AGMOnVault -diskpoolid 20060633 -applianceid 1415019931 

    Imports all OnVault images from disk pool ID 20060633 created by Appliance ID 1415019931

    .EXAMPLE
    Import-AGMOnVault -diskpoolid 20060633 -applianceid 1415019931 -appid 4788
    
    Imports all OnVault images from disk pool ID 20060633 and Source App ID 4788 created by Appliance ID 1415019931

    .EXAMPLE
    Import-AGMOnVault -diskpoolid 20060633 -applianceid 1415019931 -appid 4788 -owner
    
    Imports all OnVault images from disk pool ID 20060633 and Source App ID 4788 created by Appliance ID 1415019931 and takes ownership

    .EXAMPLE
    Import-AGMOnVault -diskpoolid 20060633 -applianceid 1415019931 -appid 4788 -forget
    
    Forgets all OnVault images imported from disk pool ID 20060633 and Source App ID 4788 created by Appliance ID 1415019931

    .DESCRIPTION
    A function to import OnVault images
    Learn Appliance ID with Get-AGMAppliance
    Learn Diskpool ID with Get-AGMDiskPool
    Learn Application ID with Get-AGMApplication and use sources.id

    #>

    if (!($diskpoolid))
    {
        [string]$diskpoolid = Read-Host "Diskpool ID to import from"
    }

    if (!($applianceid))
    {
        [string]$applianceid = Read-Host "Appliance ID to import from"
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


Function Import-AGMPDSnapshot ([string]$diskpoolid,[string]$applianceid,[string]$appid,[switch][alias("f")]$forget,[switch][alias("o")]$ownershiptakeover,[string]$jsonbody,[string]$label) 
{
    <#
    .SYNOPSIS
    Imports or forgets PD Snapshot images
    There is no Import-AGMPDSnapshot command.   You can do import and forget from this function. 

    .EXAMPLE
    Import-AGMPDSnapshot -diskpoolid 20060633 -applianceid 1415019931 

    Imports all PD Snapshot images from disk pool ID 20060633 onto Appliance ID 1415019931

    .EXAMPLE
    Import-AGMPDSnapshot -diskpoolid 20060633 -applianceid 1415019931 -appid 4788
    
    Imports all PD Snapshot images from disk pool ID 20060633 and App ID 4788 onto Appliance ID 1415019931

    .EXAMPLE
    Import-AGMPDSnapshot -diskpoolid 20060633 -applianceid 1415019931 -appid 4788 -owner
    
    Imports all PD Snapshot images from disk pool ID 20060633 and App ID 4788 onto Appliance ID 1415019931 and takes ownership

    .EXAMPLE
    Import-AGMPDSnapshot -diskpoolid 20060633 -applianceid 1415019931 -appid 4788 -forget
    
    Forgets all PD Snapshot images imported from disk pool ID 20060633 and App ID 4788 onto Appliance ID 1415019931

    .DESCRIPTION
    A function to import PD Snapshot images
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
        $endpoint = "/diskpool/$diskpoolid/vaultclusters/$applianceid/$appid" + "?action=$action&owner=$owner&nowait=true&jobclass=1"
        Post-AGMAPIData  -endpoint $endpoint
    }
    else 
    {
        $endpoint = "/diskpool/$diskpoolid/vaultclusters/$applianceid" + "?action=$action&owner=$owner&nowait=true&jobclass=1"
        Post-AGMAPIData  -endpoint $endpoint
    }
}
