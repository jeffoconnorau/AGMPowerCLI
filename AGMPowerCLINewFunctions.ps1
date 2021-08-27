Function New-AGMAppDiscovery ([string]$hostid,[string]$ipaddress,[string]$applianceid) 
{
    <#
    .SYNOPSIS
    Runs discovery against a host 

    .EXAMPLE
    New-AGMAppDiscovery -hostid 5678 -applianceid 1415071155
    
    Runs application discovery against the host with ID 5678 for appliance with ID 1415071155

    .DESCRIPTION
    A function to run application discovery

    #>

    if ((!($hostid)) -and (!($ipaddress)))
    {
        [string]$hostid = Read-Host "Host to perform discovery on (press enter to use IP)"
        if (!($hostid))
        {
            [string]$ipaddress = Read-Host "Host IP perform discovery on"
        }
    }
    
    if (!($applianceid))
    {
        [string]$applianceid = Read-Host "Appliance to perform discovery on"
    }
    
    if ($hostid)
    {
        $body = [ordered]@{
            host = [ordered]@{
                id=$hostid
                sources= @(
                    @{ 
                        clusterid=$applianceid
                    }
                )
            }
        }
    }
    if ($ipaddress)
    {
        $body = [ordered]@{
            cluster=$applianceid;
            type="standard";
            ipaddress=$ipaddress
        }
    }

    $jsonbody = $body | ConvertTo-Json -depth 4

    Post-AGMAPIData  -endpoint /host/discover -body $jsonbody
}

Function New-AGMCloudVM ([string]$zone,[string]$id,[string]$credentialid,[string]$clusterid,[string]$applianceid,[string]$projectid,[string]$instanceid) 
{
    <#
    .SYNOPSIS
    Adds new Cloud VMs

    .EXAMPLE
    New-AGMCloudVM -credentialid 1234 -zone australia-southeast1-c -applianceid 144292692833 -instanceid 4240202854121875692

    Adds VM with ID 4240202854121875692 to specified appliance 

    .DESCRIPTION
    A function to add Cloud VMs
    Multiple vmids should be comma separated

    #>

    if ($id) { $credentialid = $id }
    if (!($credentialid))
    {
        [string]$credentialid = Read-Host "Credential ID"
    }
    
    if ($applianceid) { [string]$clusterid = $applianceid}

    if (!($clusterid))
    {
        $clusterid = Read-Host "Cluster ID"
    }
    if (!($projectid))
    {
        [string]$projectid = Read-Host "Project ID"
    }   

    #if user doesn't specify name and zone, then learn them
    $credentialgrab = Get-AGMCredential -credentialid $credentialid
    if (!($credentialgrab.id))
    {
        Get-AGMErrorMessage -messagetoprint "The credential ID $credentialid could not be found."
        return
    } else {
        if (!($zone))
        {
            $zone = $credentialgrab.region
        }
    }

    if (!($zone))
    {
        [string]$zone = Read-Host "Zone Name"
    } 
    if (!($instanceid))
    {
        [string]$instanceid = Read-Host "Instance IDs (Comma separated)"
    } 

    $cluster = @{ clusterid = $clusterid}
    $body = [ordered]@{}
    $body += @{ cluster = $cluster;
    region = $zone;
    listonly = $false;
    vmids = $($instanceid.Split(","))
    project = $projectid;
    }
    $json = $body | ConvertTo-Json
    
    Post-AGMAPIData  -endpoint /cloudcredential/$credentialid/discovervm/addvm -body $json -limit $limit
}

Function New-AGMCredential ([string]$name,[string]$zone,[string]$clusterid,[string]$applianceid,$filename,[string]$projectid) 
{
    <#
    .SYNOPSIS
    Creates a cloud credential

    .EXAMPLE
    New-AGMCredential -name cred1 -zone australia-southeast1-c -clusterid 144292692833 -filename keyfile.json
    

    .DESCRIPTION
    A function to create cloud credentials

    #>

    if (!($name))
    {
        [string]$name = Read-Host "Credential Name"
    }
    if (!($zone))
    {
        [string]$zone = Read-Host "Default zone"
    }
    if ($applianceid) { [string]$clusterid = $applianceid}
    if (!($clusterid))
    {
        [string]$clusterid = Read-Host "Cluster IDs (comma separated)"
    }
    if (!($filename))
    {
        $filename = Read-Host "JSON key file"
    }
    if ( Test-Path $filename )
    {
        $jsonkey = Get-Content -Path $filename -raw
        $jsonkey = $jsonkey.replace("\n","\\n")
        $jsonkey = $jsonkey.replace("`n","\n ")
        $jsonkey = $jsonkey.replace('"','\"')
    }
    else
    {
        Get-AGMErrorMessage -messagetoprint "The file named $filename could not be found."
        return
    }

    if (!($projectid))
    {
        $jsongrab = Get-Content -Path $filename | ConvertFrom-Json
        if (!($jsongrab.project_id))
        {
            Get-AGMErrorMessage -messagetoprint "The file named $filename does not contain a valid project ID."
            return
        } else {
            $projectid = $jsongrab.project_id
        }
    }   

    $sources = ""
    foreach ($cluster in $clusterid.Split(","))
    {
        $sources = $sources +',{"clusterid":"' +$cluster +'"}'
    }
    $sources = $sources.substring(1)

    $json = '{"name":"' +$name +'","cloudtype":"GCP","region":"' +$zone +'","endpoint":"","credential":"'
    $json = $json + $jsonkey
    $json = $json +'","orglist":[],"projectid":"' +$projectid +'",'
    $json = $json +'"sources":[' +$sources +']}'

    $testcredential = Post-AGMAPIData  -endpoint /cloudcredential/testconnection -body $json
    if ($testcredential.errors)
    {
        $testcredential
        return
    }

    $json = '{"name":"' +$name +'","cloudtype":"GCP","region":"' +$zone +'","endpoint":"","credential":"'
    $json = $json + $jsonkey
    $json = $json +'","orglist":[],'
    $json = $json +'"sources":[' +$sources +']}'

    Post-AGMAPIData  -endpoint /cloudcredential -body $json
}



Function New-AGMMount ([string]$imageid,[string]$targethostid,[string]$jsonbody,[string]$label) 
{
    <#
    .SYNOPSIS
    Mounts an Image

    .EXAMPLE
    New-AGMMount -imageid 1234 -targethostid 5678
    
    Mounts image ID 1234 to target host with ID 5678

    .EXAMPLE
    New-AGMMount -imageid 53776703 -jsonbody '{"@type":"mountRest","label":"test mount","host":{"id":"43673548"},"poweronvm":false,"migratevm":false}'
    
    Mounts image ID 53776703 to target host with ID 43673548 with Label "test mount".
    The jsonbody field needs to be well formed JSON.   You can get this by running a mount job in the AGM GUI and then immediately displaying the audit log with:
    Get-AGMAudit -filtervalue "command~POST https" -limit 1 -sort id:desc

    .DESCRIPTION
    A function to mount an Image

    #>

    if (!($imageid))
    {
        [string]$imageid = Read-Host "ImageID to mount"
    }

    if ( (!($jsonbody)) -and (!($targethostid)) )
    {
        [string]$targethostid = Read-Host "Target host ID to mount $imageid to"
        if (!($label))
        {
            [string]$label = Read-Host "Label to apply to newly mounted image"
        }
    }
    if ($targethostid)
    {
        $body = @{
            label = $label;
            host = @{id=$targethostid}
        }
        $jsonbody = $body | ConvertTo-Json
    }

    Post-AGMAPIData  -endpoint /backup/$imageid/mount -body $jsonbody
}



Function New-AGMSLA ([string]$appid,[string]$slpid,[string]$sltid,[string]$jsonbody,[string]$scheduler) 
{
    <#
    .SYNOPSIS
    Creates an SLA

    .EXAMPLE
    New-AGMSLA -appid 1234 -sltid 5678 -slpid 9012 -scheduler disabled
    
    Creates a new SLA using APPID, SLT ID and SLP ID with scheduler disabled.   
    Details about the new SLA will be returned.
    The scheduler is disabled so options can be set.  
    You can enable the scheduler with  Set-AGMSLA
    If no options are needed, you don't need to specify scheduler state

    .DESCRIPTION
    A function to create an SLA

    #>

    if (($id) -and (!($appid)) )
    {
        $appid = $id
    }
    if (!($sltid))
    {
        $sltid = Read-Host "SLT ID"
    }
    if (!($slpid))
    {
        $slpid = Read-Host "SLP ID"
    }
   

    if (!($jsonbody)) 
    {

        $application = New-Object -TypeName psobject
        $application | Add-Member -MemberType NoteProperty -Name id -Value $appid

        $slp = New-Object -TypeName psobject
        $slp | Add-Member -MemberType NoteProperty -Name id -Value $slpid
        
        $slt = New-Object -TypeName psobject
        $slt | Add-Member -MemberType NoteProperty -Name id -Value $sltid
        
        $body = New-Object -TypeName psobject
        $body | Add-Member -MemberType NoteProperty -name application -Value $application

        if (!($scheduler))
        {
            $body | Add-Member -MemberType NoteProperty -Name scheduleoff -Value "false"
        }

        if ($scheduler.ToLower() -eq "enable")
        {
            $body | Add-Member -MemberType NoteProperty -Name scheduleoff -Value "false"
        }
        if ($scheduler.ToLower() -eq "disable")
        {
            $body | Add-Member -MemberType NoteProperty -Name scheduleoff -Value "true"
        }
        $body | Add-Member -MemberType NoteProperty -name slp -Value $slp
        $body | Add-Member -MemberType NoteProperty -name slt -Value $slt

        $jsonbody = $body | ConvertTo-Json
    }

    Post-AGMAPIData  -endpoint /sla -body $jsonbody
}