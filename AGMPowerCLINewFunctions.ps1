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