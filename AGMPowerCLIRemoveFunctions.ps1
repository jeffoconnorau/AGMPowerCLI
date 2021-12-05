function Remove-AGMApplication ([Parameter(Mandatory=$true)][string]$appid)
{
    <#
    .SYNOPSIS
    Deletes a nominated application

    .EXAMPLE
    Remove-AGMApplication
    You will be prompted for an Application ID

    .EXAMPLE
    Remove-AGMApplication 2133445
    Deletes Application ID 2133445


    .DESCRIPTION
    A function to delete applications

    #>


    Post-AGMAPIData -endpoint /application/$appid -method delete
}


function Remove-AGMAppliance ([string]$applianceid,[string]$id)
{
    <#
    .SYNOPSIS
    Removes a nominated appliance

    .EXAMPLE
    Remove-AGMAppliance
    You will be prompted for an Appliance ID
    You could learn the Appliance IDs with Get-AGMAppliance.  Use the ID field

    .EXAMPLE
    Remove-AGMAppliance -id 2133445
    Removes Appliance ID 2133445


    .DESCRIPTION
    A function to remove appliances

    #>

    if ($id) { $applianceid = $id}
    if (!($applianceid))
    {
        $applianceid = Read-Host "Appliance ID"
    }
    Post-AGMAPIData -endpoint /cluster/$applianceid -method delete
}



function Remove-AGMCredential([string]$credentialid,[string]$id,[string]$applianceid,[string]$clusterid)
{
    <#
    .SYNOPSIS
    Deletes a nominated Cloud Credential

    .EXAMPLE
    Remove-AGMCredential -id 12345 clusterid 5678
    Deletes credential ID 12345 from clusterid ID 5678


    .DESCRIPTION
    A function to delete cloud credentials

    #>

    if ($credentialid) { $id = $credentialid}
    if ($applianceid) { $clusterid = $applianceid}
    if (!($id))
    {
        $id = Read-Host "Credential ID"
    }
    if (!($clusterid))
    {
        $clusterid = Read-Host "Cluster IDs (comma separated)"
    }
    # add each cluster ID to sources
    $sources = @(
        foreach ($cluster in $clusterid.Split(","))
        {
        @{
            clusterid = $cluster
        }
    }
    )
    # create source body and convert to JSON
    $body = @{ sources = $sources }
    $json = $body | ConvertTo-Json
    
    Post-AGMAPIData -endpoint /cloudcredential/$id -method delete -body $json
}




function Remove-AGMHost ([string]$id,[string]$clusterid)
{
    <#
    .SYNOPSIS
    Deletes a nominated host

    .EXAMPLE
    Remove-host
    You will be prompted for an host ID

    .EXAMPLE
    Remove-AGMHost -id 2133445 -clusterid 1415071155
    Deletes Host ID 2133445 from cluster ID 1415071155

    .EXAMPLE
    Remove-AGMHost -id 2133445 -clusterid "1415071155,1425071155"
    Deletes Host ID 2133445 from cluster ID 1415071155 and cluster ID 1425071155
    If you don't enclose in double quotes you will get errors

    .DESCRIPTION
    A function to delete Hosts

    #>


    if (!($id)) 
    {
        [string]$id = Read-Host "Host ID"
    }
    if (!($clusterid)) 
    {
        [string]$clusterid = Read-Host "Cluster ID (comma separated list)"
    }

    # add each cluster ID to sources
    $sources = @(
        foreach ($cluster in $clusterid.Split(","))
        {
        @{
            clusterid = $cluster
        }
    }
    )
    # create source body and convert to JSON
    $body = @{ sources = $sources }
    $json = $body | ConvertTo-Json


    Post-AGMAPIData -endpoint /host/$id -method delete -body $json
}


function Remove-AGMImage ([string]$imagename,[string]$backupname)
{
    <#
    .SYNOPSIS
    Expires a nominated image

    .EXAMPLE
    Remove-AGMImage
    You will be prompted for Image Name

    .EXAMPLE
    Remove-AGMImage Image_2133445
    Expires Image_2133445


    .DESCRIPTION
    A function to expire images

    #>

    if ($backupname) { $imagename = $backupname }
    if (!($imagename)) 
    {
        $imagename = Read-Host "ImageName"
    }
    $imagegrab = Get-AGMImage -filtervalue backupname=$imagename
    if ($imagegrab.id)
    {
        $id = $imagegrab.id
    }
    else 
    {
        Get-AGMErrorMessage -messagetoprint "Failed to find $imagename"
        return
    }
    Post-AGMAPIData -endpoint /backup/$id/expire?force=false 
}

Function Remove-AGMMigrate ([string]$imageid) 
{
    <#
    .SYNOPSIS
    Removes a migration job 

    .EXAMPLE
    Remove-AGMMigrate 
    You will be prompted for ImageID

    .EXAMPLE
    Remove-AGMMigrate -imageid 56072427 

    Removes migration  for Image ID 56072427

    .DESCRIPTION
    A function to remove migration jobs 

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
    $body = [ordered]@{}
    $body += @{ action = "migratecancel" }
    $json = $body | ConvertTo-Json

    Post-AGMAPIData  -endpoint /backup/$imageid/migrate  -body $json
}

function Remove-AGMOrg ([Parameter(Mandatory=$true)][string]$id)
{
    <#
    .SYNOPSIS
    Deletes a nominated org

    .EXAMPLE
    Remove-AGMOrg
    You will be prompted for org ID

    .EXAMPLE
    Remove-AGMOrg 2133445
    Deletes OrgID 2133445


    .DESCRIPTION
    A function to delete orgs

    #>


    Post-AGMAPIData -endpoint /org/$id -method "delete"
}

function Remove-AGMRole ([Parameter(Mandatory=$true)][string]$id)
{
    <#
    .SYNOPSIS
    Deletes a nominated role

    .EXAMPLE
    Remove-AGMRole
    You will be prompted for role ID

    .EXAMPLE
    Remove-AGMRole 2133445
    Deletes RoleID 2133445


    .DESCRIPTION
    A function to delete roles

    #>


    Post-AGMAPIData -endpoint /role/$id -method "delete"
}

function Remove-AGMSLA ([string]$id,[string]$slaid,[string]$appid)
{
    <#
    .SYNOPSIS
    Deletes a nominated SLA

    .EXAMPLE
    Remove-AGMSLA
    You will be prompted for an SLA ID

    .EXAMPLE
    Remove-AGMSLA -id 2133445
    Deletes SLAID 2133445

    .EXAMPLE
    Remove-AGMSLA -slaid 2133445
    Deletes SLAID 2133445

    .EXAMPLE
    Remove-AGMSLA -appid 1234
    Deletes the SLA for AppID 1234

    .DESCRIPTION
    A function to delete SLAs

    #>

    if ($id)
    {
        $slaid = $id
    }

    if ( ($appid) -and (!($slaid)) )
    {
        $slaid = (Get-AGMSLA -filtervalue appid=$appid).id
    }

    if (!($slaid))
    {
        [string]$slaid = Read-Host "SLA ID to remove"
    }

    Post-AGMAPIData -endpoint /sla/$slaid -method "delete"
}



function Remove-AGMUser([Parameter(Mandatory=$true)][string]$id)
{
    <#
    .SYNOPSIS
    Deletes a nominated user

    .EXAMPLE
    Remove-AGMUser
    You will be prompted for user ID

    .EXAMPLE
    Remove-AGMUser 2133445
    Deletes UserID 2133445


    .DESCRIPTION
    A function to delete users

    #>

    
    Post-AGMAPIData -endpoint /user/$id -method "delete"
}

function Remove-AGMJob([string]$jobname)
{
    <#
    .SYNOPSIS
    Cancels a nominated job

    .EXAMPLE
    Remove-AGMJob
    You will be prompted for job Name

    .EXAMPLE
    Remove-AGMJob Job_2133445
    Cancels Job_2133445


    .DESCRIPTION
    A function to cancel jobs

    #>


    if (!($jobname))
    {
        $jobname = Read-Host "JobName"
    }
    if ($jobname)
    {
        $jobgrab = Get-AGMJob -filtervalue jobname=$jobname
        if ($jobgrab.id)
        {
            $id = $jobgrab.id
        }
        else 
        {
            Get-AGMErrorMessage -messagetoprint "Failed to find $jobname"
            return
        }
    }
    $body = @{status="cancel"}
    $json = $body | ConvertTo-Json
    $cancelgrab = Put-AGMAPIData -endpoint /job/$id -body $json
    if ($cancelgrab.errormessage)
    { 
        $cancelgrab
    }
    elseif ($cancelgrab.changerequesttext)
    {
        $cancelgrab | select-object jobname, changerequesttext, status
    }
    else 
    {
        $cancelgrab
    }

}


function Remove-AGMMount([string]$imagename,[switch][alias("d")]$delete,[switch][alias("p")]$preservevm,[switch][alias("f")]$force)
{
    <#
    .SYNOPSIS
    Unmounts a nominated image

    .EXAMPLE
    Remove-AGMMount
    You will be prompted for image Name 

    .EXAMPLE
    Remove-AGM -imagename Image_2133445
    Unmounts Image_2133445 but does not delete it

    .EXAMPLE
    Remove-AGM -imagename Image_2133445 -d
    Unmounts Image_2133445 and deletes it from Actifio and from the cloud if a mount is a GCP VM created from Persistent Disk Snapshot

    .EXAMPLE
    Remove-AGM -imagename Image_2133445 -p
    For Google Cloud Persistent Disk (PD) mounts
    Unmounts Image_2133445 and deletes it on Actifio Side but preserves it on Google side.

    .DESCRIPTION
    A function to unmount images

    -delete (-d)      Is used to unmount and delete an image.  If not specified then an unmount is done, but the image is retained on the Actifio Side
    -force (-f)       Removes the mount even if the host-side command to remove the mounted application fails.   This can leave artifacts on the Host and should be used with caution
    -preservevm (-p)  This applies to GCE Instances created from PD Snapshot.   When used the Actifio Image of the mount is removed, but on the GCP side the new VM is retained.   

    #>


    if (!($imagename))
    {
        $imagename = Read-Host "ImageName"
    }
    if ($imagename)
    {
        $imagegrab = Get-AGMImage -filtervalue backupname=$imagename
        if ($imagegrab.id)
        {
            $id = $imagegrab.id
        }
        else 
        {
            Get-AGMErrorMessage -messagetoprint "Failed to find $imagename"
            return
        }
    }

    if ($delete)
    { 
        $deleterequest="true"
    }
    else 
    {
        $deleterequest="false"
    }
    if ($force)
    { 
        $forcerequest="true"
    }
    else 
    {
        $forcerequest="false"
    }
    if ($preservevm)
    { 
        $preservevmrequest="true"
    }
    else 
    {
        $preservevmrequest="false"
    }


    $body = @{delete=$deleterequest;force=$forcerequest;preservevm=$preservevmrequest}
    $json = $body | ConvertTo-Json

    Post-AGMAPIData -endpoint /backup/$id/unmount -body $json
}
