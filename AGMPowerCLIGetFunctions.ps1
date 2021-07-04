#appliance

function Get-AGMAppliance ([string]$id,[string]$filtervalue,[switch][alias("o")]$options,[int]$limit,[string]$sort)
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
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
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

function Get-AGMApplication ([string]$id,[string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
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
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
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

function Get-AGMApplicationActiveImage ([Parameter(Mandatory=$true)][string]$id,[int]$limit,[string]$sort)
{
<#
    .SYNOPSIS
    Gets details about Application Active Images (mounts)

    .EXAMPLE
    Get-AGMApplicationActiveImage
    Will display all Active Images after prompting for an Application ID

    .EXAMPLE
    Get-AGMApplicationActiveImage -id 200
    Display Active images for Application ID 200

    .EXAMPLE
    Get-AGMApplicationActiveImage -limit 2 -id 200
    Display two Active images for Application ID 200
    
    .EXAMPLE
    Get-AGMApplicationActiveImage -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMApplicationActiveImage -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display Active Images (mounts) for a specified Application
    
    #>

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

function Get-AGMApplicationAppClass ([Parameter(Mandatory=$true)][string]$id,[string]$operation,[string]$hostid)
{
<#
    .SYNOPSIS
    Gets details about the Application class of a specified application.  This is used during mount operations.

    .EXAMPLE
    Get-AGMApplicationAppClass
    Will display the application class details after prompting for an Application ID

    .EXAMPLE
    Get-AGMApplicationAppClass -id 705065
    Display Application Class info for application ID 705065

    .EXAMPLE
    Get-AGMApplicationAppClass -id 705065 -hostid 1234
    Display Application Class info for application ID 705065 when mounting to host ID 1234

    .EXAMPLE
    Get-AGMApplicationAppClass -id 705065 -hostid 1234 -operation clone
    Display Application Class info for application ID 705065 when cloning to host ID 1234

    .DESCRIPTION
    A function to display application class details for an application.
    
    #>

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

function Get-AGMApplicationInstanceMember ([Parameter(Mandatory=$true)][string]$id,[int]$limit,[string]$sort)
{
<#
    .SYNOPSIS
    Gets a list of members for an instance group type application (like an MS SQL Instance)

    .EXAMPLE
    Get-AGMApplicationInstanceMember
    Will display all members of a prompted application

    .EXAMPLE
    Get-AGMApplicationInstanceMember -id 705065
    Will display all members for application ID 705065   

    .DESCRIPTION
    A function to display members for a grouped instance application type.
    
    #>

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

function Get-AGMApplicationMember ([Parameter(Mandatory=$true)][string]$id,[int]$limit,[string]$sort)
{
<#
    .SYNOPSIS
    Gets a list of members for a group type application 

    .EXAMPLE
    Get-AGMApplicationMember 
    Will display all members of a prompted application

    .EXAMPLE
    Get-AGMApplicationMember  -id 705065
    Will display all members for application ID 705065   

    .DESCRIPTION
    A function to display members for a grouped application type.
    
    #>


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
    <#
    .SYNOPSIS
    Get list of Application Types

    .EXAMPLE
    Get-AGMApplicationTypes 
    Will display a list of application types known to AGM

    .DESCRIPTION
    A function to display Application Types.   
    
    #>


    Get-AGMAPIData -endpoint /application/types
}

function Get-AGMApplicationWorkflow ([Parameter(Mandatory=$true)][string]$id,[int]$limit,[string]$sort)
{
 <#
    .SYNOPSIS
    Gets a list of workflows for a specific application

    .EXAMPLE
    Get-AGMApplicationWorkflow
    Will display all Audit entries

    .EXAMPLE
    Get-AGMApplicationWorkflow -id 705065
    Will display workflows for application ID 705065   

    .DESCRIPTION
    A function to display workflows for a specified application ID.
    
    #>

    if (!($sort))
    {
        $sort = ""
    }
    if ($id)
    {
        Get-AGMAPIData -endpoint /application/$id/workflow -limit $limit -sort $sort
    }
}

function Get-AGMApplicationWorkflowStatus ([Parameter(Mandatory=$true)][string]$id,[Parameter(Mandatory=$true)][string]$workflowid)
{
 <#
    .SYNOPSIS
    Gets the status of a specific workflow for a specific application ID

    .EXAMPLE
    Get-AGMApplicationWorkflowStatus -id 705065 -workflowid 3378203
    Will display workflows for application ID 705065, workflow ID  3378203  

    .DESCRIPTION
    A function to display workflows status for a specified application ID and workflow ID
    
    #>


    if (($id) -and ($workflowid))
    {
        Get-AGMAPIData -endpoint /application/$id/workflow/$workflowid -itemoverride
    }
}

# Audit
function Get-AGMAudit ([string]$filtervalue,[switch][alias("o")]$options,[string]$id,[int]$limit,[string]$sort)
{
  <#
    .SYNOPSIS
    Gets a list of Audit log entries.  This could be a very long list.

    .EXAMPLE
    Get-AGMAudit
    Will display all Audit entries

    .EXAMPLE
    Get-AGMAudit -id 1234
    Will display audit ID 1234.   

    .EXAMPLE
    Get-AGMAudit -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMAudit -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMAudit -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
    Get-AGMAudit -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMAudit -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMAudit -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display audit log entries.  The returned list can be huge.   Always use limits or filters.
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>


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

function Get-AGMConsistencyGroup ([string]$id,[string]$filtervalue,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
  <#
    .SYNOPSIS
    Gets a list of Consistency Groups

    .EXAMPLE
    Get-AGMConsistencyGroup
    Will display all consistency groups.   

    .EXAMPLE
    Get-AGMConsistencyGroup -id 1234
    Will display consistency group 1234.   

    .EXAMPLE
    Get-AGMConsistencyGroup -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMConsistencyGroup -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMConsistencyGroup -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
    Get-AGMConsistencyGroup -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMConsistencyGroup -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMConsistencyGroup -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display consistency groups
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
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

# cloud credentials
function Get-AGMCredential 
{
<#
    .SYNOPSIS
    Gets details about the stored cloud credentials

    .EXAMPLE
    Get-AGMCredential
    Will display the cloud credentials

    .DESCRIPTION
    A function to display cloud credentials
    
    #>

     Get-AGMAPIData -endpoint /cloudcredential        
}



# Disk pool

function Get-AGMDiskPool([string]$id,[string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
   <#
    .SYNOPSIS
    Gets a list of disk pools known to AGM

    .EXAMPLE
    Get-AGMDiskPool
    Will display all diskpools.  

    .EXAMPLE
    Get-AGMDiskPool -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMDiskPool -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMDiskPool -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
    Get-AGMDiskPool -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMDiskPool -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMDiskPool -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display disk pools known to AGM.  Diskpools are owned by Appliances.
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>


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

function Get-AGMEvent ([string]$id,[string]$filtervalue,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
    <#
    .SYNOPSIS
    Gets a list of events that AGM has tracked

    .EXAMPLE
    Get-AGMEvent
    Will display all events.   This may be a very long list.

    .EXAMPLE
    Get-AGMEvent -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMEvent -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMEvent -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
    Get-AGMEvent -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMEvent -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMEvent -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display events known to AGM.   The returned list can be huge.   Always use limits or filters.
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>

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

function Get-AGMHost ([string]$id,[string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
<#
    .SYNOPSIS
    Gets a list of hosts known to AGM.  

    .EXAMPLE
    Get-AGMHost
    Will display all hosts.   This may be a very long list.

    .EXAMPLE
    Get-AGMHost -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMHost -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMHost -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
     Get-AGMHost -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMHost -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMHost -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display hosts known to AGM.   The returned list can be huge.   Always use limits or filters.
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>


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

function Get-AGMImage ([string]$id,[string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
<#
    .SYNOPSIS
    Gets a list of images.  It is not recommended to run this command without filters.

    .EXAMPLE
    Get-AGMImage
    Will display all images.  This will be a very long list.

    .EXAMPLE
    Get-AGMImage -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMImage -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMImage -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
    Get-AGMImage -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMImage -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMImage -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display all images known to AGM.  The returned list can be huge.   Always use limits or filters.
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>

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
<#
    .SYNOPSIS
    Gets a list of system state recovery options for a specified image.

    .EXAMPLE
    Get-AGMImageSystemStateOptions
    Will request an image ID and then show the system state recovery options

    .EXAMPLE
    Get-AGMImageSystemStateOptions -id 1234
    Will show the system state recovery options for image ID 1234.

    .EXAMPLE
    Get-AGMImageSystemStateOptions -id 1234 -target GCP
    Will show the system state recovery options for image ID 1234 when being used with GCP

    .DESCRIPTION
    A function to display system state recovery information.  
    
    #>


    if ($id) { $imageid = $id }
    if (!($imageid))
    {
        [string]$id = Read-Host "ImageID"
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

function Get-AGMJob ([string]$id,[string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
<#
    .SYNOPSIS
    Gets a list of running and queued jobs on an AGM.  

    .EXAMPLE
    Get-AGMJob
    Will display all running and queued jobs

    .EXAMPLE
    Get-AGMJob -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMJob -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMJob -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
    Get-AGMJob -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMJob -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMJob -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display jobs in the running or queued status on an AGM.  
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>

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
        Get-AGMAPIData -endpoint /job/$id -datefields $datefields -duration
    }
    elseif ($filtervalue)
    {
        Get-AGMAPIData -endpoint /job -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort -duration
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /job -keyword $keyword -datefields $datefields -limit $limit -sort $sort -duration
    } 
    else
    {
        Get-AGMAPIData -endpoint /job -datefields $datefields -limit $limit -sort $sort -duration
    }
}

#jobhistory

function Get-AGMJobHistory ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
<#
    .SYNOPSIS
    Gets a list of finished jobs on an AGM.   It is not recommended to run this command without filters.

    .EXAMPLE
    Get-AGMJobHistory
    Will display all running and completed jobs (regardless of status)

    .EXAMPLE
    Get-AGMJobHistory -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMJobHistory -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMJobHistory -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
    Get-AGMJobHistory -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMJobHistory -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMJobHistory -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display AGM job history.  The returned list can be huge.   Always use limits or filters.
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>


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
        Get-AGMAPIData -endpoint /jobhistory -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort -duration
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /jobhistory -keyword $keyword -datefields $datefields -limit $limit -sort $sort -duration
    } 
    else
    {
        Get-AGMAPIData -endpoint /jobhistory -datefields $datefields -limit $limit -sort $sort -duration
    }
}


#jobstatus

function Get-AGMJobStatus ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
<#
    .SYNOPSIS
    Gets a list of running and finished jobs on an AGM.   It is not recommended to run this command without filters.

    .EXAMPLE
    Get-AGMJobStatus
    Will display all running and completed jobs (regardless of status)

    .EXAMPLE
    Get-AGMJobStatus -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMJobStatus -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMJobStatus -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
    Get-AGMJobStatus -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMJobStatus -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMJobStatus -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display AGM job status.  This is a great way to find status of job regardless of whether it has finished or not.   But the returned list can be huge.   Always use limits or filters.
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>


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
        Get-AGMAPIData -endpoint /jobstatus -filtervalue $filtervalue -datefields $datefields -limit $limit -sort $sort -duration
    }
    elseif ($keyword)
    {
        Get-AGMAPIData -endpoint /jobstatus -keyword $keyword -datefields $datefields -limit $limit -sort $sort -duration
    } 
    else
    {
        Get-AGMAPIData -endpoint /jobstatus -datefields $datefields -limit $limit -sort $sort -duration
    }
}


#LDAP

function Get-AGMLDAPConfig
{
<#
    .SYNOPSIS
    Display the LDAP Config

    .EXAMPLE
    Get-AGMLDAPConfig
    Will display the LDAP Config values

    .DESCRIPTION
    A function to display the LDAP Config
    
    #>

    Get-AGMAPIData -endpoint /ldap/config
}

function Get-AGMLDAPGroup 
{
<#
    .SYNOPSIS
    Display the LDAP Group Mapping

    .EXAMPLE
    Get-AGMLDAPGroup
    Will display the LDAP Group to Role and Org Mapping

    .DESCRIPTION
    A function to display the LDAP group config
    
    #>

    Get-AGMAPIData -endpoint /ldap/group
}

# Logical group

function Get-AGMLogicalGroup ([string]$id,[string]$filtervalue,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
<#
    .SYNOPSIS
    Gets a list of AGM Logical Groups.  Logical groups are simple groups of Applications with the same SLT/SLP

    .EXAMPLE
    Get-AGMLogicalGroup 
    Will display all logical groups

    .EXAMPLE
    Get-AGMLogicalGroup  -id 3
    Will display logical group ID 3

    .EXAMPLE
    Get-AGMLogicalGroup -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMLogicalGroup -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMLogicalGroup -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
    Get-AGMLogicalGroup -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMLogicalGroup -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMLogicalGroup -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display AGM Logical Groups
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>


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



function Get-AGMLogicalGroupMember ([Parameter(Mandatory=$true)][string]$id)
{
<#
    .SYNOPSIS
    Gets a list of members in an AGM Logical Group.  Logical groups are simple groups of Applications with the same SLT/SLP

    .EXAMPLE
    Get-AGMLogicalGroupMember
    Will display all members of a requested logical group

    .EXAMPLE
    Get-AGMLogicalGroupMember -id 6547835
    Will display logical group ID 6547835

    .DESCRIPTION
    A function to display members in an AGM Logical Group
    
    #>

    if ($id)
    {
        Get-AGMAPIData -endpoint /logicalgroup/$id/member
    }
}


#org

function Get-AGMOrg ([string]$id,[string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
<#
    .SYNOPSIS
    Gets a list of AGM Organizations (Orgs).  Organizations are used to manage what things an AGM user can work with

    .EXAMPLE
    Get-AGMOrg
    Will display all Orgs

    .EXAMPLE
    Get-AGMOrg -id 3
    Will display org ID 3

    .EXAMPLE
    Get-AGMOrg -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMOrg -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMOrg -filtervalue id=3
    Looks for any object with id 3

    .EXAMPLE
    Get-AGMOrg -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMOrg -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMOrg -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display AGM Orgs
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>

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

function Get-AGMRight ([string]$id)
{
<#
    .SYNOPSIS
    Gets a list of AGM Rights.  Rights are used to manage what an AGM User can do as part of their role.

    .EXAMPLE
    Get-AGMRight
    Will display all Rights

    .EXAMPLE
    Get-AGMRight -id "Backup Manage"
    Will display the right title "Backup Manage"

    .DESCRIPTION
    A function to display AGM Rights
    
    #>


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

function Get-AGMRole ([string]$id,[string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
 <#
    .SYNOPSIS
    Gets a list of AGM Roles.  Roles are used to manage what rights (ACLs) an AGM user has

    .EXAMPLE
    Get-AGMRole
    Will display all Roles

    .EXAMPLE
    Get-AGMRole -id 2
    Will display role ID 2

    .EXAMPLE
    Get-AGMRole -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMRole -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMRole -filtervalue id=1234
    Looks for any object with id 1234

    .EXAMPLE
    Get-AGMRole -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMRole -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMRole -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display AGM Roles
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>


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
    <#
    .SYNOPSIS
    Displays the current Session to AGM

    .EXAMPLE
    Get-AGMSession
    Will display the current session ID

    .EXAMPLE
    Get-AGMSession -sessionid "8b3cf06-c16c-42c9-b518-09c1e6874f65"
    Will display details about the specified session ID

    .DESCRIPTION
    A function to display the session ID details.   A session ID is created when you run Connect-AGM and destroyed when you run Disconnect-AGM
    
    #>



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

function Get-AGMSLA ([string]$id,[string]$filtervalue,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
 <#
    .SYNOPSIS
    Gets a list of Service Level Agreements (SLAs)

    .EXAMPLE
    Get-AGMSLA
    Will display all SLPs

    .EXAMPLE
    Get-AGMSLA -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMSLA -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMSLA -filtervalue id=1234
    Looks for any object with id 1234

    .EXAMPLE
    Get-AGMSLA -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMSLA -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMSLA -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display AGM SLAs
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>



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
function Get-AGMSLP ([string]$id,[string]$filtervalue,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
    <#
    .SYNOPSIS
    Gets a list of AGM Service Level Profiles (SLPs)

    .EXAMPLE
    Get-AGMSLP
    Will display all SLPs

    .EXAMPLE
    Get-AGMSLP -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMSLP -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMSLP -filtervalue id=1234
    Looks for any object with id 1234

    .EXAMPLE
    Get-AGMSLP -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMSLP -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMSLP -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display AGM SLPs
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>
    
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
function Get-AGMSLT ([string]$id,[string]$filtervalue,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
    <#
    .SYNOPSIS
    Gets a list of AGM Service Level Templates (SLTs)

    .EXAMPLE
    Get-AGMSLT
    Will display all SLTs

    .EXAMPLE
    Get-AGMSLT -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMSLT -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMSLT -filtervalue id=1234
    Looks for any object with id 1234

    .EXAMPLE
    Get-AGMSLT -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMSLT -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMSLT -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display AGM SLTs
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>


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
    <#
    .SYNOPSIS
    Gets a list of policies for a specific Service Level Template (SLT)

    .EXAMPLE
    Get-AGMSLTPolicy
    Will display all policies for a requested SLT ID

    .EXAMPLE
    Get-AGMSLTPolicy -id 6452877
    Will display all policies for SLT ID 6452877

    .DESCRIPTION
    A function to display AGM SLTs
    
    #>

    if ( (!($id)) -and (!($options)) )
    {
        [string]$id = Read-Host "SLTID"
    }
    # if user doesn't ask for a limit, send 0 so we know to ignore it
    if (!($limit))
    { 
        $limit = "0"
    }
    Get-AGMAPIData -endpoint /slt/$id/policy -limit $limit
}

#user

function Get-AGMUser ([string]$id,[string]$filtervalue,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
   <#
    .SYNOPSIS
    Gets a list of AGM Users

    .EXAMPLE
    Get-AGMUser
    Will display all Users

    .EXAMPLE
    Get-AGMUser -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMUser -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMUser -filtervalue id=1234
    Looks for any object with id 1234

    .EXAMPLE
    Get-AGMUser -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMUser -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMUser -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display AGM Users
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>


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
    <#
    .SYNOPSIS
    Gets the AGM Version

    .EXAMPLE
    Get-AGMVersion
    Will display the version of the AGM
    #>

    Get-AGMAPIData -endpoint /config/version
}

function Get-AGMVersionDetail
{
    <#
    .SYNOPSIS
    Gets the AGM Version with some extra details

    .EXAMPLE
    Get-AGMVersion
    Will display the version of the AGM
    #>

    $datefields = "installed"
    Get-AGMAPIData -endpoint /config/versiondetail -datefields $datefields
}

#workflow

function Get-AGMWorkFlow ([string]$filtervalue,[string]$keyword,[switch][alias("o")]$options,[int]$limit,[string]$sort)
{
   <#
    .SYNOPSIS
    Gets a list of workflows

    .EXAMPLE
    Get-AGMWorkFlow
    Will display all workflows

    .EXAMPLE
    Get-AGMWorkFlow -limit 2
    Will display a maximum of two objects 

    .EXAMPLE
    Get-AGMWorkFlow -o
    To display all fields that can be filtered with filtervalue

    .EXAMPLE
    Get-AGMWorkFlow -filtervalue id=1234
    Looks for any object with id 1234

    .EXAMPLE
    Get-AGMWorkFlow -filtervalue "id>1234&name~sky"
    Looks for any object with id greater than 1234 and a name like sky.   

    .EXAMPLE
    Get-AGMWorkFlow -sort id:desc
    Displays all objects sorting on ID descending.  

    .EXAMPLE
    Get-AGMWorkFlow -sort "id:desc,name:asc"
    Displays all objects sorting on ID descending and name ascending. 

    .DESCRIPTION
    A function to display Applications
    Multiple filtervalues need to be encased in double quotes and separated by the & symbol
    Filtervalues can be =, <, >, ~ (fuzzy) or ! (not)
    Multiple sorts need to be encased in double quotes and separated by the , symbol
    Sorts can only be asc for ascending or desc for descending.
    
    #>

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


