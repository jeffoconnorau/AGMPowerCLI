#appliance

function Get-AGMAppliance ([string]$filtervalue,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{

    <#
    .SYNOPSIS
    Gets details about Appliances

    .EXAMPLE
    Get-AGMAppliance
    Will display all Appliances

    .EXAMPLE
    Get-AGMAppliance -limit 2
    Will display a maximum of two objects 
    
    .EXAMPLE
    Get-AGMAppliance -id 200
    Display only the object with an ID of 200

    .EXAMPLE
    Get-AGMAppliance -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMAppliance -filtervalue id=1234
    Looks for any object with id 1234

    .EXAMPLE
    Get-AGMAppliance -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMAppliance -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMAppliance -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display Appliances
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, > or ~ (fuzzy)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.

    #>

    $datefields = "syncdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /cluster -o
       
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /cluster/$id -datefields $datefields 
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /cluster -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    else
    {
        Get-AGMAPIData -endpoint /cluster -datefields $datefields -limit $limit -sort $sort
    }
}

# Application

function Get-AGMApplication ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{

    <#
    .SYNOPSIS
    Gets details about Applications

    .EXAMPLE
    Get-AGMApplication
    Will display all Applications

    .EXAMPLE
    Get-AGMApplication -limit 2
    Will display a maximum of two objects 
    
    .EXAMPLE
    Get-AGMApplication -id 200
    Display only the object with an ID of 200

    .EXAMPLE
    Get-AGMApplication -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMApplication -filtervalue id=1234
    Looks for any object with id 1234

    .EXAMPLE
    Get-AGMApplication -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMApplication -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMApplication -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display Applications
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, > or ~ (fuzzy)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>


    $datefields = "syncdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /application -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /application/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /application -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /application -keyword $keyword -datefields $datefields -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /application -datefields $datefields -limit $limit -sort $sort
    }
}

function Get-AGMApplicationActiveImage ([Parameter(Mandatory=$true)][int]$id,[int]$limit,[string]$sort)
{
    $datefields = "backupdate,modifydate,consistencydate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/activeimage -datefields $datefields -limit $limit -sort $sort
    }
}

function Get-AGMApplicationAppClass ([Parameter(Mandatory=$true)][int]$id,[string]$operation,[int]$hostid)
{
    if ($hostid)
    {
        $extrarequests = "&hostid=" + $hostid
    }
    if ($operation)
    { 
        $extrarequests = $extrarequests + "&operation=" + $operation
    }
    if ($extrarequests)
    {
        Get-AGMAPIData -endpoint /application/$id/appclass -extrarequests $extrarequests
    }
    else 
    {
        Get-AGMAPIData -endpoint /application/$id/appclass         
    }
}

function Get-AGMApplicationBackup ([Parameter(Mandatory=$true)][int]$id,[int]$limit,[string]$sort)
{
    $datefields = "backupdate,modifydate,consistencydate,beginpit,endpit"
     # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/backup -datefields $datefields -limit $limit -sort $sort
    }
}

function Get-AGMApplicationInstanceMember ([Parameter(Mandatory=$true)][int]$id,[int]$limit,[string]$sort)
{
    $datefields = "backupdate,modifydate,consistencydate,beginpit,endpit"
     # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/instancemembershipdetails -datefields $datefields -limit $limit -sort $sort
    }
}

function Get-AGMApplicationMember ([Parameter(Mandatory=$true)][int]$id,[int]$limit,[string]$sort)
{
    $datefields = "backupdate,modifydate,consistencydate,beginpit,endpit"
     # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/member -datefields $datefields -limit $limit -sort $sort
    }
}

function Get-AGMApplicationTypes 
{
    Get-AGMAPIData -endpoint /application/types
}







function Get-AGMApplicationWorkflow ([Parameter(Mandatory=$true)][int]$id,[int]$limit,[string]$sort)
{
    if (!($sort))
    {
        $sort = ""
    }
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/workflow -limit $limit -sort $sort
    }
}

function Get-AGMApplicationWorkflowStatus ([Parameter(Mandatory=$true)][int]$id,[Parameter(Mandatory=$true)][int]$workflowid)
{
    if (($id) -and ($workflowid))
    {
        Get-AGMAPIData -endpoint /application/$id/workflow/$workflowid
    }
}

# Audit
function Get-AGMAudit ([string]$filtervalue,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "issuedate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /localaudit -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /localaudit/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /localaudit -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    else
    {
        Get-AGMAPIData -endpoint /localaudit -datefields $datefields -limit $limit -sort $sort
    }
}



# Consistency group

function Get-AGMConsistencyGroup ([string]$filtervalue,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "syncdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /consistencygroup -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /consistencygroup/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /consistencygroup -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    else
    {
        Get-AGMAPIData -endpoint /consistencygroup -datefields $datefields -limit $limit -sort $sort
    }
}

# Disk pool

function Get-AGMDiskPool([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "modifydate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /diskpool -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /diskpool/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /diskpool -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /diskpool -keyword $keyword -datefields $datefields -limit $limit -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /diskpool -datefields $datefields -limit $limit -sort $sort
    }
}

# Event

function Get-AGMEvent ([string]$filtervalue,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "eventdate,syncdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /event -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /event/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /event -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    else
    {
        Get-AGMAPIData -endpoint /event -datefields $datefields -limit $limit -sort $sort
    }
}

#host 

function Get-AGMHost ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "modifydate,syncdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /host -o       
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /host/$id -datefields $datefields
    }
    elseif ($filtervalue)
    { 
        Get-AGMAPIData -endpoint /host -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /host -keyword $keyword -datefields $datefields -limit $limit -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /host -datefields $datefields -limit $limit -sort $sort
    }
}

#Image (backup) 

function Get-AGMImage ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "backupdate,modifydate,consistencydate,expiration,beginpit,endpit"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    #$datefields = ""
    if ($options)
    { 
        Get-AGMAPIData -endpoint /backup -o 
    }
    elseif ($id)
    {
        Get-AGMAPIData -endpoint /backup/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /backup -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /backup -keyword $keyword -datefields $datefields -limit $limit -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /backup -datefields $datefields -limit $limit -sort $sort
    }
}

function Get-AGMImageSystemStateOptions ([string]$imageid,[string]$id,[string]$target)
{
    if ($id) { $imageid = $id }
    if (!($imageid))
    {
        [int]$id = Read-Host "ImageID"
    }
    if (!($target))
    {
        Get-AGMAPIData -endpoint /backup/$imageid/systemstateoptions
    }
    else 
    {
        Get-AGMAPIData -endpoint /backup/$imageid/systemstateoptions/$target     
    }
}

#job

function Get-AGMJob ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "queuedate,expirationdate,startdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /job -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /job/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /job -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /job -keyword $keyword -datefields $datefields -limit $limit -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /job -datefields $datefields -limit $limit -sort $sort
    }
}

function Get-AGMJobCountSummary 
{
    Get-AGMAPIData -endpoint /job/countsummary
}


#jobhistory

function Get-AGMJobHistory ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
    $datefields = "queuedate,expirationdate,startdate,consistencydate,enddate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /jobhistory -o 
    }
    elseif ($filtervalue)
    { 
        Get-AGMAPIData -endpoint /jobhistory -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /jobhistory -keyword $keyword -datefields $datefields -limit $limit -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /jobhistory -datefields $datefields -limit $limit -sort $sort
    }
}


#jobstatus

function Get-AGMJobStatus ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
    $datefields = "queuedate,expirationdate,startdate,consistencydate,enddate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /jobstatus -o 
    }
    elseif ($filtervalue)
    { 
        Get-AGMAPIData -endpoint /jobstatus -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /jobstatus -keyword $keyword -datefields $datefields -limit $limit -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /jobstatus -datefields $datefields -limit $limit -sort $sort
    }
}


#LDAP

function Get-AGMLDAPConfig
{
    Get-AGMAPIData -endpoint /ldap/config
}

function Get-AGMLDAPGroup 
{
        Get-AGMAPIData -endpoint /ldap/group
}

# Logical group

function Get-AGMLogicalGroup ([string]$filtervalue,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "modifydate,syncdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /logicalgroup -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /logicalgroup/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /logicalgroup -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    else
    {
        Get-AGMAPIData -endpoint /logicalgroup -datefields $datefields -limit $limit -sort $sort
    }
}



function Get-AGMLogicalGroupMember ([Parameter(Mandatory=$true)][int]$id)
{
    if ($id)
    {
        Get-AGMAPIData -endpoint /logicalgroup/$id/member
    }
}


#org

function Get-AGMOrg ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "modifydate,createdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /org -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /org/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /org -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /org -keyword $keyword -datefields $datefields -limit $limit -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /org -datefields $datefields -limit $limit -sort $sort
    }
}


#right

function Get-AGMRight ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /right -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /right/$id
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /right -filtervalue $filtervalue -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /right -keyword $keyword -limit $limit -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /right -limit $limit -sort $sort
    }
}

#role

function Get-AGMRole ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "createdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /role -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /role/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /role -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /role -keyword $keyword -datefields $datefields -limit $limit -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /role -datefields $datefields -limit $limit -sort $sort
    }
}


#session
function Get-AGMSession  ([String]$sessionid)
{
    if ((!($sessionid)) -and (!($agmsessionid)))
    {
        Write-Host "Please specify a session ID or run Connect-AGM to generate one"
        break    
    }
    if ($sessionid)
    {
        Get-AGMAPIData -endpoint /session/$sessionid
    }
    else
    {
        Get-AGMAPIData -endpoint /session/$agmsessionid
    }
}

#sla

function Get-AGMSLA ([string]$filtervalue,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "modifydate,syncdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /sla -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /sla/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /sla -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    else
    {
        Get-AGMAPIData -endpoint /sla -datefields $datefields -limit $limit -sort $sort
    }
}

#SLP 
function Get-AGMSLP ([string]$filtervalue,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "modifydate,syncdate,createdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /slp -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /slp/$id -datefields $datefields
        
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /slp -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    else
    {
        Get-AGMAPIData -endpoint /slp -datefields $datefields -limit $limit -sort $sort
    }
}

#SLT 
function Get-AGMSLT ([string]$filtervalue,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /slt -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /slt/$id
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /slt -filtervalue $filtervalue -limit $limit -sort $sort
    }
    else
    {
        Get-AGMAPIData -endpoint /slt -limit $limit -sort $sort
    }
}

#SLTPolicy
function Get-AGMSLTPolicy ([string]$id,[int]$limit)
{
    if ( (!($id)) -and (!($options)) )
    {
        [int]$id = Read-Host "SLTID"
    }
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    Get-AGMAPIData -endpoint /slt/$id/policy -limit $limit
}

# upgrade

function Get-AGMUpgradeHistory
{
    Get-AGMAPIData -endpoint /config/upgradehistory
}

#user

function Get-AGMUser ([string]$filtervalue,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
    $datefields = "createdate"
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /user -o 
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /user/$id -datefields $datefields
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /user -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort
    }
    else
    {
        Get-AGMAPIData -endpoint /user -datefields $datefields -limit $limit -sort $sort
    }
}



# Version

function Get-AGMVersion
{
    Get-AGMAPIData -endpoint /config/version
}

function Get-AGMVersionDetail
{
    $datefields = "installed"
    Get-AGMAPIData -endpoint /config/versiondetail -datefields $datefields
}

#workflow

function Get-AGMWorkFlow ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    if (!($sort))
    {
        $sort = ""
    }
    if ($options)
    { 
        Get-AGMAPIData -endpoint /workflow -o
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /workflow -filtervalue $filtervalue -limit $limit -sort $sort
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /workflow -keyword $keyword -limit $limit -sort $sort
    } 
    else
    {
        Get-AGMAPIData -endpoint /workflow -limit $limit -sort $sort
    }
}


