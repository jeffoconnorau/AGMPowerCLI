
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

Function Restore-AGMApplication ([string]$imageid,[string]$jsonbody) 
{
    <#
    .SYNOPSIS
    Restores an application using a nominated image ID

    .EXAMPLE
    Restore-AGMApplication -imageid 1234 

    Uses image ID 1234 to restore the relevant application (the application that created that image)


    .DESCRIPTION
    A function to restore Applications

    #>

    if (!($imageid))
    {
        [string]$imageid = Read-Host "Image ID to use for the restore"
    }

    if (!($jsonbody))
    {
        $jsonbody = '{"@type":"restoreRest","poweronvm":true,"recover":true,"migratevm":false,"notdisableschedule":true}'
    }

    $endpoint = "/backup/$imageid/restore"
    Post-AGMAPIData  -endpoint $endpoint -jsonbody $jsonbody
}
