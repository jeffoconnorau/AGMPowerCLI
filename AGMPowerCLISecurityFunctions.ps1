function New-AGMOrg ([string]$orgname,[string]$description,[string]$jsonbody,[string]$applist,[string]$arraylist,[string]$hostlist,[string]$lglist,[string]$poollist,[string]$slplist,[string]$sltlist,[string]$userlist)
{
    <#  
    .SYNOPSIS
    Creates a new Organization on AGM

    .DESCRIPTION
    The New-AGMOrg is used to create a new Organization.   

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    New-AGMOrg EngTeam1
    
    Creates a new Org called EngTeam1
  
    .EXAMPLE
    New-AGMOrg -orgname EngTeam1 -description "Test team"
    
    Creates a new Org called EngTeam1 with a description of "Test team"

    .EXAMPLE
    New-AGMOrg -orgname avtest8 -description "lets get developing" -applist "19324243" -arraylist "28127562" -hostlist 5569125 -lglist 40490815 -poollist "13638082" -slplist 5552517 -sltlist "43073490,4583" -userlist "45229518"

    Creates a new org with specified resources.
    applist is a list of App IDs
    arraylist is a list of ESP arrays
    hostlist is a list of host IDs
    lglist is a list of logical group IDs
    poollist is a list of pool IDs
    slplist is a list of profile IDs
    sltlist is a list of template IDs
    userlist is a list of user IDs

    .EXAMPLE
    New-AGMOrg -jsonbody '{"@type":"organizationRest","name":"avtest","description":"test org"}'
    
    Creates a new Org called avtest with a description of "test org", using a JSON body.

    .EXAMPLE
    New-AGMOrg -jsonbody {"@type":"organizationRest","name":"avtest","description":"test team","resourcecollection":{"sltlist":["43073490","38356288","4583"],"hostlist":["5569125"],"slplist":["5552517"],"userlist":["52122754"],"poollist":["5552670","5552672"]}}

    Creates a new Org called avtest with a description of "test team" and a variety of resources, using a JSON body.
    #>

    $datefields = "modifydate,createdate"
    if (!($jsonbody))
    {
        if (!($orgname)) 
        {
            $orgname = Read-Host "OrgName"
        }
       
        if ($applist) 
        {  
            $appgrab = @{applist=@($applist.Split(","))}
        }
        else 
        {
            $appgrab=@{}    
        }

        if ($arraylist) 
        {  
            $arraygrab = @{arraylist=@($arraylist.Split(","))}
        }
        else 
        {
            $arraygrab=@{}    
        }

        if ($hostlist) 
        {  
            $hostgrab = @{hostlist=@($hostlist.Split(","))}
        }
        else 
        {
            $hostgrab=@{}    
        }

        if ($lglist) 
        {  
            $lggrab = @{lglist=@($lglist.Split(","))}
        }
        else 
        {
            $lggrab=@{}    
        }

        if ($poollist) 
        {  
            $poolgrab = @{poollist=@($poollist.Split(","))} 
        }
        else 
        {
            $poolgrab=@{}    
        }
       
        if ($slplist) 
        {  
            $slpgrab =  @{slplist=@($slplist.Split(","))} 
        }
        else 
        {
            $slpgrab=@{}    
        }
       
        if ($sltlist) 
        {  
            $sltgrab = @{sltlist=@($sltlist.Split(","))}
        }
        else 
        {
            $sltgrab=@{}    
        }
        
        if ($userlist) 
        {  
            $usergrab = @{userlist=@($userlist.Split(","))}
        }
        else 
        {
            $usergrab=@{}  
        }

        $resourcecollection = @{}
        $resourcecollection+=$appgrab
        $resourcecollection+=$arraygrab
        $resourcecollection+=$hostgrab
        $resourcecollection+=$lggrab
        $resourcecollection+=$poolgrab
        $resourcecollection+=$sltgrab
        $resourcecollection+=$slpgrab
        $resourcecollection+=$usergrab

        $body = [ordered]@{"@type"="organizationRest";name=$orgname;description=$description;resourcecollection=$resourcecollection}
        $jsonbody = $body | ConvertTo-Json

    }
    Post-AGMAPIData -endpoint /org -body $jsonbody -datefields $datefields
}

function Update-AGMOrg ([string]$orgid,[string]$orgname,[string]$description,[string]$jsonbody)
{
    <#  
    .SYNOPSIS
    Updates an AGM Organization

    .DESCRIPTION
    The Update-AGMOrg is used to modify an Organization, changings it's name, description or members.  

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Update-AGMOrg -orgid 53795913 -orgname avtest5 -description "Org for AV"

    Updates org ID 53795913 with orgname of avtest5 and a description of "Org for AV".  Note if these are the current values, the command will still run.

    .EXAMPLE
    Update-AGMOrg -orgid 53795913 -jsonbody '{"@type":"organizationRest","id":"53795913","name":"avtest3","description":"test org"}'
    
    Modifies org ID 53795913 to change it's name to avtest3 and its description to "test org"
  
    #>
    $datefields = "modifydate,createdate"
    if (!($orgid))
    {
        [string]$orgid = Read-Host "OrgID to update"
    }
    if (!($jsonbody))
    { 
        $body = [ordered]@{"@type"="organizationRest";name=$orgname;description=$description;resourcecollection=$resourcecollection}
        $jsonbody = $body | ConvertTo-Json 
    }
    
    Put-AGMAPIData -endpoint /org/$orgid -body $jsonbody -datefields $datefields
}


function New-AGMRole ([string]$rolename,[string]$description,[string]$jsonbody)
{
    <#  
    .SYNOPSIS
    Creates a new Role on AGM

    .DESCRIPTION
    The New-AGMRole is used to create a new Role.   

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    New-AGMRole DevUsers
    Creates a new role called DevUsers

    .EXAMPLE
    New-AGMRole -rolename DevUsers
    Creates a new role called DevUsers

    #>


    $datefields = "modifydate,createdate"
    if (!($jsonbody))
    {
        if (!($rolename)) 
        {
            $rolename = Read-Host "RoleName"
        }

        if (!($description))
        {
            $description = Read-Host "Description"
        }
        $body = @{name=$rolename;description=$description}
        $jsonbody = $body | ConvertTo-Json
    }
    Post-AGMAPIData -endpoint /role -body $jsonbody -datefields $datefields
}



function Set-AGMOrgApplication ([string]$orglist,[string]$appid,[string]$jsonbody)
{
    <#  
    .SYNOPSIS
    Sets which AGM Organizations an application is in 

    .DESCRIPTION
    The Set-AGMOrgApplication is used to determine which organizations an application is in.  This command replaces existing memberships, it doesn't add to existing memberships.

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Set-AGMOrgApplication -orglist "4715,159413" -appid 5569144

    Changes appid 5569144 so that it is now a member of orgs 4715 and 159413.   
    Any previous memberships are replaced.  Note multiple org IDs, need to be comma separated and enclosed by double quotes

    .EXAMPLE
    Set-AGMOrgApplication -appid 5569144 -jsonbody '{"@type":"applicationRest","orglist":[{"id":"159413"},{"id":"4715"}],"sensitivity":0,"ispartofmemberrule":false}'
    
    Changes appid 5569144 so that it is now a member of orgs 4715 and 159413.   
    Any previous memberships are replaced
  
    #>
    
    $datefields = "modifydate,syncdate"
    if (!($appid))
    {
        [string]$appid = Read-Host "AppID to update"
    }
    if (!($jsonbody))
    { 
        if (!($orglist))
        {
          [string]$orglist = Read-Host "OrgIDs to update"
        }
        if ( ($orglist) -and ($orglist -ne "0") ) 
        {
            $orggrab = @(
                foreach ($org in $orglist.Split(","))
                {
                    @{
                        id = $org
                    }
                }
            )
            $body = [ordered]@{"@type"="applicationRest";"orglist"=$orggrab}
            $jsonbody = $body | ConvertTo-Json
        }

        if ($orglist -eq "0")
        {
            $jsonbody='{"@type":"applicationRest","orglist":[]}'
        }
    }
    
    Put-AGMAPIData -endpoint /application/$appid -body $jsonbody -datefields $datefields
}

function Set-AGMOrgHost ([string]$orglist,[string]$hostid,[string]$jsonbody)
{
    <#  
    .SYNOPSIS
    Sets which AGM Organizations a host is in 

    .DESCRIPTION
    The Set-AGMOrgHost is used to determine which organizations a host is in.  This command replaces existing memberships, it doesn't add to existing memberships.

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Set-AGMOrgHost -orglist "4715,159413" -hostid 5569144

    Changes hostid 5569144 so that it is now a member of orgs 4715 and 159413.   
    Any previous memberships are replaced.  Note multiple org IDs, need to be comma separated and enclosed by double quotes

    .EXAMPLE
    Set-AGMOrgHost -orglist 0 -hostid 5569144

    Changes hostid 5569144 so that it is no longer a member of any org.
    Any previous memberships are replaced.  Note multiple org IDs, need to be comma separated and enclosed by double quotes

    .EXAMPLE
    Set-AGMOrgHost -hostid 5569144 -jsonbody '{"@type":"hostRest","orglist":[{"id":"159413"},{"id":"4715"}]}'
    
    Changes host id 5569144 so that it is now a member of orgs 4715 and 159413.   
    Any previous memberships are replaced
  
    #>
    
    $datefields = "modifydate,syncdate"
    if (!($hostid))
    {
        [string]$hostid = Read-Host "Host ID to update"
    }
    if (!($jsonbody))
    { 
        if (!($orglist))
        {
          [string]$orglist = Read-Host "OrgIDs to update"
        }
        if ( ($orglist) -and ($orglist -ne "0") ) 
        {
            $orggrab = @(
                foreach ($org in $orglist.Split(","))
                {
                    @{
                        id = $org
                    }
                }
            )
            $body = [ordered]@{"@type"="hostRest";"orglist"=$orggrab}
            $jsonbody = $body | ConvertTo-Json
        }
        if ($orglist -eq "0")
        {
            $jsonbody='{"@type":"hostRest","orglist":[]}'
        }
    }
    
    Put-AGMAPIData -endpoint /host/$hostid -body $jsonbody -datefields $datefields
}

function Set-AGMOrgLogicalGroup ([string]$orglist,[string]$groupid,[string]$jsonbody) 
{
    <#  
    .SYNOPSIS
    Sets which AGM Organizations a logical group is in 

    .DESCRIPTION
    The Set-AGMOrgLogicalGroup  is used to determine which organizations a logical group is in.  This command replaces existing memberships, it doesn't add to existing memberships.

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Set-AGMOrgLogicalGroup -orglist "4715,159413" -groupid 40490815

    Changes logical group 5569144 so that it is now a member of orgs 4715 and 159413.   
    Any previous memberships are replaced.  Note multiple org IDs, need to be comma separated and enclosed by double quotes

    .EXAMPLE
    Set-AGMOrgLogicalGroup -orglist 0 -groupid 40490815

    Changes logical group 5569144 so that it is no longer a member of any org.

    .EXAMPLE
    Set-AGMOrgLogicalGroup  -groupid 40490815 -jsonbody '{"@type":"logicalGroupRest","orglist":[{"id":"159413"},{"id":"4715"}]}'
    
    Changes logical group id 5569144 so that it is now a member of orgs 4715 and 159413.   
    Any previous memberships are replaced
  
    #>
    
    $datefields = "modifydate,syncdate"
    if (!($groupid))
    {
        [string]$groupid = Read-Host "Logical Group ID to update"
    }
    if (!($jsonbody))
    { 
        if (!($orglist))
        {
          [string]$orglist = Read-Host "OrgIDs to update"
        }
        if ( ($orglist) -and ($orglist -ne "0") ) 
        {
            $orggrab = @(
                foreach ($org in $orglist.Split(","))
                {
                    @{
                        id = $org
                    }
                }
            )
            $body = [ordered]@{"@type"="logicalGroupRest";"orglist"=$orggrab}
            $jsonbody = $body | ConvertTo-Json
        }
        if ($orglist -eq "0")
        {
            $jsonbody='{"@type":"logicalGroupRest","orglist":[]}'
        }
    }
    
    Put-AGMAPIData -endpoint /logicalgroup/$groupid -body $jsonbody -datefields $datefields
}
