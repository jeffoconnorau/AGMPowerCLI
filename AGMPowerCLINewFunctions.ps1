function New-AGMOrg ([string]$orgname,[string]$description)
{
    $datefields = "modifydate,createdate"
    if (!($orgname)) 
    {
        $orgname = Read-Host "OrgName"
    }

    if (!($description))
    {
        $description = Read-Host "Description"
    }
    $body = '{ "name": "' + $orgname + '", "description": "' + $description + '" }'
    Put-AGMAPIData -endpoint /org -body $body -datefields $datefields
}


function New-AGMRole ([string]$rolename,[string]$description)
{
    $datefields = "modifydate,createdate"
    if (!($rolename)) 
    {
        $rolename = Read-Host "RoleName"
    }

    if (!($description))
    {
        $description = Read-Host "Description"
    }
    $body = '{ "name": "' + $rolename + '", "description": "' + $description + '" }'
    Put-AGMAPIData -endpoint /role -body $body -datefields $datefields
}