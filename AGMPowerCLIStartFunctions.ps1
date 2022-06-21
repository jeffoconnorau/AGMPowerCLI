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

Function Start-AGMMigrate ([string]$imageid,[switch][alias("f")]$finalize) 
{
    <#
    .SYNOPSIS
    Starts a migration job 

    .EXAMPLE
    Start-AGMMigrate 
    You will be prompted for ImageID

    .EXAMPLE
    Start-AGMMigrate -imageid 56072427 

    Runs a migration job for Image ID 56072427

        .EXAMPLE
    Start-AGMMigrate -imageid 56072427 -finalize

    Runs a Finalize job for Image ID 56072427

    .DESCRIPTION
    A function to run migration jobs 

    #>

    if (!($imageid))
    {
        $imageid = Read-host "Image ID"
    }
    if (!($imageid))
    {
        Get-AGMErrorMessage -messagetoprint "No Image ID was supplied"
        return
    }

    if ($finalize)
    {
        $body = [ordered]@{}
        $body += @{ action = "finalize" }
        $json = $body | ConvertTo-Json
        Post-AGMAPIData  -endpoint /backup/$imageid/migrate -body $json
    }
    else {
        Post-AGMAPIData  -endpoint /backup/$imageid/migrate 
    }

}


Function Start-AGMReplicateLog ([string]$appid,[string]$id) 
{
    <#
    .SYNOPSIS
    Starts a replicate log job 

    .EXAMPLE
    Start-AGMReplicateLog 
    You will be prompted for AppID

    .EXAMPLE
    Start-AGMReplicateLog -appid 56072427 

    Runs a log replication job for App ID 56072427

    .DESCRIPTION
    A function to run log replication jobs 

    #>

    if ($id) { $appid = $id }

    if (!($appid))
    {
        $imageid = Read-host "App ID"
    }
    
    Post-AGMAPIData  -endpoint /application/$appid/replicatelog 
}