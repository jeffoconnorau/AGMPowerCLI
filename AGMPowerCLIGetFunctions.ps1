#appliance

function Get-AGMAppliance ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "syncdate"
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
        Get-AGMAPIData -endpoint /cluster -filtervalue $filtervalue -datefields $datefields
    }
    else
    {
        Get-AGMAPIData -endpoint /cluster -datefields $datefields
    }
}

# Application

function Get-AGMApplication ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "syncdate"
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
        Get-AGMAPIData -endpoint /application -filtervalue $filtervalue -datefields $datefields
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /application -keyword $keyword -datefields $datefields    
    } 
    else
    {
        Get-AGMAPIData -endpoint /application -datefields $datefields
    }
}

function Get-AGMApplicationActiveImage ([Parameter(Mandatory=$true)][int]$id)
{
    $datefields = "backupdate,modifydate,consistencydate"
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/activeimage -datefields $datefields
    }
}

function Get-AGMApplicationAppClass ([Parameter(Mandatory=$true)][int]$id)
{
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/appclass
    }
}

function Get-AGMApplicationBackup ([Parameter(Mandatory=$true)][int]$id)
{
    $datefields = "backupdate,modifydate,consistencydate,beginpit,endpit"
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/backup -datefields $datefields
    }
}

function Get-AGMApplicationTypes 
{
    Get-AGMAPIData -endpoint /application/types
}


function Get-AGMApplicationWorkflow ([Parameter(Mandatory=$true)][int]$id)
{
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/workflow
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
function Get-AGMAudit ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "issuedate"
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
        Get-AGMAPIData -endpoint /localaudit -filtervalue $filtervalue -datefields $datefields
    }
    else
    {
        Get-AGMAPIData -endpoint /localaudit -datefields $datefields
    }
}



# Consistency group

function Get-AGMConsistencyGroup ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "syncdate"
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
        Get-AGMAPIData -endpoint /consistencygroup -filtervalue $filtervalue -datefields $datefields
    }
    else
    {
        Get-AGMAPIData -endpoint /consistencygroup -datefields $datefields
    }
}

# Disk pool

function Get-AGMDiskPool([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "modifydate"
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
        Get-AGMAPIData -endpoint /diskpool -filtervalue $filtervalue -datefields $datefields
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /diskpool -keyword $keyword -datefields $datefields   
    } 
    else
    {
        Get-AGMAPIData -endpoint /diskpool -datefields $datefields
    }
}

# Event

function Get-AGMEvent ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "eventdate,syncdate"
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
        Get-AGMAPIData -endpoint /event -filtervalue $filtervalue -datefields $datefields
    }
    else
    {
        Get-AGMAPIData -endpoint /event -datefields $datefields
    }
}

#host 

function Get-AGMHost ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "modifydate,syncdate"
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
        Get-AGMAPIData -endpoint /host -filtervalue $filtervalue -datefields $datefields
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /host -keyword $keyword -datefields $datefields
    } 
    else
    {
        Get-AGMAPIData -endpoint /host -datefields $datefields
    }
}

#Image (backup) 

function Get-AGMImage ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "backupdate,modifydate,consistencydate,expiration,beginpit,endpit"
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
        Get-AGMAPIData -endpoint /backup -filtervalue $filtervalue -datefields $datefields
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /backup -keyword $keyword -datefields $datefields    
    } 
    else
    {
        Get-AGMAPIData -endpoint /backup -datefields $datefields
    }
}

#job

function Get-AGMJob ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "queuedate,expirationdate,startdate"
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
        Get-AGMAPIData -endpoint /job -filtervalue $filtervalue -datefields $datefields
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /job -keyword $keyword -datefields $datefields
    } 
    else
    {
        Get-AGMAPIData -endpoint /job -datefields $datefields
    }
}

function Get-AGMJobCountSummary 
{
    Get-AGMAPIData -endpoint /job/countsummary
}


#jobhistory

function Get-AGMJobHistory ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options)
{
    $datefields = "queuedate,expirationdate,startdate,consistencydate,enddate"
    if ($options)
    { 
        Get-AGMAPIData -endpoint /jobhistory -o 
    }
    elseif ($filtervalue)
    { 
        Get-AGMAPIData -endpoint /jobhistory -filtervalue $filtervalue -datefields $datefields
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /jobhistory -keyword $keyword -datefields $datefields   
    } 
    else
    {
        Get-AGMAPIData -endpoint /jobhistory -datefields $datefields
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

function Get-AGMLogicalGroup ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "modifydate,syncdate"
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
        Get-AGMAPIData -endpoint /logicalgroup -filtervalue $filtervalue -datefields $datefields
    }
    else
    {
        Get-AGMAPIData -endpoint /logicalgroup -datefields $datefields
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

function Get-AGMOrg ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "modifydate,createdate"
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
        Get-AGMAPIData -endpoint /org -filtervalue $filtervalue -datefields $datefields
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /org -keyword $keyword -datefields $datefields  
    } 
    else
    {
        Get-AGMAPIData -endpoint /org -datefields $datefields
    }
}


#right

function Get-AGMRight ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
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
        Get-AGMAPIData -endpoint /right -filtervalue $filtervalue
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /right -keyword $keyword   
    } 
    else
    {
        Get-AGMAPIData -endpoint /right
    }
}

#role

function Get-AGMRole ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "createdate"
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
        Get-AGMAPIData -endpoint /role -filtervalue $filtervalue -datefields $datefields
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /role -keyword $keyword -datefields $datefields  
    } 
    else
    {
        Get-AGMAPIData -endpoint /role -datefields $datefields
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

function Get-AGMSLA ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "modifydate,syncdate"
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
        Get-AGMAPIData -endpoint /sla -filtervalue $filtervalue -datefields $datefields
    }
    else
    {
        Get-AGMAPIData -endpoint /sla -datefields $datefields
    }
}

#SLP 
function Get-AGMSLP ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "modifydate,syncdate,createdate"
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
        Get-AGMAPIData -endpoint /slp -filtervalue $filtervalue -datefields $datefields
    }
    else
    {
        Get-AGMAPIData -endpoint /slp -datefields $datefields
    }
}

#SLT 
function Get-AGMSLT ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
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
        Get-AGMAPIData -endpoint /slt -filtervalue $filtervalue
    }
    else
    {
        Get-AGMAPIData -endpoint /slt
    }
}




# upgrade

function Get-AGMUpgradeHistory
{
    Get-AGMAPIData -endpoint /config/upgradehistory
}

#user

function Get-AGMUser ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    $datefields = "createdate"
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
        Get-AGMAPIData -endpoint /user -filtervalue $filtervalue -datefields $datefields
    }
    else
    {
        Get-AGMAPIData -endpoint /user -datefields $datefields
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

function Get-AGMWorkFlow ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options)
{
    if ($options)
    { 
        Get-AGMAPIData -endpoint /workflow -o
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /workflow -filtervalue $filtervalue
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /workflow -keyword $keyword   
    } 
    else
    {
        Get-AGMAPIData -endpoint /workflow
    }
}


