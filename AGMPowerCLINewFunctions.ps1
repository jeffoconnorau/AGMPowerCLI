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
    $body = @{name=$orgname;description=$description}
    $json = $body | ConvertTo-Json
    Post-AGMAPIData -endpoint /org -body $json -datefields $datefields
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
    $body = @{name=$rolename;description=$description}
    $json = $body | ConvertTo-Json
    Post-AGMAPIData -endpoint /role -body $json -datefields $datefields
}