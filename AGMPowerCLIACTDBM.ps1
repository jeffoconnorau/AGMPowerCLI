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
    A function to find any Apps named smalldb

    #>


    if (!($appname))
    {
        $appname = Read-Host "AppName"
    }
         
    $output = Get-AGMApplication -filtervalue appname=$appname
    if ($output.id)
    {
        Foreach ($id in $output)
        { 
            $id | Add-Member -NotePropertyName appliancename -NotePropertyValue $id.cluster.name
            $id | Add-Member -NotePropertyName applianceip -NotePropertyValue $id.cluster.ipaddress
            $id | Add-Member -NotePropertyName appliancetype -NotePropertyValue $id.cluster.type
            $id | Add-Member -NotePropertyName hostname -NotePropertyValue $id.host.hostname
            $id | select friendlytype, hostname, appname, id, appliancename, applianceip, appliancetype, managed
        }
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
        if (( $capturetype -eq "db") -or ( $capturetype -eq "log"))
        {
            write-host "Performing $capturetype capture on AppID $appid"
        }
        else 
        {
            Get-AGMErrorMessage -messagetoprint "Requested backup type is invalid, use either db or log"
            return
        }
    }
    if (!($capturetype))
    {
        $capturetype = "db"
        write-host "No Backuptype was requested so will perform a db job"
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
        write-host "AppID $appid is protected by SLTID $sltid"
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
            else 
            {
                write-host "AppID $appid has snapshot policy ID $policyid, will use this to run a snapshot job"
            }
        }
        $body = '{ "policy": {"id": "' + $policyid + '"},"backuptype": "' + $capturetype + '" }'
        Post-AGMAPIData  -endpoint /application/$appid/backup -body $body
        write-host "Waiting 5 seconds for job to be listed"
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
