Function Get-AGMAPIData ([String]$filtervalue,[String]$keyword, [string]$search, [int]$timeout, $endpoint,[switch][alias("o")]$options,[string]$datefields,[int]$limit,[string]$sort)
{
    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Get-AGMErrorMessage -messagetoprint "Not logged in or session expired. Please login using Connect-AGM"
        return
    }

    if (!($endpoint))
    {
        $endpoint = Read-Host "AGM End point"
    }

    if ($endpoint[0] -ne "/")
    {
        $endpoint = "/" + $endpoint
    }

    if ($filtervalue) 
    {
        $fv = ""
        $andsep = $filtervalue.Split("&") -notmatch '^\s*$'
        foreach ($line in $andsep) 
        {
            # remove any whitespace at the end
            $trimm = $line.TrimEnd()
            $secondwordequals = $trimm.Split("=") | Select -skip 1
            $secondwordgreater = $trimm.Split(">") | Select -skip 1
            $secondwordlesser = $trimm.Split("<") | Select -skip 1
            $secondwordfuzzy = $trimm.Split("~") | Select -skip 1
            if ($secondwordequals)
            {
                $firstword = $trimm.Split("=") | Select -First 1
                if ($datefields)
                {
                    foreach ($field in $datefields.Split(","))
                    {
                        if ($field -eq $firstword)
                        {
                            $secondwordequals = Convert-ToUnixDate $secondwordequals
                        }
                    }
                }
                $fv = $fv + "&filter=" + $firstword + ":==" + [System.Web.HttpUtility]::UrlEncode($secondwordequals)
            }
            elseif ($secondwordgreater)
            {
                $firstword = $trimm.Split(">") | Select -First 1
                if ($datefields)
                {
                    foreach ($field in $datefields.Split(","))
                    {
                        if ($field -eq $firstword)
                        {
                            $secondwordgreater = Convert-ToUnixDate $secondwordgreater
                        }
                    }
                }
                $fv = $fv + "&filter=" + $firstword + ":>=" + [System.Web.HttpUtility]::UrlEncode($secondwordgreater)
            }
            elseif ($secondwordlesser)
            {
                $firstword = $trimm.Split("<") | Select -First 1
                if ($datefields)
                {
                    foreach ($field in $datefields.Split(","))
                    {
                        if ($field -eq $firstword)
                        {
                            $secondwordlesser = Convert-ToUnixDate $secondwordlesser
                        }
                    }
                }
                $fv = $fv + "&filter=" + $firstword + ":<=" + [System.Web.HttpUtility]::UrlEncode($secondwordlesser)
            }
            elseif ($secondwordfuzzy)
            {
                $firstword = $trimm.Split("~") | Select -First 1
                if ($datefields)
                {
                    foreach ($field in $datefields.Split(","))
                    {
                        if ($field -eq $firstword)
                        {
                            $secondwordfuzzy = Convert-ToUnixDate $secondwordfuzzy
                        }
                    }
                }
                $fv = $fv + "&filter=" + $firstword + ":=|" + [System.Web.HttpUtility]::UrlEncode($secondwordfuzzy)
            }
        }
        #$fv
    }
    else
    {
        $fv = ""
    }

    if ($keyword)
    {
        $kw = ""
        $andsep = $keyword.Split("&") -notmatch '^\s*$'
        foreach ($line in $andsep) 
        {
            # remove any whitespace at the end
            $trimm = $line.TrimEnd()
            if ($trimm)
            {
                $kw = $kw + "&keyword=" + [System.Web.HttpUtility]::UrlEncode($trimm)
            }
        }
    }
    else
    {
        $kw = ""
    }

    if ($sort)
    {
        $order = $sort.Split(":") | select -skip 1
        if (!($order))
        {
            Get-AGMErrorMessage -messagetoprint "Please specify a sort order of asc or desc after a semi colon, e.g.  appname:asc or appname:desc"
            return
        }
        elseif 
        (($order -ne "asc") -and ($order -ne "desc"))
        {
            Get-AGMErrorMessage -messagetoprint "Please specify a sort order of asc or desc after a semi colon, e.g.  appname:asc or appname:desc"
            return
        }
        $sort = "&sort=" + [System.Web.HttpUtility]::UrlEncode($sort)
    }
    else
    {
        $sort = ""
    }

    if ($search)
    {
        $searchitem = "&search=" + [System.Web.HttpUtility]::UrlEncode($search)
    }
    else
    {
        $searchitem = ""
    }



    # default of 15 seconds may be too short
    if (!($timeout))
    {
        $timeout = 15
    }

    # we always start at apistart of 0 which is the first result
    $apistart = 0 
   
    # if somehow the default actmaxapilimit set at connect-act is gone, we set it again
    if ( $agmmaxapilimit -eq "" )
    {
        $agmmaxapilimit = 0
    }
   
    # the api limit per command should be either 4096 or if the user set actmaxapilimit to a number 1-4095 then use that value
    if (( $agmmaxapilimit  -gt 0 ) -and ( $agmmaxapilimit  -le 4096 ))
    { 
        $maxlimitpercommand = $agmmaxapilimit
    }
    else
    {
        $maxlimitpercommand = 4096
    }

    # if user askedd for a limit lets use it
    if (($limit) -and ($limit -ne 0))
    {
        $maxlimitpercommand = $limit
    }


    $method = "get"
    if ($options)
    {
        $method = "options"
    }
    
    # time to send out endpoint   
    $done = 0
    Do
    {
        Try
        {
            $url = "https://$AGMIP/actifio" + "$endpoint"  + "?offset=" + "$apistart" + "&limit=$maxlimitpercommand" + "$fv" + "$searchitem" + "$kw" + "$sort"
            # write-host "we are going to use this method: $method     with this url: $url"
            if ($IGNOREAGMCERTS)
            {
                $resp = Invoke-RestMethod -SkipCertificateCheck -Method $method -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
            }
            else
            {
                $resp = Invoke-RestMethod -Method $method -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
            }
        }
            Catch
            {
                $RestError = $_
            }
            if ($RestError)
            {
                Test-AGMJSON $RestError 
            }
            else
            {
            if (!($resp.items))
            {
                if ($options)
                {
                    $grab = $resp | ConvertTo-JSON | ConvertFrom-Json -AsHashtable
                    $grab1 = $grab.Values.filterablefields.Split("@{field=") | select -skip 1 
                    $grab2 = $grab1 -notmatch '^\s*$'
                    $grab2 -replace "}"
                }
                else 
                {
                    # time stamp conversion
                    if ($datefields)
                    {
                        foreach ($field in $datefields.Split(","))
                        {
                            if ($resp.$field)
                            {
                                $resp.$field = Convert-FromUnixDate $resp.$field
                            }
                        }
                    }
                    $resp
                }
                
                return
            }
            else
            {
                if ($datefields)
                {
                    if ($resp.items)
                    {
                        foreach($line in $resp.items)
                        {
                            foreach ($field in $datefields.Split(","))
                            {
                                if ($line.$field)
                                {
                                    $line.$field = Convert-FromUnixDate $line.$field
                                }
                            }
                        }
                    }
                }
                $resp.items
            }
        }
        # count the results and add 4096 to apistart.  If we got less than 4096 we are done and can finish by settting done to 1
        $objcount = $resp.count
        # if less than 4096 we are either finished or hit the max and we can drop out
        if ( $objcount -lt 4096)
        {
            $done = 1
        }
        # we add 4096 by default for the next grab of data
        else
        {
        $apistart = $apistart + 4096
        $nextlimit = $apistart + 4096
        }
        if ( $apistart -eq $agmmaxapilimit)
        {
            $done = 1
        }
        # we now need to consider if the maxlimit should be trimmed
        if (($agmmaxapilimit -gt 4096) -and ( $nextlimit -gt $agmmaxapilimit))
        {
            $maxlimitpercommand = $agmmaxapilimit - $apistart
        }
    } while ($done -eq 0)
}

# errors can either have JSON and be easy to format or can be text,  we need to sniff
Function Test-AGMJSON()
{
    if ($args) 
    {
        Try
        {
            $isthisjson = $args | Test-Json -ErrorAction Stop
            $validJson = $true
        }
        Catch
        {
            $validJson = $false
        }
        if (!$validJson) 
        {
            Write-Host "$args"
        }
        else
        {
            $args | ConvertFrom-JSON
        }
        Return
    }
}

function Get-AGMErrorMessage ([string]$messagetoprint)
{

        $acterror = @()
        $acterrorcol = "" | Select errormessage
        $acterrorcol.errormessage = "$messagetoprint"
        $acterror = $acterror + $acterrorcol
        $acterror
}


Function Remove-AGMAPIData ([int]$timeout, $endpoint,[switch][alias("d")]$delete,[switch][alias("f")]$force,[switch][alias("r")]$remove)
{
    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Get-AGMErrorMessage -messagetoprint "Not logged in or session expired. Please login using Connect-AGM"
        return
    }

    if (!($endpoint))
    {
        $endpoint = Read-Host "AGM End point"
    }

    if ($endpoint[0] -ne "/")
    {
        $endpoint = "/" + $endpoint
    }

    # default of 15 seconds may be too short
    if (!($timeout))
    {
        $timeout = 15
    }

    # we need to set the method
    $method = "Post"

    #this is the body
    $body = 'accept: */*'
    $json = $body | ConvertTo-Json

    # time to send out endpoint   =
    Try
    {
        $url = "https://$AGMIP/actifio" + "$endpoint"  
        # write-host "we are going to use this method: $method     with this url: $url"
        if ($IGNOREAGMCERTS)
        {
            $resp = Invoke-RestMethod -SkipCertificateCheck -Method $method -Headers @{ Authorization = "Actifio $AGMSESSIONID"; accept = "application/json" }  -Uri "$url" -TimeoutSec $timeout 
        }
        else
        {
            $resp = Invoke-RestMethod -Method $method -Headers @{ Authorization = "Actifio $AGMSESSIONID" }  -Uri "$url" -TimeoutSec $timeout 
        }
    }
    Catch
    {
        $RestError = $_
    }
    if ($RestError)
    {
        Test-AGMJSON $RestError 
    }
    else
    {
        $resp
        if (!($resp))
        {
            Write-host "No output was returned but no error occurred."
        }
        return
    } 
}


Function Convert-FromUnixDate ($UnixDate) 
{
    if ($AGMTimezone -eq "local")
    {
        [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate.ToString().SubString(0,10))).ToLocalTime().ToString('yyyy-MM-dd HH:mm:ss')
    }
    if ($AGMTimezone -eq "utc") 
    {
        [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate.ToString().SubString(0,10))).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss')
    }
   
}

Function Convert-ToUnixDate ([datetime]$InputEpoch) 
{
    if ($AGMTimezone -eq "local")
    {
        [datetime]$Epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970')
        $Ctime = (New-TimeSpan -Start $Epoch -End $InputEpoch).TotalSeconds
        $Ctime = $Ctime * 1000000
        $Ctime -as [decimal]
    }
    if ($AGMTimezone -eq "utc") 
    {
        [datetime]$Epoch = '1970-01-01 00:00:00'
        $Ctime = (New-TimeSpan -Start $Epoch -End $InputEpoch).TotalSeconds
        $Ctime = $Ctime * 1000000
        $Ctime -as [decimal]
    }
}

