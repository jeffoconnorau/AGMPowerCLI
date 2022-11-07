
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

Function Restore-AGMApplication ([string]$imageid,[string]$imagename,[string]$jsonbody,[switch]$recover,[switch]$donotdisableschedule,[string]$objectlist,[string]$username,[string]$password,[string]$datastore,[switch]$poweronvm) 
{
    <#
    .SYNOPSIS
    Restores an application using a nominated image ID

    .EXAMPLE
    Restore-AGMApplication -imageid 1234 
    Uses image ID 1234 to restore the relevant application (the application that created that image)

    .EXAMPLE
    Restore-AGMApplication -imageid 1234 -objectlist "DB1,DB2" 
    Uses image ID 1234 to restore DB1 and DB2 in Instance or a Consistency Group

    .DESCRIPTION
    A function to restore Applications

    #>

    # learn about the image
    if ($imagename)
    {
        $imagecheck = Get-AGMImage -filtervalue backupname=$imagename
        if (!($imagecheck))
        {
            Get-AGMErrorMessage -messagetoprint "Failed to find $imagename using:  Get-AGMImage -filtervalue backupname=$imagename"
            return
        }
        else 
        {
            $imageid = $imagecheck.id
        }
    }

    # this image
    if (!($imageid))
    {
        [string]$imageid = Read-Host "Image ID to use for the restore"
    }

    # a user could specify the jsonbody or we could build one
    if (!($jsonbody))
    {
        # the objectlist is a list of databases that we want to restore
        if ($objectlist)
        {
            $restoreobjectmappings = @()
            foreach ($object in $objectlist.Split(","))
            {   
                $restoreobjectmappings += New-Object -TypeName psobject -Property @{restoreobject="$object"}
            }
        }

        # these two should appear every time
        if (!($recover)) { $recover = $true }
        if (!($notdisableschedule)) { $notdisableschedule = $true}

        # now we build a body 
        $body = [ordered]@{}
        if ($restoreobjectmappings) { $body += [ordered]@{ restoreobjectmappings = $restoreobjectmappings } }
        $body += [ordered]@{ recover = $recover }
        $body += [ordered]@{ notdisableschedule = $notdisableschedule }
        if ($username) { $body += [ordered]@{ username = $username } }
        if ($password) { $body += [ordered]@{ password = $password } }
        if ($datastore) { $body += [ordered]@{ datastore = $datastore } }
        if ($poweronvm) { $body += [ordered]@{ poweronvm = $poweronvm } }
    }
    $jsonbody = $body | ConvertTo-Json

    $endpoint = "/backup/$imageid/restore"
    Post-AGMAPIData  -endpoint $endpoint -jsonbody $jsonbody
}
