
function Get-AGMVersion
{
    Get-AGMAPIData -endpoint /config/version
}

function Get-AGMVersionDetail
{
    $output = Get-AGMAPIData -endpoint /config/versiondetail
    if ($output.installed)
    {
        $output.installed = Convert-FromUnixDate $output.installed
    }
    $output
}

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

function Get-AGMUpgradeHistory
{
    Get-AGMAPIData -endpoint /config/upgradehistory
}

function Get-AGMLDAPConfig
{
    Get-AGMAPIData -endpoint /ldap/config
}

function Get-AGMLDAPGroup 
{
        Get-AGMAPIData -endpoint /ldap/group
}

function Get-AGMApplication ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    if ($options)
    { 
        Get-AGMAPIData -endpoint /application -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /application/$id
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /application -filtervalue $filtervalue
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /application -keyword $keyword   
    } 
    else
    {
        Get-AGMAPIData -endpoint /application
    }
}

function Get-AGMApplicationActiveImage ([Parameter(Mandatory=$true)][int]$id)
{
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/activeimage
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
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/backup
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


#SLP 
function Get-AGMSLP ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    if ($options)
    { 
        Get-AGMAPIData -endpoint /slp -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /slp/$id
        
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /slp -filtervalue $filtervalue
    }
    else
    {
        Get-AGMAPIData -endpoint /slp
    }
}

#sla

function Get-AGMSLA ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    if ($options)
    { 
        Get-AGMAPIData -endpoint /sla -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /sla/$id
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /sla -filtervalue $filtervalue
    }
    else
    {
        Get-AGMAPIData -endpoint /sla
    }
}

#backup 

function Get-AGMImage ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    if ($options)
    { 
        Get-AGMAPIData -endpoint /backup -o
    }
    elseif ($id)
    {
        Get-AGMAPIData -endpoint /backup/$id
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /backup -filtervalue $filtervalue
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /backup -keyword $keyword   
    } 
    else
    {
        Get-AGMAPIData -endpoint /backup
    }
}


#host 

function Get-AGMHost ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    if ($options)
    { 
        Get-AGMAPIData -endpoint /host -o       
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /host/$id
    }
    elseif ($filtervalue)
    { 
        Get-AGMAPIData -endpoint /host -filtervalue $filtervalue
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /host -keyword $keyword   
    } 
    else
    {
        Get-AGMAPIData -endpoint /host
    }
}

#appliance

function Get-AGMAppliance ([string]$filtervalue,[switch][alias("o")]$options,[string]$id)
{
    if ($options)
    { 
        Get-AGMAPIData -endpoint /cluster -o
       
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /cluster/$id
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /cluster -filtervalue $filtervalue
    }
    else
    {
        Get-AGMAPIData -endpoint /cluster
    }
}

#job

function Get-AGMJob ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[string]$id)
{
    if ($options)
    { 
        Get-AGMAPIData -endpoint /job -o
    }
    elseif ($id)
    { 
        Get-AGMAPIData -endpoint /job/$id
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /job -filtervalue $filtervalue
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /job -keyword $keyword   
    } 
    else
    {
        Get-AGMAPIData -endpoint /job
    }
}

#jobhistory

function Get-AGMJobHistory ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options)
{
    if ($options)
    { 
        Get-AGMAPIData -endpoint /jobhistory -o 
    }
    elseif ($filtervalue)
    { 
        Get-AGMAPIData -endpoint /jobhistory -filtervalue $filtervalue
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /jobhistory -keyword $keyword   
    } 
    else
    {
        Get-AGMAPIData -endpoint /jobhistory 
    }
}
