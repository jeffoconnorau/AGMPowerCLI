Function Start-AGMMigrate ([string]$imageid,[switch][alias("f")]$finalize) 
{
    <#
    .SYNOPSIS
    Starts a migration job 

    .EXAMPLE
    Start-AGMMigrate 
    You will be prompted for ImageID

    .EXAMPLE
    Start-AGMMigrate -imageid 56072427 

    Runs a migration job for Image ID 56072427

        .EXAMPLE
    Start-AGMMigrate -imageid 56072427 -finalize

    Runs a Finalize job for Image ID 56072427

    .DESCRIPTION
    A function to run migration jobs 

    #>

    if (!($imageid))
    {
        $imageid = Read-host "Image ID"
    }
    if (!($imageid))
    {
        Get-AGMErrorMessage -messagetoprint "No Image ID was supplied"
        return
    }

    if ($finalize)
    {
        $body = [ordered]@{}
        $body += @{ action = "finalize" }
        $json = $body | ConvertTo-Json
        Post-AGMAPIData  -endpoint /backup/$imageid/migrate -body $json
    }
    else {
        Post-AGMAPIData  -endpoint /backup/$imageid/migrate 
    }

}