Function Set-AGMHost ([string]$hostid,[string]$ipaddress,[string]$friendlyname)
{
    <#
    .SYNOPSIS
    Modifies a host

    .EXAMPLE
    Set-AGMHost -hostid 60111722 -ipaddress 10.0.2.1
    
    Sets the IP address for host ID  60111722 to 10.0.2.1

    .EXAMPLE
    Set-AGMHost -hostid 60111722 -friendlyname jeff
    
    Sets the friendlyname for host ID  60111722 to jeff

    .DESCRIPTION
    A function to modify a host

    #>
    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Get-AGMErrorMessage -messagetoprint "Not logged in or session expired. Please login using Connect-AGM"
        return
    }

    if (!($hostid)) 
    {
        $hostid = Read-Host "Host ID"
    }

    $body = [ordered]@{}
    $body += @{ id = $hostid }
    if ($ipaddress)
    {
        $body += @{ ipaddress = $ipaddress }
    }
    if ($friendlyname)
    {
        $body += @{ friendlypath = $friendlyname }
    }
    $jsonbody = $body | ConvertTo-Json


    
    Put-AGMAPIData  -endpoint /host/$hostid -body $jsonbody


}



Function Set-AGMSLA ([string]$id,[string]$slaid,[string]$appid,[string]$dedupasync,[string]$expiration,[string]$logexpiration,[string]$scheduler) 
{
    <#
    .SYNOPSIS
    Enables or disables an SLA 
    Note that if both an SLA ID and an App ID are supplied, the App ID will be ignored.

    .EXAMPLE
    Set-AGMSLA -slaid 1234 -dedupasync disable 
    
    Disables dedupasync for SLA ID 1234.  

    .EXAMPLE
    Set-AGMSLA -slaid 1234 -expiration disable 
    
    Disables expiration for SLA ID 1234.  

    .EXAMPLE
    Set-AGMSLA -appid 5678 -expiration disable 
    
    Disables expiration for App ID 5678.   

    .EXAMPLE
    Set-AGMSLA -appid 5678 -logexpiration disable 
    
    Disables log expiration for App ID 5678.   

    .EXAMPLE
    Set-AGMSLA -slaid 1234 -scheduler enable 
    
    Enables the scheduler for SLA ID 1234.   

    .EXAMPLE
    Set-AGMSLA -slaid 1234 -scheduler disable 
    
    Disables the scheduler for SLA ID 1234.   


    .DESCRIPTION
    A function to modify an SLA

    #>

    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Get-AGMErrorMessage -messagetoprint "Not logged in or session expired. Please login using Connect-AGM"
        return
    }

    if ($id)
    {
        $slaid = $id
    }

    if (($appid) -and (!($slaid)))
    {
        $slaid = (Get-AGMSLA -filtervalue appid=$appid).id
    }

    if (!($slaid))
    {
        Get-AGMErrorMessage -messagetoprint "No SLA ID or App ID was supplied"
        return
    }

    $body = New-Object -TypeName psobject

    if ($dedupasync.ToLower() -eq "enable"){
        $body | Add-Member -MemberType NoteProperty -Name dedupasyncoff -Value "false"
    }
    if ($dedupasync.ToLower() -eq "disable"){
        $body | Add-Member -MemberType NoteProperty -Name dedupasyncoff -Value "true"
    }

    if ($expiration.ToLower() -eq "enable"){
        $body | Add-Member -MemberType NoteProperty -Name expirationoff -Value "false"
    }
    if ($expiration.ToLower() -eq "disable"){
        $body | Add-Member -MemberType NoteProperty -Name expirationoff -Value "true"
    }

    if ($logexpiration.ToLower() -eq "enable"){
        $body | Add-Member -MemberType NoteProperty -Name logexpirationoff -Value "false"
    }
    if ($logexpiration.ToLower() -eq "disable"){
        $body | Add-Member -MemberType NoteProperty -Name logexpirationoff -Value "true"
    }

    if ($scheduler.ToLower() -eq "enable"){
        $body | Add-Member -MemberType NoteProperty -Name scheduleoff -Value "false"
    }
    if ($scheduler.ToLower() -eq "disable"){
        $body | Add-Member -MemberType NoteProperty -Name scheduleoff -Value "true"
    }

    $jsonbody = $body | ConvertTo-Json


    Put-AGMAPIData  -endpoint /sla/$slaid -body $jsonbody
    }