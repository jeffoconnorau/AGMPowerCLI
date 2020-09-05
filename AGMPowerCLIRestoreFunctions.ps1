Function Restore-AGMApplication ([string]$imageid,[string]$jsonbody) 
{
    <#
    .SYNOPSIS
    Restores an application using a nominated image ID

    .EXAMPLE
    Restore-AGMApplication -id 1234 

    Uses image ID 1234 to restore the relevant application (the application that created that image)


    .DESCRIPTION
    A function to restore Applications

    #>

    if (!($imageid))
    {
        [string]$imageid = Read-Host "Image ID to use for the restore"
    }

    if (!($jsonbody))
    {
        $jsonbody = '{"@type":"restoreRest","poweronvm":true,"recover":true,"migratevm":false,"notdisableschedule":true}'
    }

    $endpoint = "/backup/$imageid/restore"
    Post-AGMAPIData  -endpoint $endpoint -jsonbody $jsonbody
}
