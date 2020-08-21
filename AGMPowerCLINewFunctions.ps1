Function New-AGMMount ([int]$imageid,[int]$targethostid,[string]$jsonbody,[string]$label) 
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
        [int]$imageid = Read-Host "ImageID to mount"
    }

    if ( (!($jsonbody)) -and (!($targethostid)) )
    {
        [int]$targethostid = Read-Host "Target host ID to mount $imageid to"
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



Function New-AGMSLA ([int]$appid,[int]$slpid,[int]$sltid,[string]$jsonbody,[string]$scheduler) 
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