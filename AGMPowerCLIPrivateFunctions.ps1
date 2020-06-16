# this function prevents errors trying to  run commands without these variables set.
Function Test-AGMConnection
{
    <#
    .SYNOPSIS
    This is an internal function used to test if parms exist to connect to an appliance.  You do not use this function directly
    #>


    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Write-host ""
        Write-Host "Error"
        Write-Host "-----"
        Write-Host "Not logged in or session expired. Please login using Connect-AGM"
        Write-Host ""
        break;
    }
}


Function Get-AGMAPIData ([String]$filtervalue,[String]$keyword, [string]$search, [int]$timeout, $endpoint,[switch][alias("o")]$options)
{

    Test-AGMConnection

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
                $fv = $fv + "&filter=" + $firstword + ":==" + [System.Web.HttpUtility]::UrlEncode($secondwordequals)
            }
            elseif ($secondwordgreater)
            {
                $firstword = $trimm.Split(">") | Select -First 1
                $fv = $fv + "&filter=" + $firstword + ":>=" + [System.Web.HttpUtility]::UrlEncode($secondwordgreater)
            }
            elseif ($secondwordlesser)
            {
                $firstword = $trimm.Split("<") | Select -First 1
                $fv = $fv + "&filter=" + $firstword + ":<=" + [System.Web.HttpUtility]::UrlEncode($secondwordlesser)
            }
            elseif ($secondwordfuzzy)
            {
                $firstword = $trimm.Split("~") | Select -First 1
                $fv = $fv + "&filter=" + $firstword + ":=|" + [System.Web.HttpUtility]::UrlEncode($secondwordfuzzy)
            }
        }
        $fv
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
            $url = "https://$AGMIP/actifio" + "$endpoint"  + "?offset=" + "$apistart" + "&limit=$maxlimitpercommand" + "$fv" + "$searchitem" + "$kw"
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
                    $resp | ConvertTo-Json
                }
                else 
                {
                    $resp
                }
                
                return
            }
            else
            {
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

