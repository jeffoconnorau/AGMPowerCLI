function Remove-AGMApplication ([Parameter(Mandatory=$true)][int]$appid)
{
    <#
    .SYNOPSIS
    Deletes a nominated application

    .EXAMPLE
    Remove-AGMApplication
    You will be prompted for App ID

    .EXAMPLE
    Remove-AGMApplication 2133445
    Deletes AppID 2133445


    .DESCRIPTION
    A function to delete applications

    #>


    Post-AGMAPIData -endpoint /application/$appid 
}

function Remove-AGMImage ([string]$id)
{
    <#
    .SYNOPSIS
    Expires a nominated image

    .EXAMPLE
    Remove-AGMImage
    You will be prompted for Image ID

    .EXAMPLE
    Remove-AGMImage 2133445
    Expires Image 2133445


    .DESCRIPTION
    A function to expire images

    #>

    if (!($id)) 
    {
        [int]$id = Read-Host "Image ID"
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
    $body = '{ "status": "cancel" }' 
    $cancelgrab = Put-AGMAPIData -endpoint /job/$id -body $body
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
