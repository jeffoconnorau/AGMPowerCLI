Function Get-AGMDBMApplicationID ([string]$appname) 
{
    <#
    .SYNOPSIS
    Displays the App IDs for a nominated AppName.

    .EXAMPLE
    Get-AGMDBMApplicationID
    You will be prompted for AppName

    .EXAMPLE
    Get-AGMDBMApplicationID smalldb
    To search for the AppID of any apps called smalldb

    .DESCRIPTION
    A function to find any Apps with nominated name

    #>


    if (!($appname))
    {
        $appname = Read-Host "AppName"
    }
         
    $output = Get-AGMApplication -filtervalue appname=$appname
    if ($output.id)
    {
        $AGMArray = @()

        Foreach ($id in $output)
        { 
            $id | Add-Member -NotePropertyName appliancename -NotePropertyValue $id.cluster.name
            $id | Add-Member -NotePropertyName applianceip -NotePropertyValue $id.cluster.ipaddress
            $id | Add-Member -NotePropertyName appliancetype -NotePropertyValue $id.cluster.type
            $id | Add-Member -NotePropertyName hostname -NotePropertyValue $id.host.hostname
            $AGMArray += [pscustomobject]@{
                id = $id.id
                friendlytype = $id.friendlytype
                hostname = $id.hostname
                appname = $id.appname
                appliancename = $id.appliancename
                applianceip = $id.applianceip
                appliancetype = $id.appliancetype
                managed = $id.managed
            }
        }
        $AGMArray | FT -AutoSize | Sort-Object -Property hostname -Descending
    }
    else
    {
        $output
    }
}

Function Get-AGMDBMHostID ([string]$hostname) 
{
    <#
    .SYNOPSIS
    Displays the Host IDs for a nominated HostName.

    .EXAMPLE
    Get-AGMDBMHostID
    You will be prompted for HostName

    .EXAMPLE
    Get-AGMDBMHostID smalldb
    To search for the HostID of any hosts called smalldb

    .DESCRIPTION
    A function to find any Hosts with nominated HostName

    #>


    if (!($hostname))
    {
        $hostname = Read-Host "HostName"
    }
         
    $output = Get-AGMHost -filtervalue hostname~$hostname
    if ($output.id)
    {
        $AGMArray = @()

        Foreach ($id in $output)
        { 
            $id | Add-Member -NotePropertyName appliancename -NotePropertyValue $id.appliance.name
            $id | Add-Member -NotePropertyName applianceip -NotePropertyValue $id.appliance.ipaddress
            $id | Add-Member -NotePropertyName appliancetype -NotePropertyValue $id.appliance.type
            $AGMArray += [pscustomobject]@{
                id = $id.id
                hostname = $id.hostname
                osrelease = $id.osrelease
                appliancename = $id.appliancename
                applianceip = $id.applianceip
                appliancetype = $id.appliancetype
            }
        }
        $AGMArray | FT -AutoSize | Sort-Object -Property hostname -Descending
    }
    else
    {
        $output
    }
}



Function Get-AGMDBMImageDetails ([int]$appid) 
{
    <#
    .SYNOPSIS
    Displays the images for a specified app

    .EXAMPLE
    Get-AGMDBMImageDetails
    You will be prompted for App ID

    .EXAMPLE
    Get-AGMDBMImageDetails 2133445
    Display images for AppID 2133445


    .DESCRIPTION
    A function to find images for a nominated app and show some interesting fields

    #>


    if (!($appid))
    {
        [int]$appid = Read-Host "AppID"
    }
         
    $output = Get-AGMImage -filtervalue appid=$appid -sort "jobclasscode:asc,consistencydate:asc"
    if ($output.id)
    {
        $backup = Foreach ($id in $output)
        { 
            $id | select id, jobclass, consistencydate, endpit
        }
        $backup
    }
    else
    {
        $output
    }
}

Function New-AGMDBMImage ([int]$appid,[int]$policyid,[string]$capturetype,[switch][alias("m")]$monitor) 
{
    <#
    .SYNOPSIS
    Creates a new image 

    .EXAMPLE
    New-AGMDBMImage
    You will be prompted for App ID

    .EXAMPLE
    New-AGMDBMImage 2133445
    Create a new snapshot for AppID 2133445

    .EXAMPLE
    New-AGMDBMImage -appid 2133445 -capturetype log
    Create a new log snapshot for AppID 2133445


    .EXAMPLE
    New-AGMDBMImage -appid 2133445 -capturetype log -m 
    Create a new log snapshot for AppID 2133445 and monitor the resulting job to completion 


    .DESCRIPTION
    A function to create new snapshot images

    #>

    if ($capturetype)
    {
        if (( $capturetype -ne "db") -and ( $capturetype -ne "log"))
        {
            Get-AGMErrorMessage -messagetoprint "Requested backup type is invalid, use either db or log"
            return
        }
    }
    if (!($capturetype))
    {
        $capturetype = "db"
    }

    if (!($appid))
    {
        [int]$appid = Read-Host "AppID"
    }
    if (!($policyid))
    {     
        $appgrab = Get-AGMApplication -filtervalue appid=$appid 
        $sltid = $appgrab.sla.slt.id
        if (!($sltid))
        {
            Get-AGMErrorMessage -messagetoprint "Failed to learn SLT ID for App ID $appid"
            return
        }
        else 
        {
        $policygrab = Get-AGMSltPolicy -id $sltid
        }
        if (!($policygrab))
        {
            Get-AGMErrorMessage -messagetoprint "Failed to learn Policies for SLT ID $sltid"
            return
        }
        else 
        {
            $policyid = $($policygrab | where {$_.op -eq "snap"} | select -last 1).id
            if (!($policyid))
            {
                Get-AGMErrorMessage -messagetoprint "Failed to learn Snap Policy ID for SLT ID $sltid"
                return
            }
        }
        $policy = @{id=$policyid}
        $body = @{policy=$policy;backuptype=$capturetype}
        $json = $body | ConvertTo-Json
        Post-AGMAPIData  -endpoint /application/$appid/backup -body $json
        Start-Sleep -s 5
        $jobgrab = Get-AGMJob -filtervalue "appid=$appid&jobclasscode=1&isscheduled=false" -sort queuedate:desc -limit 1 | select-object jobname,status,queuedate,startdate
        if (($jobgrab) -and ($monitor))
        {
            Get-AGMFollowJobStatus $jobgrab.jobname
        }
        else 
        {
            $jobgrab 
        }
    }
}

Function Get-AGMFollowJobStatus ([string]$jobname) 
{
    <#
    .SYNOPSIS
    Tracks jobstatus for a nominated job

    .EXAMPLE
    Get-AGMFollowJobStatus
    You will be prompted for JobName

    .EXAMPLE
    Get-AGMFollowJobStatus Job_1234
    Track the progress of Job_1234


    .DESCRIPTION
    A function to follow the progress with 5 second intervals until the job succeeds or is not longer running or queued

    #>



    if (!($jobname))
    {
        $jobname = Read-Host "JobName"
    }
    
    $done = 0
    do 
    {
        $jobgrab = Get-AGMJobStatus -filtervalue jobname=$jobname
        if ($jobgrab.errormessage)
        {   
            $done = 1
            $jobgrab
        }    
        elseif (!($jobgrab.status)) 
        {
            Get-AGMErrorMessage -messagetoprint "Failed to find $jobname"
            $done = 1
        }
        elseif ($jobgrab.status -eq "queued")
        {
            $jobgrab | select-object jobname, status, queuedate | Format-Table
            Start-Sleep -s 5
        }
        elseif ($jobgrab.status -eq "running") 
        {
            if ($jobgrab.duration)
            {
                $jobgrab.duration = Convert-AGMDuration $jobgrab.duration
            }
            $jobgrab | select-object jobname, status, progress, queuedate, startdate, duration | Format-Table
            Start-Sleep -s 5
        }
        else 
        {
            if ($jobgrab.duration)
            {
                $jobgrab.duration = Convert-AGMDuration $jobgrab.duration
            }
            $jobgrab | select-object jobname, status, message, startdate, enddate, duration | Format-Table
            $done = 1    
        }
    } until ($done -eq 1)
}


Function New-AGMMSSQLMount ([int]$appid,[int]$targethostid,[string]$imagename,[string]$targethostname,[string]$appname,[string]$sqlinstance,[string]$dbname,[string]$label,[switch][alias("m")]$monitor,[switch][alias("w")]$wait) 
{
    <#
    .SYNOPSIS
    Mounts an MS SQL Image

    .EXAMPLE
    New-AGMMSSQLMount
    You will be prompted for App ID and targethostid

    .EXAMPLE
    New-AGMMSSQLMount -appid 5552336 -targethostname demo-sql-4 -w
    Mounts the latest snapshot from AppID 5552336 to host named demo-sql-4, and waits for jobname to be printed

    .EXAMPLE
    New-AGMMSSQLMount -appid 5552336 -targethostname demo-sql-4 -m
    Mounts the latest snapshot from AppID 5552336 to host named demo-sql-4, and monitors the job to completion

    .EXAMPLE
    New-AGMMSSQLMount -appid 5552336 -targethostname demo-sql-4 -label "TDM Mount" -sqlinstance DEMO-SQL-4 -dbname avtest -w
    Mounts the latest snapshot from AppID 5552336 to host named demo-sql-4, creating a new DB called avtest on SQL Instance DEMO-SQL-4

    .DESCRIPTION
    A function to mount MS SQL Image

    #>
    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Get-AGMErrorMessage -messagetoprint "Not logged in or session expired. Please login using Connect-AGM"
        return
    }

    if ($targethostname)
    {
        $hostgrab = Get-AGMHost -filtervalue hostname=$targethostname
        if ($hostgrab.id.count -ne 1)
        { 
            Get-AGMErrorMessage -messagetoprint "Failed to resolve $targethostname to a single host ID using Get-AGMHost -filtervalue hostname=$targethostname"
            return
        }
        else {
            $hostid = $hostgrab.id
        }
    }
    if ($appname)
    {
        $appgrab = Get-AGMApplication -filtervalue appname=$appname
        if ($appgrab.id.count -ne 1)
        { 
            Get-AGMErrorMessage -messagetoprint "Failed to resolve $appname to a single App ID using:  Get-AGMApplication -filtervalue appname=$appname"
            return
        }
        else {
            $appid = $appgrab.id
        }
    }

    if (!($appid))
    {
        [int]$appid = Read-Host "AppID"
    }
    if (!($hostid))
    {
        [int]$hostid = Read-Host "TargetHostID"
    }
    if ($imagename)
    {
        $imagegrab = Get-AGMImage -filtervalue backupname=$imagename
        if (!($imagegrab))
        {
            Get-AGMErrorMessage -messagetoprint "Failed to find $imagename using:  Get-AGMImage -filtervalue backupname=$imagename"
            return
        }
        else 
        {
            $backupid = $backupgrab.id    
        }
    }
    else 
    {
        $imagegrab = Get-AGMLatestImage $appid
        if (!($imagegrab.backupname))
        {
            Get-AGMErrorMessage -messagetoprint "Failed to find snapshot for AppID using:  Get-AGMLatestImage $appid"
            return
        }   
        else {
            $imagename = $imagegrab.backupname
            $backupid = $imagegrab.id
        }
    }
    if (!($label))
    {
        $label = ""
    }
    
    if ( ($sqlinstance) -and ($dbname) )
    {
        $body = [ordered]@{
            label = $label;
            image = $imagename;
            host = @{id=$hostid}
            provisioningoptions = @(
                @{
                    name = 'sqlinstance'
                    value = $sqlinstance
                },
                @{
                    name = 'dbname'
                    value = $dbname
                },
                @{
                    name = 'recover'
                    value = 'true'
                },
                @{
                    name = 'userlogins'
                    value = 'false'
                },
                @{
                    name = 'recoverymodel'
                    value = 'Same as source'
                },
                @{
                    name = 'overwritedatabase'
                    value = 'no'
                }
            )
            appaware = "true";
            migratevm = "false";
        }
    }
    else 
    {
        $body = @{
            label = $label;
            image = $imagename;
            host = @{id=$hostid}
        }
    }

    $json = $body | ConvertTo-Json

    if ($monitor)
    {
        $wait = "y"
    }


    Post-AGMAPIData  -endpoint /backup/$backupid/mount -body $json
    if ($wait)
    {
        Start-Sleep -s 15
        $jobgrab = Get-AGMJob -filtervalue "appid=$appid&jobclasscode=5&isscheduled=false&targethost=$targethostname" -sort queuedate:desc -limit 1 
        if (!($jobgrab.jobname))
        {
            Start-Sleep -s 15
            $jobgrab = Get-AGMJob -filtervalue "appid=$appid&jobclasscode=5&isscheduled=false&targethost=$targethostname" -sort queuedate:desc -limit 1 
            if (!($jobgrab.jobname))
            {
                return
            }
        }
        else
        {   
            $jobgrab| select-object jobname,status,queuedate,startdate,targethost
            
        }
        if (($jobgrab.jobname) -and ($monitor))
        {
            Get-AGMFollowJobStatus $jobgrab.jobname
        }
    }
}
