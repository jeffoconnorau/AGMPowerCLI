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

Function Get-AGMAPIData ([String]$filtervalue,[String]$keyword, [string]$search,[int]$timeout,[string]$endpoint,[string]$extrarequests,[switch][alias("h")]$head,[switch][alias("o")]$options,[switch]$itemoverride,[switch]$duration,[string]$datefields,[int]$limit,[string]$sort)
{
    <#  
    .SYNOPSIS
    Send a Get API call to an AGM

    .DESCRIPTION
    The Get-AGMAPIData connects to AGM to issue a Get 
    Normally this function is not called directly, but by another function, such as Get-AGMUser.
    However power users can use this function to simplify their own scripts if they so choose.

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Get-AGMAPIData -endpoint /application -filtervalue appname~smalldb -datefields "syncdate" -limit 1 -sort id:desc
    Use the /application endpoint which is used to display applications and display applications with a name like smalldb,
    but limit the output to one object and sort by id descending.
    This sort means that if an application is returned it will be the most recently created one.

    #>

    
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

    if (!($extrarequests))
    {
        $extrarequests = ""
    }

    if ($filtervalue) 
    {
        $fv = ""
        $andsep = $filtervalue.Split("&") -notmatch '^\s*$'
        foreach ($line in $andsep) 
        {
            # remove any whitespace at the end
            $trimm = $line.TrimEnd()
            $secondwordequals = $trimm.Split("=") | Select-Object -skip 1
            $secondwordnotequal = $trimm.Split("!") | Select-Object -skip 1
            $secondwordgreater = $trimm.Split(">") | Select-Object -skip 1
            $secondwordlesser = $trimm.Split("<") | Select-Object -skip 1
            $secondwordfuzzy = $trimm.Split("~") | Select-Object -skip 1
            if ($secondwordequals)
            {
                $firstword = $trimm.Split("=") | Select-Object -First 1
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
            elseif ($secondwordnotequal)
            {
                $firstword = $trimm.Split("!") | Select-Object -First 1
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
                $fv = $fv + "&filter=" + $firstword + ":!=" + [System.Web.HttpUtility]::UrlEncode($secondwordnotequal)
            }
            elseif ($secondwordgreater)
            {
                $firstword = $trimm.Split(">") | Select-Object -First 1
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
                $firstword = $trimm.Split("<") | Select-Object -First 1
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
                $firstword = $trimm.Split("~") | Select-Object -First 1
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
        $commasplit = $sort.Split(",") 
        foreach ($line in $commasplit)
        {
            $order = $line.Split(":") | Select-Object -skip 1
            if (!($order))
            {
                Get-AGMErrorMessage -messagetoprint "Please specify a sort order of asc or desc after a full colon, e.g.  appname:asc or appname:desc"
                return
            }
            elseif 
            (($order -ne "asc") -and ($order -ne "desc"))
            {
                Get-AGMErrorMessage -messagetoprint "Please specify a sort order of asc or desc after a full colon, e.g.  appname:asc or appname:desc"
                return
            }
            if (!($sortreq))
            {
                $sortreq = "&sort=" + [System.Web.HttpUtility]::UrlEncode($line)
            }
            else
            {
                $sortreq = $sortreq + "," + [System.Web.HttpUtility]::UrlEncode($line)
            }
        }
    }
    else
    {
        $sortreq = ""
    }

    if ($search)
    {
        $searchitem = "&search=" + [System.Web.HttpUtility]::UrlEncode($search)
    }
    else
    {
        $searchitem = ""
    }



    # default of 300 seconds is enforced regardless
    if (!($timeout))
    {
        $timeout = $GLOBAL:AGMTIMEOUT
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
            $url = "https://$AGMIP/actifio" + "$endpoint"  + "?offset=" + "$apistart" + "&limit=$maxlimitpercommand" + "$fv" + "$searchitem" + "$kw" + "$sortreq" + "$extrarequests"
            # write-host "we are going to use this method: $method     with this url: $url"
            if ($IGNOREAGMCERTS)
            {
                if ($head)
                {
                    $resp = Invoke-WebRequest -SkipCertificateCheck -Method "head" -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
                } else {
                    $resp = Invoke-RestMethod -SkipCertificateCheck -Method $method -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
                }   
                
            }
            else
            {
                if ($head)
                {
                    if ($AGMToken)
                    {
                        $resp = Invoke-WebRequest -Method "head" -Headers @{ Authorization = "Bearer $AGMToken"; "backupdr-management-session" = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
                    }
                    else {
                        $resp = Invoke-WebRequest -Method "head" -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
                    }
                } 
                else 
                {
                    if ($AGMToken)
                    {
                        $resp = Invoke-RestMethod -Method $method -Headers @{ Authorization = "Bearer $AGMToken"; "backupdr-management-session" = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
                    }
                    else {
                        $resp = Invoke-RestMethod -Method $method -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
                    }
                }
            }
        }
            Catch
            {
                if ( $((get-host).Version.Major) -gt 5 )
                {
                    $RestError = $_
                }
                else 
                {
                    if ($_.Exception.Response)
                    {
                        $result = $_.Exception.Response.GetResponseStream()
                        $reader = New-Object System.IO.StreamReader($result)
                        $reader.BaseStream.Position = 0
                        $reader.DiscardBufferedData()
                        $RestError = $reader.ReadToEnd();
                    }
                    else 
                    {
                        Get-AGMErrorMessage  -messagetoprint  "No response was received from $AGMIP  Timeout is set to $timeout seconds"
                        return
                    }
                }
            }
            if ($RestError)
            {
                Test-AGMJSON $RestError 
            }
            else
            {
            if ( (!($resp.items)) -or ($itemoverride -eq $true) )
            {
                if ($options)
                {
                    $grab = $resp.'GET(list)'
                    if ($grab.filterablefields)
                    {
                        $grab = $grab.filterablefields
                        $grab | Sort-Object field
                    }
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
                    if ($duration)
                    {
                        if ($resp.duration)
                        {
                            $resp.duration = Convert-AGMDuration $resp.duration
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
                if ($duration)
                {
                    if ($resp.items)
                    {
                        foreach($line in $resp.items)
                        {
                            if ($line.duration)
                            {
                                $line.duration = Convert-AGMDuration $line.duration
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
    } 
    while ($done -eq 0)
}

# errors can either have JSON and be easy to format or can be text,  we need to sniff
Function Test-AGMJSON()
{
    <#  
    .SYNOPSIS
    Checks if data returned by AGM is JSON or not.

    .DESCRIPTION
    When AGM returns data it is normally in JSON which PowerShell 7 loves to munch on.
    But sometimes data is not JSON or needs some special handling so this function checks what we got and handles it.

    .NOTES
    Written by Anthony Vandewerdt
    
    #>
 

    if ($args) 
    {
        [string]$messagetotest = $args
        if ( $((get-host).Version.Major) -gt 5 )
        {

            if ($messagetotest | Test-Json)
            {
                $jsonmessage = $messagetotest | ConvertFrom-JSON -ErrorAction Stop
                $validJson = $true
            }
            else
            {
                # error messages from can Sky have multiple lines, which PS doesn't want to print, so we strip them out to get all the text
                $cleanedmessage = $args -replace "`n",","
                Get-AGMErrorMessage  -messagetoprint $cleanedmessage 
                return
            }
        }
        else 
        {
            $validJson = 1
            try 
            {
                $jsonmessage = ConvertFrom-Json $messagetotest -ErrorAction Stop;
                $validJson = 1;
            }  catch  {
                $validJson = 2;
            }
            if ($validJson -eq 2) 
            {
                $cleanedmessage = $args -replace "`n",","
                Get-AGMErrorMessage  -messagetoprint $cleanedmessage 
                return
            }
        }
        # if we got here we have valid JSON
        if ($jsonmessage.err_code -eq 10011)
        {
            Get-AGMErrorMessage -messagetoprint "Users current assigned role does not have permission to perform this action." 
        }
        elseif ($jsonmessage.err_message)
        {
            $cleanedmessage = $jsonmessage.err_message -replace "`n",","
            Get-AGMErrorMessage -messagetoprint $cleanedmessage
        }
        elseif ($jsonmessage.error)
        {
            $jsonmessage.error
        }
        Return
    }
}

function Get-AGMErrorMessage ([string]$messagetoprint,[int]$errcode)
{
    <#  
    .SYNOPSIS
    Prints a message in a format that makes it looks like an error

    .DESCRIPTION
    When AGM returns an error you will get an errormessage and often an errorcode.
    But if the module itself generates an error we want it to look like a proper error with the same format.
    This also makes it easy to script, by looking for errormessage in returned data.

    .NOTES
    Written by Anthony Vandewerdt
    
    #>

    $acterror = @()
    $acterrorcol = "" | Select-Object errormessage
    $acterrorcol.errormessage = "$messagetoprint"
    $acterror = $acterror + $acterrorcol
    $acterror
}


Function Post-AGMAPIData ([int]$timeout,[string]$endpoint,[string]$body,[string]$method,[string]$datefields)
{
    <#  
    .SYNOPSIS
    Send a Post API call to an AGM

    .DESCRIPTION
    The Post-AGMAPIData connects to AGM to issue a Post 
    Normally this function is not called directly, but by another function.
    However power users can use this function to simplify their own scripts if they so choose.

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Post-AGMAPIData -endpoint /org -body '{ "description": "Melbourne test team","name": "MelTeam1" }' -datefields "modifydate,createdate"
    
    In this example we send some JSON to the /org endpoint which requests a new org with the relevant name and description.
    This will create an org and return data relevant to that new org.  Note the returned data will be formatted JSON.

    .EXAMPLE
    Post-AGMAPIData -endpoint /org/53688920 -method "delete"
    This deletes Org ID 53688920

    #>


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

    # default of 300 seconds may be too short
    if (!($timeout))
    {
        $timeout = $GLOBAL:AGMTIMEOUT 
    }

    # we need to set the method
    if (!($method))
    {    
        $method = "post"
    }


    if (!($body))
    {
        $body = '{ "accept": "*/*" }'   
    }
    Try
    {
        $url = "https://$AGMIP/actifio" + "$endpoint"  
        # write-host "we are going to use this method: $method     with this url: $url"
        if ($IGNOREAGMCERTS)
        {
            $resp = Invoke-RestMethod -SkipCertificateCheck -Method $method -Headers @{ Authorization = "Actifio $AGMSESSIONID" ; accept = "application/json" } -body $body -ContentType "application/json" -Uri "$url" -TimeoutSec $timeout 
        }
        else
        {
            if ($AGMToken) 
            {
                $resp = Invoke-RestMethod -Method $method -Headers @{ Authorization = "Bearer $AGMToken"; "backupdr-management-session" = "Actifio $AGMSESSIONID" ; accept = "application/json" } -body $body -ContentType "application/json" -Uri "$url" -TimeoutSec $timeout 
                
            }
            else 
            {
                $resp = Invoke-RestMethod -Method $method -Headers @{ Authorization = "Actifio $AGMSESSIONID" ; accept = "application/json" } -body $body -ContentType "application/json" -Uri "$url" -TimeoutSec $timeout 
            }
            
        }
    }
    Catch
    {
        if ( $((get-host).Version.Major) -gt 5 )
        {
            $RestError = $_
        }
        else 
        {
            
            if ($_.Exception.Response)
            {
                $result = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $RestError = $reader.ReadToEnd();
            }
            else 
            {
                Get-AGMErrorMessage  -messagetoprint  "No response was received from $AGMIP  Timeout is set to $timeout seconds"
                return
            }
        }
    }
    if ($RestError)
    {
       Test-AGMJSON $RestError 
    }
    else 
    {
        if ($resp)   
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
    }
}


Function Put-AGMAPIData ([int]$timeout,[string]$endpoint,[string]$body)
{
    <#  
    .SYNOPSIS
    Send a Put API call to an AGM

    .DESCRIPTION
    The Put-AGMAPIData connects to AGM to issue a Put
    Normally this function is not called directly, but by another function.
    However power users can use this function to simplify their own scripts if they so choose.     

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Put-AGMAPIData -endpoint /job/12345 -body '{ "status": "cancel" }'
    
    This sends a Put API to the /job endpoint requesting that job ID 12345 be cancelled.

    #>


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

    # default of 300 seconds may be too short
    if (!($timeout))
    {
        $timeout = $GLOBAL:AGMTIMEOUT
    }
    if (!($body))
    {
        $body = '{ "accept": "*/*" }' 
    }
    Try
    {
        $url = "https://$AGMIP/actifio" + "$endpoint"  
        # write-host "we are going to use this method: $method     with this url: $url"
        if ($IGNOREAGMCERTS)
        {
            $resp = Invoke-RestMethod -SkipCertificateCheck -Method put -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -body $body -ContentType "application/json" -Uri "$url" -TimeoutSec $timeout 
        }
        else
        {
            if ($AGMToken)
            {
                $resp = Invoke-RestMethod -Method put -Headers @{ Authorization = "Bearer $AGMToken"; "backupdr-management-session" = "Actifio $AGMSESSIONID" } -body $body -ContentType "application/json" -Uri "$url" -TimeoutSec $timeout 
            }
            else 
            {
                $resp = Invoke-RestMethod -Method put -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -body $body -ContentType "application/json" -Uri "$url" -TimeoutSec $timeout 
            }
            
        }
    }
    Catch
    {
        if ( $((get-host).Version.Major) -gt 5 )
        {
            $RestError = $_
        }
        else 
        {
            if ($_.Exception.Response)
            {
                $result = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $RestError = $reader.ReadToEnd();
            }
            else 
            {
                Get-AGMErrorMessage  -messagetoprint  "No response was received from $AGMIP  Timeout is set to $timeout seconds"
                return
            }
        }
    }
    if ($RestError)
    {
        Test-AGMJSON $RestError 
    }
    else 
    {
        if ($resp)   
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
    }
}




Function Convert-FromUnixDate ($UnixDate) 
{
    <#  
    .SYNOPSIS
    Converts time stamps from Epoch to IS08601

    .DESCRIPTION
    By default AGM returns all date stamps as Epoch (seconds offset from Jan 1, 1970).
    Fields can look like this:   syncdate=1594697898434000
    Humans prefer dates that are human readable and really cool humans prefer ISO8601 format.

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Convert-FromUnixDate 1594697896759000

    Convert 1594697896759000 to ISO8601 readable date format
    #>
    $length = $UnixDate | measure-object -character | Select-Object -expandproperty characters
    if ($length -eq 16)
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
}

Function Convert-ToUnixDate ([datetime]$InputEpoch) 
{
    <#  
    .SYNOPSIS
    Converts time stamps from IS08601 to Epoch

    .DESCRIPTION
    By default AGM prefers to munch on date stamps that are in Epoch (seconds offset from Jan 1, 1970).
    Humans prefer dates that are human readable so this function lets everyone be happy.

    .NOTES
    Written by Anthony Vandewerdt
    
    #>

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

Function Convert-AGMDuration ($duration)
{
    <#  
    .SYNOPSIS
    Creates a human readable duration timestamps

    .DESCRIPTION
    Duration is returned by AGM as seconds.   So we turn that into HHH:MM:SS

    .NOTES
    Written by Anthony Vandewerdt
    
    #>

    $convertedtime =  [timespan]::fromseconds($duration/1000000)
    [string]$totalhours = $convertedtime.days * 24 + $convertedtime.hours

    if ($totalhours -eq "0")
    { 
        $totalhours = "00" 
    }
    $totalhours + $convertedtime.ToString("\:mm\:ss")
}

####   Appliance Delegation

Function Get-AGMAPIApplianceInfo ([String]$applianceid,[String]$id,[string]$command,[string]$arguments,[int]$timeout)
{
    <#  
    .SYNOPSIS
    Fetch info output from Appliances

    .NOTES
    Written by Anthony Vandewerdt
    
    #>


    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Get-AGMErrorMessage -messagetoprint "Not logged in or session expired. Please login using Connect-AGM"
        return
    }
    if ($id)
    { $applianceid = $id}

    if (!($timeout))
    {
         $timeout = $GLOBAL:AGMTIMEOUT
    }

    if (!($applianceid))
    {
        [string]$applianceid = Read-Host "applianceid"
    }
    if (!($command))
    {
        [string]$command = Read-Host "Command"
    }
    Try
    {
        $url = "https://$AGMIP/actifio/appliancedelegation/$applianceid/api/info/" + "$command" 
        if  ($arguments)
        {
            $url = $url +"?" +$arguments
        }
        if ($IGNOREAGMCERTS)
        {
            $resp = Invoke-RestMethod -SkipCertificateCheck -Method "Get" -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
        }
        else
        {
            if ($AGMToken)
            {
                $resp = Invoke-RestMethod -Method "Get" -Headers @{ Authorization = "Bearer $AGMToken"; "backupdr-management-session" = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
            }
            else 
            {
                $resp = Invoke-RestMethod -Method "Get" -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
            }
        }
    }
    Catch
    {
        if ( $((get-host).Version.Major) -gt 5 )
        {
            $RestError = $_
        }
        else 
        {
            if ($_.Exception.Response)
            {
                $result = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $RestError = $reader.ReadToEnd();
            }
            else 
            {
                Get-AGMErrorMessage  -messagetoprint  "No response was received from $AGMIP  Timeout is set to $timeout seconds"
                return
            }
        }
    }
    if ($RestError)
    {
        Test-AGMJSON $RestError 
    }
    elseif ($resp.result)
    {
        $resp.result
    }
    else 
    {
        $resp    
    }      
}

Function Get-AGMAPIApplianceReport ([String]$applianceid,[string]$command,[string]$arguments,[int]$timeout)
{
    <#  
    .SYNOPSIS
    Fetch report output from Appliances

    .NOTES
    Written by Anthony Vandewerdt
    
    #>

    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Get-AGMErrorMessage -messagetoprint "Not logged in or session expired. Please login using Connect-AGM"
        return
    }

    if (!($timeout))
    {
         $timeout = $GLOBAL:AGMTIMEOUT
    }

    if (!($applianceid))
    {
        [string]$applianceid = Read-Host "applianceid"
    }
    if (!($command))
    {
        [string]$command = Read-Host "Endpoint"
    }
    Try
    {
        $url = "https://$AGMIP/actifio/appliancedelegation/$applianceid/api/report/" + "$command" 
        if  ($arguments)
        {
            $url = $url +"?" +$arguments
        }
        if ($IGNOREAGMCERTS)
        {
            $resp = Invoke-RestMethod -SkipCertificateCheck -Method "Get" -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
        }
        else
        {
            if ($AGMToken)
            {
                $resp = Invoke-RestMethod -Method "Get" -Headers @{ Authorization = "Bearer $AGMToken"; "backupdr-management-session" = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
            }
            else
            {
                $resp = Invoke-RestMethod -Method "Get" -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
            }
        }
    }
    Catch
    {
        if ( $((get-host).Version.Major) -gt 5 )
        {
            $RestError = $_
        }
        else 
        {
            if ($_.Exception.Response)
            {
                $result = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $RestError = $reader.ReadToEnd();
            }
            else 
            {
                Get-AGMErrorMessage  -messagetoprint  "No response was received from $AGMIP  Timeout is set to $timeout seconds"
                return
            }
        }
    }
    if ($RestError)
    {
        Test-AGMJSON $RestError 
    }
    elseif ($resp.result)
    {
        $resp.result
    }
    else 
    {
        $resp    
    }      
}

Function Set-AGMAPIApplianceTask ([String]$applianceid,[string]$command,[string]$arguments,[int]$timeout)
{
    <#  
    .SYNOPSIS
    Fetch info output from Appliances

    .NOTES
    Written by Anthony Vandewerdt
    
    #>


    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Get-AGMErrorMessage -messagetoprint "Not logged in or session expired. Please login using Connect-AGM"
        return
    }

    if (!($timeout))
    {
         $timeout = $GLOBAL:AGMTIMEOUT
    }

    if (!($applianceid))
    {
        [string]$applianceid = Read-Host "applianceid"
    }
    if (!($command))
    {
        [string]$command = Read-Host "Command"
    }
    Try
    {
        $url = "https://$AGMIP/actifio/appliancedelegation/$applianceid/api/task/" + "$command" 
        if  ($arguments)
        {
            $url = $url +"?" +$arguments
        }
        if ($IGNOREAGMCERTS)
        {
            $resp = Invoke-RestMethod -SkipCertificateCheck -Method "Post" -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
        }
        else
        {
            if ($AGMToken)
            {
                $resp = Invoke-RestMethod -Method "Post" -Headers @{ Authorization = "Bearer $AGMToken"; "backupdr-management-session" = "Actifio $AGMSESSIONID" }  -Uri "$url" -TimeoutSec $timeout 
            }
            else 
            {
                $resp = Invoke-RestMethod -Method "Post" -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "$url" -TimeoutSec $timeout 
            }
        }
    }
    Catch
    {
        if ( $((get-host).Version.Major) -gt 5 )
        {
            $RestError = $_
        }
        else 
        {
            if ($_.Exception.Response)
            {
                $result = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $RestError = $reader.ReadToEnd();
            }
            else 
            {
                Get-AGMErrorMessage  -messagetoprint  "No response was received from $AGMIP  Timeout is set to $timeout seconds"
                return
            }
        }
    }
    if ($RestError)
    {
        Test-AGMJSON $RestError 
    }
    elseif ($resp.result)
    {
        $resp.result
    }
    else 
    {
        $resp    
    }      
}


function Set-AGMPromoteUser
{
    <#  
    .SYNOPSIS
    Promotes a Management Console user 

    .DESCRIPTION
    Run this function to promote the user

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Set-AGMPromoteUser
 
    #>
   
    #$jsonbody = '{"id":"' +$AGMSESSIONID +'","size":11}'

    Put-AGMAPIData  -endpoint /manageacl/promoteUser

}