function Remove-AGMApplication ([Parameter(Mandatory=$true)][int]$appid)
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

function Remove-AGMImage ([string]$imagename)
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
    Post-AGMAPIData -endpoint /backup/$id/expire 
}


function Remove-AGMOrg ([Parameter(Mandatory=$true)][int]$id)
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

function Remove-AGMRole ([Parameter(Mandatory=$true)][int]$id)
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

function Remove-AGMUser([Parameter(Mandatory=$true)][int]$id)
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


function Remove-AGMMount([string]$imagename,[switch][alias("d")]$delete,[switch][alias("f")]$force)
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
    Unmounts Image_2133445 and deletes it

    .DESCRIPTION
    A function to unmount images

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


    $body = @{delete=$deleterequest;force=$forcerequest}
    $json = $body | ConvertTo-Json

    Post-AGMAPIData -endpoint /backup/$id/unmount -body $json
}
