# Copyright 2022 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



Function Set-AGMConsistencyGroup ([string]$clusterid,[string]$applianceid,[string]$groupid,[string]$groupname,[string]$description) 
{
    <#
    .SYNOPSIS
    A command to set the group name or description of a consistency group

    .EXAMPLE
    Set-AGMConsistencyGroup -applianceid 143112195179 -groupid "12345" -groupname "newname" -description "better description than the last one"

    To learn applianceid, use this command:  Get-AGMAppliance and use the clusterid as applianceid.  
    To learn groupid, use this command:  Get-AGMConsistencyGroup

    .DESCRIPTION
    A function to modify Consistency Groups

    #>
    
    if ($applianceid) { [string]$clusterid = $applianceid}

    if (!($clusterid))
    {
        $clusterid = Read-Host "Appliance ID"
    }
    if (!($groupid))
    {
        [string]$groupid = Read-Host "Group ID"
    }   
 
    # cluster needs to be like:  sources":[{"clusterid":"144488110379"},{"clusterid":"143112195179"}]
    $sources = @()
    foreach ($cluster in $clusterid.Split(","))
    {
        $sources += [ordered]@{ id = $cluster }
    } 

    # {"groupname":"teddybear","description":"WANT A BETTER","cluster":{"id":"70194"},"host":{},"id":"353953"}
    # {"groupname":"teddybear","description":"WANT A BETTER2","cluster":{"id":"70194"},"host":{"id":"70631"},"id":"353953"}

    $body = [ordered]@{}
    if ($description)
    { 
        $body += @{ description = $description }
    }
    if ($groupname)
    { 
        $body += @{ groupname = $groupname }
    }
    $body += [ordered]@{ cluster = $sources;
    id = $groupid 
    }
    $json = $body | ConvertTo-Json

    PUT-AGMAPIData  -endpoint /consistencygroup/$groupid -body $json 
}

Function Set-AGMConsistencyGroupMember ([string]$groupid,[switch]$add,[switch]$remove,[string]$applicationid) 
{
    <#
    .SYNOPSIS
    A command to set the members of a consistency group

    .EXAMPLE
    Set-AGMConsistencyGroupMember -groupid "12345" -add -applicationid "1234"
    To add application ID 1233 to groupid 12345

    .EXAMPLE
    Set-AGMConsistencyGroupMember -groupid "12345" -add -applicationid "1234,5678"
    To add application ID 1233 and 5678 to groupid 12345

     .EXAMPLE
    Set-AGMConsistencyGroupMember -groupid "12345" -remove -applicationid "1234"
    To remove application ID 1233 from groupid 12345

    To learn groupid, use this command:  Get-AGMConsistencyGroup
    To learn application ID, use this command: Get-AGMApplication

    .DESCRIPTION
    A function to modify Consistency Group members

    #>
    
    if (!($groupid))
    {
        [string]$groupid = Read-Host "Group ID"
    }    
    if ( (!($add)) -and (!($remove)) )
    {
        Get-AGMErrorMessage -messagetoprint "You need to specify either -add or -remove"
        return
    }
    if (($add) -and ($remove))
    {
        Get-AGMErrorMessage -messagetoprint "Do not specify add and remove at the same time"
        return
    }

    # [{"action":"add","members":[210645]}]
    # [{"action":"remove","members":[210647]}]
    # [{"action":"add","members":[210647,210645]}]

    $body1 = [ordered]@{}
    if ($add)
    {
        $json = '[{"action":"add","members":[' +$applicationid +']}]'
    }
    if ($remove)
    {
        $json = '[{"action":"remove","members":[' +$applicationid +']}]'
    }

    Post-AGMAPIData -endpoint /consistencygroup/$groupid/member -body $json 
}


Function Set-AGMCredential ([string]$name,[string]$zone,[string]$id,[string]$credentialid,[string]$clusterid,[string]$applianceid,$filename,[string]$projectid) 
{
    <#
    .SYNOPSIS
    Updates a cloud credential

    .EXAMPLE
    Set-AGMCredential -credentialid 1234 -name cred1 -zone australia-southeast1-c -clusterid 144292692833 -filename keyfile.json
    
    To update just the JSON file to the same appliances for credential ID 1234

    .EXAMPLE
    Set-AGMCredential -credentialid 1234 -name cred1 -zone australia-southeast1-c  -filename keyfile.json
    
    To update the JSON file and also the name and default zone for credential ID 1234

    .DESCRIPTION
    A function to update cloud credentials.   You need to supply the 

    #>

    if ($id) { $credentialid = $id }
    if (!($credentialid))
    {
        [string]$credentialid = Read-Host "Credential ID"
    }
    
    if ($applianceid) { [string]$clusterid = $applianceid}

    if (!($filename))
    {
        $filename = Read-Host "JSON key file"
    }
    if ( Test-Path $filename )
    {
        $jsonkey = Get-Content -Path $filename -raw
        $jsonkey = $jsonkey.replace("\n","\\n")
        $jsonkey = $jsonkey.replace("`n","\n ")
        $jsonkey = $jsonkey.replace('"','\"')
    }
    else
    {
        Get-AGMErrorMessage -messagetoprint "The file named $filename could not be found."
        return
    }

    if (!($projectid))
    {
        $jsongrab = Get-Content -Path $filename | ConvertFrom-Json
        if (!($jsongrab.project_id))
        {
            Get-AGMErrorMessage -messagetoprint "The file named $filename does not contain a valid project ID."
            return
        } else {
            $projectid = $jsongrab.project_id
        }
    }   

    #if user doesn't specify name and zone, then learn them
    $credentialgrab = Get-AGMCredential -credentialid $credentialid
    if (!($credentialgrab.id))
    {
        Get-AGMErrorMessage -messagetoprint "The credential ID $credentialid could not be found."
        return
    } else {
        if (!($name))
        {
            $name = $credentialgrab.name
        }
        if (!($zone))
        {
            $zone = $credentialgrab.region
        }
        if(!($clusterid))
        {
            $clusterid = $credentialgrab.sources.clusterid -join ","
        }
    }

    # convert credential ID into some nice JSON
    $sources = ""
    foreach ($cluster in $clusterid.Split(","))
    {
        $sources = $sources +',{"clusterid":"' +$cluster +'"}'
    }
    # this removes the leading comma
    $sources = $sources.substring(1)

    # we constuct our JSON first to run test
    $json = '{"name":"' +$name +'","cloudtype":"GCP","region":"' +$zone +'","endpoint":"","credential":"'
    $json = $json + $jsonkey
    $json = $json +'","orglist":[],"projectid":"' +$projectid +'",'
    $json = $json +'"sources":[' +$sources +']}'

    # if the test fails we error out
    $testcredential = Post-AGMAPIData  -endpoint /cloudcredential/testconnection -body $json
    if ($testcredential.errors)
    {
        $testcredential
        return
    }
    
    $json = '{"id":"' +$credentialid +'","name":"' +$name +'","cloudtype":"GCP","region":"' +$zone +'","endpoint":"","credential":"'
    $json = $json + $jsonkey
    $json = $json +'","orglist":[],'
    $json = $json +'"sources":[' +$sources +']}'

    Put-AGMAPIData  -endpoint /cloudcredential/$credentialid -body $json
}


function Set-AGMImage([string]$imagename,[string]$backupname,[string]$imageid,[string]$label,[string]$expiration)
{
    <#
    .SYNOPSIS
    Changes a nominated image

    .EXAMPLE
    Set-AGMImage -imagename Image_2133445 -label "testimage"
    Labels Image_2133445 with the label "testimage"

    .EXAMPLE
    Set-AGMImage -imagename Image_2133445 -expiration "2021-09-01"
    Sets the expiration date for Image_2133445 to 2021-09-01

    .DESCRIPTION
    A function to change images.

    #>

    if ((!($label)) -and (!($expiration)))
    {
        Get-AGMErrorMessage -messagetoprint "Please specify either a new label with -label, or a new expiration date with -expiration"
        return
    }

    if (($label) -and ($expiration))
    {
        Get-AGMErrorMessage -messagetoprint "Please specify either a new label with -label, or a new expiration date with -expiration.   Please don't specify both."
        return
    }

    if ($backupname) { $imagename = $backupname }
    if ((!($imagename)) -and (!($imageid)))
    {
        $imagename = Read-Host "ImageName"
    }
    if ($imageid)
    {
        $id = $imageid
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

    if ($label)  
    { 
        $body = @{label=$label} 
        $json = $body | ConvertTo-Json
    }
    if ($expiration)  
    {
        $unixexpiration = Convert-ToUnixDate $expiration
        $json = '{"@type":"backupRest","expiration":' +$unixexpiration + '}'
    }
    Put-AGMAPIData  -endpoint /backup/$id -body $json
}



Function Set-AGMHostPort ([string]$clusterid,[string]$applianceid,[string]$hostid,[string]$iscsiname) 
{
    <#
    .SYNOPSIS
    Adds new Host ports

    .EXAMPLE
    New-AGMHost -applianceid 143112195179 -hostid "12345" iscsiname "iqn1"

    Adds iSCSI port name iqn1 to host ID 105008 on appliance ID 143112195179

    To learn applianceid, use this command:  Get-AGMAppliance and use the clusterid as applianceid.  If you have multiple applianceIDs, comma separate them
    To learn hostid, use this command:  Get-AGMHost

    .DESCRIPTION
    A function to add Host ports

    #>
    
    if ($applianceid) { [string]$clusterid = $applianceid}

    if (!($clusterid))
    {
        $clusterid = Read-Host "Appliance ID"
    }
    if (!($hostid))
    {
        [string]$hostid = Read-Host "Host ID"
    }   
    if (!($iscsiname))
    {
        [string]$iscsiname = Read-Host "iSCSI Name"
    }  
    # cluster needs to be like:  sources":[{"clusterid":"144488110379"},{"clusterid":"143112195179"}]
    $sources = @()
    foreach ($cluster in $clusterid.Split(","))
    {
        $sources += [ordered]@{ clusterid = $cluster }
    } 
    $iscsiobject = @( $iscsiname )
    $body = [ordered]@{}
    $body += @{ sources = $sources;
        iscsi_name = $iscsiobject 
    }
    $json = $body | ConvertTo-Json

    Post-AGMAPIData  -endpoint /host/$hostid/port -body $json 
}





Function Set-AGMSLA ([string]$id,[string]$slaid,[string]$appid,[string]$logicalgroupid,[string]$dedupasync,[string]$expiration,[string]$logexpiration,[string]$scheduler) 
{
    <#
    .SYNOPSIS
    Enables or disables an SLA 
    Note that if both an SLA ID and an App ID are supplied, the App ID will be ignored.

    .EXAMPLE
    Set-AGMSLA -slaid 1234 -dedupasync disable 
    
    Disables dedupasync for SLA ID 1234.  

    .EXAMPLE
    Set-AGMSLA -slaid 1234 -expiration disable 
    
    Disables expiration for SLA ID 1234.  

    .EXAMPLE
    Set-AGMSLA -logicalgroupid 1235 -expiration disable 
    
    Disables expiration for Logical Group ID 1235 

    .EXAMPLE
    Set-AGMSLA -appid 5678 -expiration disable 
    
    Disables expiration for App ID 5678.   

    .EXAMPLE
    Set-AGMSLA -appid 5678 -logexpiration disable 
    
    Disables log expiration for App ID 5678.   

    .EXAMPLE
    Set-AGMSLA -slaid 1234 -scheduler enable 
    
    Enables the scheduler for SLA ID 1234.   

    .EXAMPLE
    Set-AGMSLA -slaid 1234 -scheduler disable 
    
    Disables the scheduler for SLA ID 1234.   


    .DESCRIPTION
    A function to modify an SLA

    #>

    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Get-AGMErrorMessage -messagetoprint "Not logged in or session expired. Please login using Connect-AGM"
        return
    }

    if ($id)
    {
        $slaid = $id
    }

    if (($appid) -and (!($slaid)))
    {
        $slaid = (Get-AGMSLA -filtervalue appid=$appid).id
        if (!($slaid))
        {
            Get-AGMErrorMessage -messagetoprint "Could not find an SLA ID for App ID $appid   Please use Get-AGMSLA to find the correct SLA ID or Get-AGMApplication to find the correct App ID"
            return
        }
    }

    if ($logicalgroupid)
    {
        $logicalgroupgrab = (Get-AGMLogicalGroup $logicalgroupid).sla
        if (!($logicalgroupgrab))
        {
            Get-AGMErrorMessage -messagetoprint "Could not find any SLA ID for Logical Group ID $logicalgroupid   Please use Get-AGMLogicalGroup to find the correct managed Group ID"
            return
        }
        $slpid = $logicalgroupgrab.slp.id
        $sltid = $logicalgroupgrab.slt.id
    }

    if ( (!($slaid)) -and (!($logicalgroupid)) )
    {
        Get-AGMErrorMessage -messagetoprint "No SLA ID or App ID or Logical Group ID was supplied.  Please either supply an appid like:  -appid 1234     or an SLA ID like  -slaid 5678   or logical groupID like  -logicalgroupid"
        return
    }

    $body = New-Object -TypeName psobject

    if ($dedupasync.ToLower() -eq "enable"){
        $body | Add-Member -MemberType NoteProperty -Name dedupasyncoff -Value "false"
    }
    if ($dedupasync.ToLower() -eq "disable"){
        $body | Add-Member -MemberType NoteProperty -Name dedupasyncoff -Value "true"
    }

    if ($expiration.ToLower() -eq "enable"){
        $body | Add-Member -MemberType NoteProperty -Name expirationoff -Value "false"
    }
    if ($expiration.ToLower() -eq "disable"){
        $body | Add-Member -MemberType NoteProperty -Name expirationoff -Value "true"
    }

    if ($logexpiration.ToLower() -eq "enable"){
        $body | Add-Member -MemberType NoteProperty -Name logexpirationoff -Value "false"
    }
    if ($logexpiration.ToLower() -eq "disable"){
        $body | Add-Member -MemberType NoteProperty -Name logexpirationoff -Value "true"
    }

    if ($scheduler.ToLower() -eq "enable"){
        $body | Add-Member -MemberType NoteProperty -Name scheduleoff -Value "false"
    }
    if ($scheduler.ToLower() -eq "disable"){
        $body | Add-Member -MemberType NoteProperty -Name scheduleoff -Value "true"
    }
    if ($logicalgroupid)
    {
        $slp = @{id=$slpid}
        $slt = @{id=$sltid}
        $body | Add-Member -MemberType NoteProperty -Name slp -Value $slp
        $body | Add-Member -MemberType NoteProperty -Name slt -Value $slt
    }

    $jsonbody = $body | ConvertTo-Json

    if (!($logicalgroupid))
    {
        Put-AGMAPIData  -endpoint /sla/$slaid -body $jsonbody
    } else {
        Put-AGMAPIData  -endpoint /logicalgroup/$logicalgroupid/sla -body $jsonbody
    }
}

Function Set-AGMUser ([string]$userid,[string]$timezone,[string]$rolelist,[string]$orglist) 
{
    <#
    .SYNOPSIS
    Changes a User

    .EXAMPLE
    Set-AGMUser -userid 123 -rolelist "2,3" -orglist "4,5"

    Sets a user to use the specified roles and orgs.
    IMPORTANT - The rolelist and orglist will REPLACE the existing roles and orgs, not ADD to them. USE WITH CARE

    .DESCRIPTION
    A function to change a User

    #>

   
    if (!($userid))
    {
        Get-AGMErrorMessage -messagetoprint "Specify a user id (that can be learned with Get-AGMUSer) with -userid"
        return
    }

    if ($rolelist)
    {
        $rolebody = @()
        foreach ($role in $rolelist.Split(","))
        {   
            $rolebody += New-Object -TypeName psobject -Property @{id="$role"}
        }
    }
    if ($orglist)
    {
        $orgbody = @()
        foreach ($org in $orglist.Split(","))
        {   
            $orgbody += New-Object -TypeName psobject -Property @{id="$org"}
        }
    }
   $body = [ordered]@{
        name = $name;
        dataaccesslevel = "0";
        timezone = $timezone;
        rolelist = $rolebody
        orglist = $orgbody
    }
    if ($AGMToken) { Set-AGMPromoteUser }
    $jsonbody = $body | ConvertTo-Json

    Put-AGMAPIData  -endpoint /user/$userid -body $jsonbody
}