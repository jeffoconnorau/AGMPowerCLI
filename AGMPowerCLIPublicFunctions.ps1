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