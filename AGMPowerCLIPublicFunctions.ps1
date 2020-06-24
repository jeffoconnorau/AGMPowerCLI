Function Get-AGMLatestImage([int]$id, [string]$jobclass) 
{
    <#
    .SYNOPSIS
    Displays the most recent image for an app

    .EXAMPLE
    Get-AGMLatestImage
    You will be prompted for app ID 

    .EXAMPLE
    Get-AGMLatestImage -id 4771
    Get the last snapshot created for the app with ID 4771

    .EXAMPLE
    Get-AGMLatestImage -id 4771 -jobclass dedup
    Get the last dedup created for the app with ID 4771


    .DESCRIPTION
    A function to find the latest image created for an app
    By default you will get the latest snapshot image

    #>


    if (!($id))
    {
        [int]$id = Read-Host "ID"
    }
      
    if ($jobclass)
    {
        $fv = "appid=" + $id + "&jobclass=$jobclass"
    }
    else 
    {
        $fv = "appid=" + $id + "&jobclass=snapshot"
    }
    
    $backup = Get-AGMImage -filtervalue "$fv" -sort ConsistencyDate:desc -limit 1
    if ($backup.id)
    {
        $backup | Add-Member -NotePropertyName appid -NotePropertyValue $backup.application.id
        $backup | Add-Member -NotePropertyName appliance -NotePropertyValue $backup.cluster.name
        $backup | Add-Member -NotePropertyName hostname -NotePropertyValue $backup.host.hostname
        $backup | select appliance, hostname, appname, appid, jobclass, backupname, id, consistencydate, endpit, sltname, slpname, policyname
    }
    else
    {
        $backup
    }
}


Function Get-AGMActiveImage([int]$appid, [string]$jobclass,[switch][alias("u")]$unmount) 
{
    <#
    .SYNOPSIS
    Displays all mounts

    .EXAMPLE
    Get-AGMActiveImages
    Displays all active images

    .EXAMPLE
    Get-AGMActiveImages -appid 4771
    Displays all active images for the app with ID 4771

    .DESCRIPTION
    A function to find the active images

    #>

    $fv = "characteristic=MOUNT"
    if ($unmount)
    {
        $fv = "characteristic=UNMOUNT"
    }
    if ($jobclass)
    {
        $fv = "characteristic=MOUNT&jobclass=$jobclass"
    }
    if ($appid) 
    {
        $fv = "characteristic=MOUNT&appid=$id" 
    }
    if ( ($appid) -and  ($jobclass) )
    {
        $fv = "characteristic=MOUNT&appid=$id&jobclass=$jobclass"
    }
    
    
    $backup = Get-AGMImage -filtervalue "$fv" 
    if ($backup.id)
    {
        $AGMArray = @()

        Foreach ($id in $backup)
        { 
            $id | Add-Member -NotePropertyName appliancename -NotePropertyValue $id.cluster.name
            $id | Add-Member -NotePropertyName hostname -NotePropertyValue $id.host.hostname
            $id | Add-Member -NotePropertyName appid -NotePropertyValue $id.application.id
            $id | Add-Member -NotePropertyName mountedhostname -NotePropertyValue $id.mountedhost.hostname
            $id | Add-Member -NotePropertyName childappname -NotePropertyValue $id.childapp.appname
            $AGMArray += [pscustomobject]@{
                imagename = $id.backupname
                apptype = $id.apptype
                hostname = $id.hostname
                appname = $id.appname
                appid = $id.appid
                mountedhostname = $id.mountedhostname
                childappname = $id.childappname
                appliancename = $id.appliancename
                consumedsize = $id.consumedsize
                label = $id.label
            }
        }
        $AGMArray | FT -AutoSize
    }
    else
    {
        $backup
    }
}


Function Get-AGMRunningJobs 
{
    <#
    .SYNOPSIS
    Displays all running jobs

    .EXAMPLE
    Get-AGMRunningJobs
    Displays all running jobs

    .DESCRIPTION
    A function to find running jobs

    #>

    $fv = "status=running"
       
    $outputgrab = Get-AGMJob -filtervalue "$fv" 
    if ($outputgrab.id)
    {
        $AGMArray = @()

        Foreach ($id in $outputgrab)
        { 
            $id | Add-Member -NotePropertyName appliancename -NotePropertyValue $id.appliance.name
            $AGMArray += [pscustomobject]@{
                jobname = $id.jobname
                jobclass = $id.jobclass
                apptype = $id.apptype
                hostname = $id.hostname
                appname = $id.appname
                appid = $id.appid
                appliancename = $id.appliancename
                startdate = $id.startdate
                progress = $id.progress
                targethost = $id.targethost
                duration = Convert-AGMDuration $id.duration
            }
        }
        $AGMArray | FT -AutoSize
    }
    else
    {
        $outputgrab
    }
}