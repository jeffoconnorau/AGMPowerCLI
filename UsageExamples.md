
# Usage Examples
This document contains usage examples that include both AGMPowerCLI and AGMPowerLIB commands.

**[Appliances](#appliances)**<br>
**[Appliance add and remove](#appliance-add-and-remove)**<br>
**[Appliance discovery schedule](#appliance-discovery-schedule)**<br>
**[Appliance info and report commands](#appliance-info-and-report-commands)**<br>
**[Appliance timezone](#appliance-timezone)**<br>

**[Applications](#applications)**<br>
**[Application bulk unprotection](#application-bulk-unprotection)**<br>

**[Compute Engine Instances](#compute-engine-instances)**<br>
**[Compute Engine Cloud Credentials](#compute-engine-cloud-credentials)**<br>
**[Compute Engine Instance Discovery](#compute-engine-instance-discovery)**<br>
**[Compute Engine Instance Management](#compute-engine-instance-management)**<br>

**[Consistency Groups](#consistency-groups)**<br>
**[Consistency Group Management](#consistency-group-management)**<br>

**[Images](#images)**<br>
**[Image expiration](#image-expiration)**<br>
**[Image creation with an On-Demand Job](#image-creation-with-an-ondemand-job)**<br>
**[Image creation in bulk using policy ID](#image-creation-in-bulk-using-policy-id)**<br>
**[Image restore](#image-restore)**<br>

**[Organizations](#organizations)**<br>
**[Organization Creation](#organization-creation)**<br>

**[SQL Server](#sql-server)**</br>
**[SQL Server Mount](#sql-server-mount)**</br>

# Appliances


## Appliance add and remove

> **Note**:   You cannot perform appliance add and remove in Google Cloud Backup and DR.  This is for Actifio AGM only.

You may want to add or remove an Appliance from AGM.   You can list all the Appliances with this command:
```
PS > Get-AGMAppliance | select id,name,ipaddress

id    name       ipaddress
--    ----       ---------
7286  backupsky1 10.194.0.20
45408 backupsky2 10.194.0.38
```
We can then remove the Appliance by specifying the ID of the appliance with this command:
```
PS > Remove-AGMAppliance 45408
PS > Get-AGMAppliance | select id,name,ipaddress

id   name       ipaddress
--   ----       ---------
7286 backupsky1 10.194.0.20
```
We can add the Appliance back with this command.  Note we can do a dryrun to make sure the add will work, but you don't need to.  The main thing with a dry run is we need to see an approval token because that is key to actually adding the appliance.  
```
PS > New-AGMAppliance -ipaddress 10.194.0.38 -username admin -password password -dryrun | select-object approvaltoken,cluster,report

approvaltoken          cluster                                                      report
-------------          -------                                                      ------
05535A005F051E00480608 @{clusterid=141925880424; ipaddress=10.194.0.38; masterid=0} {"errcode":0,"summary":"Objects to be imported:\n\t.....
```
This is the same command but without the dryrun.   After the command finishes, we list the Appliances to see our new one has been added:
```
PS > New-AGMAppliance -ipaddress 10.194.0.38 -username admin -password password  | select-object cluster,report

cluster                                                                                                               report
-------                                                                                                               ------
@{id=45582; href=https://10.194.0.3/actifio/cluster/45582; clusterid=141925880424; ipaddress=10.194.0.38; masterid=0} {"errcode":0,"summary"...

PS > Get-AGMAppliance | select id,name,ipaddress

id    name       ipaddress
--    ----       ---------
45582 backdrsky2 10.194.0.38
7286  backupsky1 10.194.0.20

PS >
```
## Appliance discovery schedule

To set the start time when auto discovery runs (instead of the default 2am), first learn the appliance ID:
```
PS /> Get-AGMAppliance | select id,name

id     name
--     ----
591780 backup-server-67154
406219 backup-server-29736
```
Display if an existing schedule is set (if no schedule is shown, then the default of 2am is in use):
```
PS /> $applianceid = 406219
PS /> Get-AGMAPIApplianceInfo -applianceid $applianceid -command getschedule -arguments "name=autodiscovery"
time  frequency
----  ---------
10:00 daily
```
To set the schedule use the following syntax.  In this example we set it to 9am rather than 10am.
```
PS /> $applianceid = 406219
PS /> Set-AGMAPIApplianceTask -applianceid $applianceid -command setschedule -arguments "name=autodiscovery&frequency=daily&time=09:00"

status
------
     0

PS /> Get-AGMAPIApplianceInfo -applianceid $applianceid -command getschedule -arguments "name=autodiscovery"

time  frequency
----  ---------
09:00 daily
```

## Appliance info and report commands

> **Note**:   If you want to manage appliance parameters such as slots, use the **Get-AGMLibApplianceParameter** and **Set-AGMLibApplianceParameter** commands documented [here](https://github.com/Actifio/AGMPowerLib#user-story-appliance-parameter-management-and-slot-limits).

You can run info and report commands on an appliance using AGMPowerCLI.  To do this we need to tell the Management Console which appliance to run the command on. So first learn your appliance ID with **Get-AGMAppliance**.  In this example the appliance we want to work with is ID 70194.
```
PS > Get-AGMAppliance | select id,name

id     name
--     ----
406219 backup-server-29736
70194  backup-server-32897
```
### Running info commands
We can use **Get-AGMAPIApplianceInfo** to send info (also known as udsinfo) commands.   In this example we send the **udsinfo lshost** command to the appliance with ID 70194.
```
PS > Get-AGMAPIApplianceInfo -applianceid 70194 -command lshost | select id,hostname

id     hostname
--     --------
16432  tiny
57610  winsrv2019-1
57612  winsrv2019-2
```
To get info about a specific host ID, you could use this command:
```
Get-AGMAPIApplianceInfo -applianceid 70194 -command lshost -arguments "argument=16432"
```
You can also filter by using a command like this:
```
Get-AGMAPIApplianceInfo -applianceid 70194 -command lshost -arguments "filtervalue=hostname=tiny"
```

### Running report commands

We can use **Get-AGMAPIApplianceReport** to send report commands.  If you want to know which commands you can send, start with *reportlist*.
```
PS > Get-AGMAPIApplianceReport -applianceid 70194 -command reportlist

ReportName             ReportFunction                                                                           RequiredRoleRights
----------             --------------                                                                           ------------------
reportadvancedsettings Show all Advanced policy options that have been set                                      AdministratorRole
```
In this example we run the *reportapps* command:
```
PS > Get-AGMAPIApplianceReport -applianceid 70194 -command reportapps | select hostname,appname,"MDLStat(GB)"

HostName      AppName            MDLStat(GB)
--------      -------            -----------
tiny          tiny               20.000
windows       windows            50.000
win-target    win-target         50.000
postgres1melb postgresql_5432    0.046
sap-prod      act                70.000
windows       WINDOWS\SQLEXPRESS 0.437
centos1       centos1            4.051
centos2       centos2            3.855
centos3       centos3            4.098
ubuntu1       ubuntu1            29.199
ubuntu2       ubuntu2            31.855
ubuntu3       ubuntu3            26.191
winsrv2019-1  WinSrv2019-1       37.332
winsrv2019-2  WinSrv2019-2       36.062
```
We then send an argument of **-a tiny** to restrict the output to applications with a name of **tiny**
```
PS > Get-AGMAPIApplianceReport -applianceid 70194 -command reportapps -arguments "-a tiny" | select hostname,appname,"MDLStat(GB)"

HostName AppName MDLStat(GB)
-------- ------- -----------
tiny     tiny    20.000
```
#### Running a commnd with multiple arguments
If you need to send multiple arguments separate them with an **&**, for example, this command send the **reportimages** command to appliance ID 406219 with the **-a 0** and **-s** parameters and exports it to CSV.
```
Get-AGMAPIApplianceReport -applianceid 406219 -command reportimages -arguments "-a 0&-s" |  Export-Csv disks.csv
```
## Appliance timezone
To display Appliance timezone, learn the appliance ID and then query the relevant appliance:
```
PS /> Get-AGMAppliance | select id,name

id     name
--     ----
591780 backup-server-67154
406219 backup-server-29736

PS /> Get-AGMAppliance 406219 | select timezone

timezone
--------
UTC
```
To set Appliance timezone, use the following syntax, making sure to specify a valid timezone:

```
PS > $timezone = "Australia/Sydney"
PS > $applianceid = 406219
PS > Set-AGMAPIApplianceTask -applianceid $applianceid -command "chcluster" -arguments "timezone=$timezone&argument=11"

status
------
     0

```
Now wait 3 minutes (this takes a little time to update).   If you see the old timezone, please wait a little longer.
```
PS > Get-AGMAppliance 406219 | select timezone

timezone
--------
Australia/Sydney
```


# Applications

## Application bulk unprotection

In this scenario, a large number of VMs that were no longer required were removed from the vCenter. However, as those VMs were still being managed by Actifio at the time of removal from the VCenter, the following error message is being received constantly
 
 ```
Error 933 - Failed to find VM with matching BIOS UUID
```

### 1)  Create a list of affected VMs using AGM PowerShell

First we need to create a list of affected VMs.  The simplest way to do this is to run these commands:

There are two parameters in the filtervalue.
The first is the errorcode of 933
The second is the startdate.  You need to update this.

This is the command we thus run (connect-agm logs us into the appliance).
We grab just the Appname  (which is the VMname) and AppID of each affected VM and reduce to a unique list in a CSV file

```
Get-AGMJobHistory -filtervalue "errorcode=933&startdate>2020-09-01"  | select appname,appid | sort-object appname | Get-Unique -asstring | Export-Csv -Path .\missingvms.csv -NoTypeInformation
```
### 2). Edit your list if needed

Now open your CSV file called missingvms.csv and go to the VMware administrator.
Validate each VM is truly gone.
Edit the CSV and remove any VMs you don't want to unprotect.   
 
### 3) Unprotection script using AGM Powershell

Because we have a CSV file of affected VMs we can run this simple PowerShell script. 

Import the list and validate the import worked by displaying the imported variable.  In this example we have only four apps.
```
PS > $appstounmanage = Import-Csv -Path .\missingvms.csv
PS > $appstounmanage

appname      appid
-------      --
duoldapproxy 655601
SYDWINDC1    655615
SYDWINDC2    6227957
SYDWINFS2    5370126
```
Then paste this script to validate each app has an SLA ID
```
foreach ($app in $appstounmanage)
{ $slaid = get-agmSLA -filtervalue appid=$($app.appid)
write-host "Appid $($app.appid) has SLA ID $($slaid.id)" }
```
Output will be similar to this:
```
Appid 655601 has SLA ID 6749490
Appid 655615 has SLA ID 6749492
Appid 6227957 has SLA ID 6749494
Appid 5370126 has SLA ID 6749496
```
If you want to build a backout plan, run this script now:
```
foreach ($app in $appstounmanage)
{ $slaid = Get-AGMSLA -filtervalue appid=$($app.appid)
$slpid =  $slaid.slp.id
$sltid =  $slaid.slt.id
write-host "New-AGMSLA -appid $($app.appid) -slpid $slpid -sltid $sltid" }
```
It will produce a list of commands to re-protect all the apps.
You would simply paste this list into your Powershell session:
```
New-AGMSLA -appid 655601 -slpid 655697 -sltid 4171
New-AGMSLA -appid 655615 -slpid 655697 -sltid 4181
New-AGMSLA -appid 6227957 -slpid 655697 -sltid 4171
New-AGMSLA -appid 5370126 -slpid 655697 -sltid 4181
```
Now we are ready for the final step.  Run this script to unprotect the VMs:
```
foreach ($app in $appstounmanage)
{ Remove-AGMSLA -appid $($app.appid) }
```
Output will be blank but the VMs will all be unprotected

### 4) Bulk deletion of the Applications

If any of the Applications have images, it is not recommended you delete them, as this creates orphans apps and images.
If you are determined to also delete them, run this script to delete the VMs from AGM and Appliances.
```
foreach ($app in $appstounmanage)
{ Remove-AGMApplication -appid $($app.appid) }
```
Output will be blank but the VMs will all be deleted.


# Compute Engine Instances

## Compute Engine Cloud Credentials

### Listing Cloud Credentials

```
PS /Downloads> Get-AGMCredential

@type          : cloudCredentialRest
id             : 218150
href           : https://10.152.0.5/actifio/cloudcredential
sources        : {@{srcid=20740; clusterid=145759989824; appliance=; name=london; cloudtype=GCP; region=europe-west2-b; projectid=avwlab2; serviceaccount=avwlabowner@avwlab2.iam.gserviceaccount.com}}
name           : london
cloudtype      : GCP
region         : europe-west2-b
projectid      : avwlab2
serviceaccount : avwlabowner@avwlab2.iam.gserviceaccount.com
```

### Creating new cloud credential:


```
PS /Downloads> New-AGMCredential -name test -filename ./glabco-4b72ba3d6a69.json -zone australia-southeast1-c -clusterid "144292692833,145759989824"

@type          : cloudCredentialRest
id             : 219764
href           : https://10.152.0.5/actifio/cloudcredential
sources        : {@{srcid=214315; clusterid=144292692833; appliance=; name=test; cloudtype=GCP; region=australia-southeast1-c; projectid=glabco; serviceaccount=avw-gcsops@glabco.iam.gserviceaccount.com}, @{srcid=21546;
                 clusterid=145759989824; appliance=; name=test; cloudtype=GCP; region=australia-southeast1-c; projectid=glabco; serviceaccount=avw-gcsops@glabco.iam.gserviceaccount.com}}
name           : test
cloudtype      : GCP
region         : australia-southeast1-c
projectid      : glabco
serviceaccount : avw-gcsops@glabco.iam.gserviceaccount.com
```

Situation where key cannot manage project
```
PS /Downloads> New-AGMCredential -name test -filename ./glabco-4b72ba3d6a69.json -zone australia-southeast1-c -clusterid "144292692833,145759989824" -projectid glabco1

@type                    errors
-----                    ------
testCredentialResultRest {@{errorcode=4000; errormsg=No privileges for project or incorrect project id provided in credential json.; clusters=System.Object[]}}
```
Duplicate name
```
PS /Downloads> New-AGMCredential -name test -filename ./glabco-4b72ba3d6a69.json -zone australia-southeast1-c -clusterid "144292692833,145759989824"

err_code err_message
-------- -----------
   10023 Create cloud credential failed on appliance avwlab2sky error code 10006 message Unique cloud credential name required: test,Create cloud credential failed on appliance londonsky.c.avwlab2.internal error code 10006 message U…
```

### Updating an existing cloud credential

The most common reason for doing this is to update the JSON key.  Use syntax like this where we specify the credential ID and the filename of the JSON file.
```
Set-AGMCredential -credentialid 1234 -filename keyfile.json
```
You can also use this command to update the default zone or the credential name as well.   However zone, name and clusterid are not mandatory and only need to be supplied if you are changing them.   The clusterid parameter would determine which appliances get updated, by default all relevant appliances are updated.   You can learn the credential ID with **Get-AGMCredential** and the clusterid will be in the sources field of the same output.   

### Deleting a Cloud Credential
```
PS /Downloads> Remove-AGMCredential -credentialid 219764 -applianceid "145759989824,144292692833"
```
Update existing credential with new key and change its name
```
PS /Downloads> Set-AGMCredential -id 219764  -name test1 -filename ./glabco-4b72ba3d6a69.json

@type          : cloudCredentialRest
id             : 219764
href           : https://10.152.0.5/actifio/cloudcredential
sources        : {@{srcid=214315; clusterid=144292692833; appliance=; name=test1; cloudtype=GCP; region=australia-southeast1-c; projectid=glabco; serviceaccount=avw-gcsops@glabco.iam.gserviceaccount.com}, @{srcid=21546;
                 clusterid=145759989824; appliance=; name=test1; cloudtype=GCP; region=australia-southeast1-c; projectid=glabco; serviceaccount=avw-gcsops@glabco.iam.gserviceaccount.com}}
name           : test1
cloudtype      : GCP
region         : australia-southeast1-c
projectid      : glabco
serviceaccount : avw-gcsops@glabco.iam.gserviceaccount.com
```

## Compute Engine Instance Discovery

### Listing new Compute Engine Instances. Use this syntax:

By default this command only shows up to 50 new VMs:
```
Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid "avwlab2" -zone "australia-southeast1-c"
```
You can set filters to display different discovery status. Can be New, Ignored, Managed or Unmanaged  
For example to list discovered but unmanaged VMs:
```
Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid "avwlab2" -zone "australia-southeast1-c" -filter Unmanaged
```
Learn the credential ID with:
```
Get-AGMCredential
```
Learn the cluster ID with:
```
Get-AGMAppliance
```
To learn instance IDs use these two commands:
```
$discovery = Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid "avwlab2" -zone "australia-southeast1-c" -filter NEW
$discovery.items.vm | select vmname,instanceid
```
For example:
```
PS > $discovery.items.vm | select vmname,instanceid

vmname      instanceid
------      ----------
consoletest 4240202854121875692
agm         6655459695622225630
```
The total number of VMs that were found and the total number fetched will be different.  In this example, 57 VMs can be found, but only 50 were fetched as the limit defaults to 50:
```
PS > Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid avwlab2

count items                             totalcount
----- -----                             ----------
   50 {@{vm=}, @{vm=}, @{vm=}, @{vm=}…}         57
```
By setting the limit to 60 we now fetch all 57 VMs:
```
PS > Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid avwlab2 -limit 60

count items                             totalcount
----- -----                             ----------
   57 {@{vm=}, @{vm=}, @{vm=}, @{vm=}…}         57

PS >
```

Or we could fetch the first 50 in one command and then in a second command, set an offset of 1, which will fetch all VMs from 51 onwards (offset it added to limit to denote the starting point).  In this example we fetch the remaining 7 VMs (since the limit is 50):
```
PS > Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid avwlab2 -limit 50 -offset 1

count items                             totalcount
----- -----                             ----------
    7 {@{vm=}, @{vm=}, @{vm=}, @{vm=}…}         57

PS >
```

### Add new Compute Engine Instance

Learn the instanceid and then use this command (comma separate the instance IDs):
```
New-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid "avwlab2" -zone "australia-southeast1-c" -instanceid "4240202854121875692,6655459695622225630"
```

## Compute Engine Instance Management

### How to learn if a Compute Engine Instance is being backed up or not.

Use this command:
```
Get-AGMApplication -filtervalue appname=bastion
```
The term we look for is “Managed” = True 
```
PS > Get-AGMApplication -filtervalue apptype=GCPInstance | select appname,apptype,managed,id, @{N='sltid'; E={$_.sla.slt.id}}, @{N='slpid'; E={$_.sla.slp.id}} | ft

appname     apptype     managed id     sltid slpid
-------     -------     ------- --     ----- -----
consoletest GCPInstance   False 224079
bastion     GCPInstance    True 209913 6392  35557
```

### How to apply backup to unmanaged Compute Engine Instance

Use a command like this.   
```
New-AGMSLA -appid 209913 -sltid 6392 -slpid 35557 -scheduler enabled
```

We need to know the App ID (ID from the Get-AGMApplication), SLT and SLP ID.
We can learn the SLT and SLP from existing app, or with:
```
Get-AGMSLT
Get-AGMSLP
```

### How to learn the IP address of a Compute Engine Instance

If we know the name of the GCP VM, then use this command: 
```
Get-AGMApplication -filtervalue appname=bastion
```
Here is an example:
```
PS > $appdata = Get-AGMApplication -filtervalue appname=bastion
PS > $appdata.host.ipaddress
10.152.0.3
PS >
```
# Consistency Groups

## Consistency Group Management

There are five commands that you can use to manage consistency groups

* Get-AGMConsistencyGroup
* New-AGMConsistencyGroup
* Remove-AGMConsistencyGroup
* Set-AGMConsistencyGroup
* Set-AGMConsistencyGroupMember

To create a consistency group we need to learn the ID of Appliance we want to create it on and the ID of the Host that it will use applications from:

* Get-AGMAppliance
* Get-AGMHost

We can then use a command like this to create it. Note this group has no members in it:
```
New-AGMConsistencyGroup -groupname "ProdGroup" -description "This is the prod group" -applianceid 70194 -hostid  70631
```
Learn the consistencygroup ID with:

* Get-AGMConsistencyGroup

You can edit the name or description with the following syntax (changing group ID to suit):
```
Set-AGMConsistencyGroup -groupname "bettername" -description "Even better description" -applianceid 70194 -groupid 353953
```
Now we need to add applications to the group.   We need to know the application IDs
Learn member APP IDs with with a filter like this:
```
$targethost = 70631
Get-AGMApplication -filtervalue hostid=$targethost | select id,appname
```
We can then add selected applications to the group with syntax like this.   Comma separate multiple IDs:
```
Set-AGMConsistencyGroupMember -groupid 353953 -applicationid "210647,210645" -add
```
We can remove them from the group with syntax like this:
```
Set-AGMConsistencyGroupMember -groupid 353953 -applicationid "210647,210645" -remove
```
We can delete  the group with syntax like this: 
```
Remove-AGMConsistencyGroup 353953
```

# Images

## Image expiration

You may have a requirement to expire large numbers of images at one time.   One way to approach this is to use the Remove-AGMImage command in a loop. However this may fail as shown in the example below.  The issue is that the first expiration job is still running while you attempt to execute the following jobs, which causes a collission:
```
PS > $images = Get-AGMImage -filtervalue appid=35590 | select backupname
PS > $images

backupname
----------
Image_0272391
Image_0270340
Image_0268295
Image_0267271
Image_0266247
Image_0265223
Image_0262151
Image_0259079

PS > foreach ($image in $images)
>> {
>> remove-agmimage -imagename $image.backupname
>> }

err_code err_message
-------- -----------
   10023 avwlab2sky:,	errormessage: expiration in progress, try again later,	errorcode: 10017
   10023 avwlab2sky:,	errormessage: expiration in progress, try again later,	errorcode: 10017
   10023 avwlab2sky:,	errormessage: expiration in progress, try again later,	errorcode: 10017
   10023 avwlab2sky:,	errormessage: expiration in progress, try again later,	errorcode: 10017
   10023 avwlab2sky:,	errormessage: expiration in progress, try again later,	errorcode: 10017
   10023 avwlab2sky:,	errormessage: expiration in progress, try again later,	errorcode: 10017
   10023 avwlab2sky:,	errormessage: expiration in progress, try again later,	errorcode: 10017

```
There are two solutions for this.   Either insert a sleep in between each Remove-AGMImage command, or preferably use the method below, where we set the image expiration date instead:

First we learn the expiration dates
```
PS > $images = Get-AGMImage -filtervalue appid=35590 | select backupname,expiration
PS > $images

backupname    expiration
----------    ----------
Image_0267271 2021-09-18 19:02:27
Image_0266247 2021-09-17 11:03:09
Image_0265223 2021-09-16 10:07:43
```
We then change them all to a date prior to today and confirm they changed:
```
PS > foreach ($image in $images) { Set-AGMImage -imagename $image.backupname -expiration "2021-09-14" }

xml                            backupRest
---                            ----------
version="1.0" encoding="UTF-8" backupRest
version="1.0" encoding="UTF-8" backupRest
version="1.0" encoding="UTF-8" backupRest

PS > $images = Get-AGMImage -filtervalue appid=35590 | select backupname,expiration
PS > $images

backupname    expiration
----------    ----------
Image_0267271 2021-09-14 00:00:00
Image_0266247 2021-09-14 00:00:00
Image_0265223 2021-09-14 00:00:00

PS >
```
The images will expire over the next hour.

## Image creation with an OnDemand Job

When we want to manually create a new backup image, this is called running an on-demand job.   We can do this with the ```New-AGMLibImage``` command.
You can learn the application ID of the application in question with:  ```Get-AGMApplication```  You may want to use filters. 
This is a good example of a filter:
```
Get-AGMApplication -filtervalue managed=true -sort appname:asc | select id,appname,apptype
```
In this example we know the application ID so we request a new image.   A snapshot job will automatically run.   If a snapshot policy cannot be found, a direct to onvault job will be attempted.
```
$appid = 425466
New-AGMLibImage $appid
```
We may want to start a particular policy so we can use the app ID to learn relevant policies:
```
$appid = 425466
Get-AGMLibPolicies -appid $appid
```
We then use the policy ID we learned.  We also added a label:
```
$policyid = 425080
New-AGMLibImage -appid $appid -policyid $policyid -label "Dev image after upgrade"
```
If the application is a database we can use ```-backuptype log``` or ```-backuptype db``` like this:
```
New-AGMLibImage  -appid 2133445 -backuptype log
```

### Tracking jobs

The command to start an on-demand job does not return a jobname, meaning you need to search for the newly created job.
One solution to do this is to start each job with a unique label. If you use a label then we can find the job easily.  First start the job with a label like this:
```
PS /> New-AGMLibImage -appid 409016 -label "tinyrun1"
Running this command: New-AGMLibImage  -appid 409016 -policyid 425081 -label tinyrun1
```
Now we search for a job with that label:
```
PS /> Get-AGMJobStatus -filtervalue "label=tinyrun1" | select jobname,status,progress,startdate

jobname     status    progress startdate
-------     ------    -------- ---------
Job_0185433 running          7 2022-11-11 09:18:44
```
But the label has to be unique or you can end up in situation like this where we run a second job with the previously used label:
```
PS /Users/avw/Documents> New-AGMLibImage -appid 409016 -label "tinyrun1"
Running this command: New-AGMLibImage  -appid 409016 -policyid 425081 -label tinyrun1
```
First we find the old job (because the new job has not started yet):
```
PS /> Get-AGMJobStatus -filtervalue "label=tinyrun1" | select jobname,status,progress,startdate

jobname     status    progress startdate
-------     ------    -------- ---------
Job_0185433 succeeded          2022-11-11 09:18:44
```
Now we find the old job and the new job:
```
PS /> Get-AGMJobStatus -filtervalue "label=tinyrun1" | select jobname,status,progress,startdate

jobname     status    progress startdate
-------     ------    -------- ---------
Job_0185358 running          7 2022-11-11 09:11:37
Job_0185433 succeeded          2022-11-11 09:18:44
```

## Image creation in bulk using policy ID

One way to create a semi air-gapped solution is to restrict access to the OnVault pool by using limited time windows that are user controlled.
If we create an OnVault or Direct2Onvault policy that never runs, meaning it is set to run everyday except everyday, then the policy will only run when manually requested.

Now since this user story relies on running specific policies for specific groups of apps, we need a way to group them.
There are two ways to achieve this:

* Using unique Templates for each group
* Using LogicalGroups to group your apps.   This is the recommended method.

Once we have done this, then we can use **Start-AGMLibPolicy** to run a job against all apps either for one policy or in one logical group (or both).
So just run the command and follow the prompts to build your command:
```
Start-AGMLibPolicy
```
We then run our command, for instance:
```
PS > Start-AGMLibPolicy -policyid 6393 -backuptype dblog
Starting job for hostname: mysqlsource   appname: mysqlsource   appid: 51919 using: snap policyID: 6393 from SLTName: PDSnaps
Starting job for hostname: mysqltarget   appname: mysqltarget   appid: 36104 using: snap policyID: 6393 from SLTName: PDSnaps
Starting job for hostname: tiny   appname: tiny   appid: 35590 using: snap policyID: 6393 from SLTName: PDSnaps
PS >
```
We can then monitor the jobs like this:
```
PS /tmp/agmpowercli> Get-AGMJob -filtervalue "policyname=OndemandOV" | select status,progress

status  progress
------  --------
running       97
running       98
```
Your logic would work like this:
1. Count the relevant apps.  In this example we have 2.
```
PS /tmp/agmpowercli> $appgrab = Get-AGMApplication -filtervalue "sltname=FSSnaps_RW_OV"
PS /tmp/agmpowercli> $appgrab.count
2
```
2. Count the current images.  We currently have 6 OnVault images.
```
PS /tmp/agmpowercli> $imagegrab = Get-AGMImage -filtervalue "sltname=FSSnaps_RW_OV&jobclass=OnVault"
PS /tmp/agmpowercli> $imagegrab.count
6
```
3. Run a new OnVault job.  We get two jobs started.
```
PS /tmp/agmpowercli> Start-AGMLibPolicy -policyid 25627
Starting job for appid 20577 using cloud policy ID 25627 from SLT FSSnaps_RW_OV
Starting job for appid 6965 using cloud policy ID 25627 from SLT FSSnaps_RW_OV
```
4.  Scan for running jobs until they all finish
```
PS /tmp/agmpowercli> Get-AGMJob -filtervalue "policyname=OndemandOV" | select status,progress

status             progress
------             --------
queued                    0
queued (readiness)        0

PS /tmp/agmpowercli> Get-AGMJob -filtervalue "policyname=OndemandOV" | select status,progress

status  progress
------  --------
running        2
running        2

PS /tmp/agmpowercli> Get-AGMJob -filtervalue "policyname=OndemandOV" | select status,progress

status    progress
------    --------
running         98
succeeded      100

PS /tmp/agmpowercli> Get-AGMJob -filtervalue "policyname=OndemandOV" | select status,progress

status progress
------ --------


PS /tmp/agmpowercli>

```
5. Count the images and ensure they went up by the number of apps.   Note that if expiration run at this time, this will confuse the issue.
You can see here we went from 6 to 8.
```
PS /tmp/agmpowercli> $imagegrab = Get-AGMImage -filtervalue "sltname=FSSnaps_RW_OV&jobclass=OnVault"
PS /tmp/agmpowercli> $imagegrab.count
8
PS /tmp/agmpowercli>
```

## Image restore
For the vast bulk of application types where we want to restore the application type the main thing we need is the image ID that will be used.
First find the application you want to work with:
```
Get-AGMApplication -filtervalue managed=true | select id,appname,apptype
```
This will give you the application ID (in this example it is 425468), which we then use to learn the images:
```
$appid=425468
Get-AGMImage -filtervalue appid=$appid -sort consistencydate:desc | select id,consistencydate,jobclass
```
We then take the image ID and run a restore.   However some application types can restore individual objects which we can specify as an objectlist, so we use this syntax to find the objects:
```
$imageid = 791691
(Get-AGMImage 791691).restorableobjects.name
```
There are a number of parameters we can use:
* $imageid:  The imageid or imagename are mandatory.
* $imagename: The imageid or imagename are mandatory.
* $jsonbody:  This can be used if you know what the desired JSON body is, otherwise use the following parameters:
* $donotrecover:   This is for databases.  Specifies that the Databases is not restored with recovery.
* $disableschedule:  This is a switch that will control whether the schedule will be disabled when a restore is run.  By default it is is false
* $objectlist:  This is a comma separated list of objects to be restored, such as DBs in an instance or Consistency Group
* $username:  This is a username
* $password:  This is the password for the username
* $datastore:  For VMware restores, specifies which datastore will be used for the restored VM
* $poweroffvm:  For VMware restore, specified if the VM should be restored in the powered off state.  By default this is false and the VM is powered on at restore time time.


# Organizations

## Organization Creation

If we want to create an Organization we need to get the IDs of the various resources we want to put into the Organization.   We could run a series of commands like this:
```
Get-AGMHost | Select-Object id,name
Get-AGMSLP | Select-Object id,name
Get-AGMSLP | Select-Object id,name
Get-AGMDiskpool | Select-Object id,name
```
Using the IDs we can then form a command like this one:
```
New-AGMOrg -orgname "prod1" -description "this is prod org" -hostlist "460500,442009" -slplist "441943" -sltlist "108758" -poollist "441941"
```
We can then grab the contents of the Org by learning the ID of the Org:
```
Get-AGMOrg
```
Then grab all the contents of the org and display the resources:
```
$org = Get-AGMOrg -orgid 526553
$org.resourcecollection
```
Output will look like this:
```
PS > $org = Get-AGMOrg -orgid 526553
PS > $org.resourcecollection

sltlist       : {108758}
hostlist      : {442009, 460500}
slplist       : {441943}
poollist      : {441941}
sltlistcount  : 1
hostlistcount : 2
slplistcount  : 1
poollistcount : 1
```
We then realize we added the wrong host ID.   We need to remove 460500 and add 449560.   First we remove 460500 by setting the Org to **0**
```
 Set-AGMOrgHost -orglist "0" -hostid 460500
 ```
 We then add 449560 to Org ID 526553
 ```
 Set-AGMOrgHost -orglist "526553" -hostid 449560
 ```
 We then validate, confirming 460500 is gone and 449560 has been added.
 ```
PS > $org = Get-AGMOrg -orgid 526553
PS > $org.resourcecollection.hostlist
442009
449560
```

# SQL Server

## SQL Server Mount

In this 'story' a user wants to mount the latest snapshot of a SQL DB to a host

The user finds the appID for the source DB

```
PS /> Get-AGMLibApplicationID smalldb

id      friendlytype hostname appname appliancename applianceip  appliancetype managed
--      ------------ -------- ------- ------------- -----------  ------------- -------
5552336 SQLServer    hq-sql   smalldb sa-sky        172.24.1.180 Sky              True
261762  Oracle       oracle   smalldb sa-sky        172.24.1.180 Sky              True
```

The user validates the name of the target host:

```
PS /> Get-AGMLibHostID demo-sql-4

id       hostname   osrelease                                    appliancename applianceip  appliancetype
--       --------   ---------                                    ------------- -----------  -------------
43673548 demo-sql-4 Microsoft Windows Server 2019 (version 1809) sa-sky        172.24.1.180 Sky
```

The user validates the SQL instance name on the target host.  Because the user isn't sure about naming of the hostname  they used '~' to get a fuzzy search.  Because they couldn't remember the exact apptype for SQL instance, they again just used a fuzzy search for 'instance':

```
PS /> Get-AGMApplication -filtervalue "hostname~demo-sql-4&apptype~instance" | select pathname

pathname
--------
DEMO-SQL-4
```
Because applications can have images on multiple appliances, if we don't specify an Image name or Image ID, we need to tell AGM which appliance to use for the source image.   We do this specifying the clusterid of the relevant appliance with -mountapplianceid.   To learn the clusterids we run this command:
```
Get-AGMAppliance | select-object name,clusterid
```

The user then runs a mount command specifying the source appid, mountapplianceid, target host and SQL Instance and DB name on the target:

```
PS /> New-AGMLibMSSQLMount -appid 5552336 -mountapplianceid 1415071155 -targethostname demo-sql-4 -label "test and dev made easy" -sqlinstance DEMO-SQL-4 -dbname avtest

```

The user finds the running job:

```
PS /> Get-AGMLibRunningJobs

jobname      jobclass   apptype         hostname                    appname               appid    appliancename startdate           progress targethost
-------      --------   -------         --------                    -------               -----    ------------- ---------           -------- ----------
Job_24358189 mount      SqlServerWriter hq-sql                      smalldb               5552336  sa-sky        2020-06-24 14:50:08       53 demo-sql-4
```

The user tracks the job to success:

```
PS /> Get-AGMLibFollowJobStatus Job_24358189

jobname      status  progress queuedate           startdate           duration
-------      ------  -------- ---------           ---------           --------
Job_24358189 running       95 2020-06-24 14:49:33 2020-06-24 14:50:08 00:01:30


jobname      status    message startdate           enddate duration
-------      ------    ------- ---------           ------- --------
Job_24358189 succeeded         2020-06-24 14:50:08         00:01:36
```

The user validates the mount exists:

```
PS /> Get-AGMLibActiveImage

imagename      apptype         hostname        appname appid    mountedhostname childappname appliancename consumedsize label
---------      -------         --------        ------- -----    --------------- ------------ ------------- ------------ -----
Image_24358189 SqlServerWriter hq-sql          smalldb 5552336  demo-sql-4      avtest       sa-sky                   0 test and dev made easy
```

The user works with the DB until it is no longer needed.

The user then un-mounts the DB, specifying -d to delete the mount:

```
PS /> Remove-AGMMount Image_24358189 -d
```

The user confirms if the mount created a child app
```
PS /> Get-AGMLibApplicationID avtest

id       friendlytype hostname   appname appliancename applianceip  appliancetype managed
--       ------------ --------   ------- ------------- -----------  ------------- -------
52410625 SQLServer    demo-sql-4 avtest  sa-sky        172.24.1.180 Sky             False
```

The user deletes the child app:
```
PS /> Remove-AGMApplication 52410625
```

### SQL Server mount with point in time recovery

In this 'story' a user wants to mount a specific snapshot of a SQL DB to a host rolled to a specific point in time.   We start with an appname:

The user finds the appID for the source DB

```
PS /Users/anthony> Get-AGMLibApplicationID smalldb

id      friendlytype hostname appname appliancename applianceip  appliancetype managed
--      ------------ -------- ------- ------------- -----------  ------------- -------
5552336 SQLServer    hq-sql   smalldb sa-sky        172.24.1.180 Sky              True
261762  Oracle       oracle   smalldb sa-sky        172.24.1.180 Sky              True

```
We now get a list of images:

```
PS /Users/anthony> Get-AGMLibImageDetails 5552336

backupname            jobclass     consistencydate     endpit
----------            --------     ---------------     ------
Image_24351142        snapshot     2020-06-24 11:55:37 2020-06-25 15:07:16
Image_24386274        snapshot     2020-06-25 11:46:22 2020-06-25 15:07:16
```
We have two snapshots and logs as well.

The user runs a mount command specifying the source appid, target host and SQL Instance and DB name on the target as well as a recovery point in ISO 860 format and image name.  However they specify the wrong date, one earlier than the consistency point:

```
PS /Users/anthony> New-AGMLibMSSQLMount -imagename Image_24351142 -appid 5552336 -targethostname demo-sql-4 -label "test and dev made easy" -sqlinstance DEMO-SQL-4 -dbname avtest -recoverypoint "2020-06-23 16:00"

errormessage
------------
Specified recovery point 2020-06-23 16:00 is earlier than image consistency date 2020-06-24 11:55:37.  Specify an earlier image.

```
They fix the date and successfully run the command:
```
PS /Users/anthony> New-AGMLibMSSQLMount -imagename Image_24351142 -appid 5552336 -targethostname demo-sql-4 -label "test and dev made easy" -sqlinstance DEMO-SQL-4 -dbname avtest -recoverypoint "2020-06-24 16:00"
```

### SQL Server Instance mount

In this 'story' a user wants to mount two databases from the latest snapshot of a SQL Instance to a host.  Most aspects of the story are the same as above, however they need some more information to run their mount command.   They learn the App ID of the SQL Instance:

```
PS /Users/anthony> Get-AGMLibApplicationID  HQ-SQL

id      friendlytype hostname appname appliancename applianceip  appliancetype managed
--      ------------ -------- ------- ------------- -----------  ------------- -------
5534398 SqlInstance  hq-sql   HQ-SQL  sa-sky        172.24.1.180 Sky              True
```

We now learn the instance members:
```
PS /Users/anthony> Get-AGMApplicationInstanceMember 5534398

rule            : exclude
totaldb         : 9
includecount    : 4
excludecount    : 4
ineligiblecount : 1
ineligiblelist  : {@{id=5552336; appname=smalldb; apptype=SqlServerWriter; srcid=4808; sensitivity=0; systemdb=False; ispartofmemberrule=False; appstate=0}}
eligiblelist    : {@{id=5552340; appname=ReportServer; apptype=SqlServerWriter; srcid=4810; sensitivity=0; systemdb=False; ispartofmemberrule=True; appstate=0}, @{id=5552338; appname=ReportServerTempDB; apptype=SqlServerWriter;
                  srcid=4809; sensitivity=0; systemdb=False; ispartofmemberrule=True; appstate=0}, @{id=5552346; appname=master; apptype=SqlServerWriter; srcid=4813; sensitivity=0; systemdb=False; ispartofmemberrule=True; appstate=0},
                  @{id=50805022; appname=model; apptype=SqlServerWriter; srcid=23401122; sensitivity=0; systemdb=False; ispartofmemberrule=False; appstate=0}…}               
```

However the eligible list is not easy to read, so lets expand it and put it into a table.  This is much easier to read:

```
PS /Users/anthony> Get-AGMApplicationInstanceMember 5534398 | Select-Object -ExpandProperty eligiblelist | ft

id       appname            apptype         srcid    sensitivity systemdb ispartofmemberrule appstate
--       -------            -------         -----    ----------- -------- ------------------ --------
5552340  ReportServer       SqlServerWriter 4810               0    False               True        0
5552338  ReportServerTempDB SqlServerWriter 4809               0    False               True        0
5552346  master             SqlServerWriter 4813               0    False               True        0
50805022 model              SqlServerWriter 23401122           0    False              False        0
5552342  msdb               SqlServerWriter 4811               0    False               True        0
5552334  smalldb1           SqlServerWriter 4805               0    False              False        0
5552332  smalldb2           SqlServerWriter 4804               0    False              False        0
5552330  smalldb3           SqlServerWriter 4803               0    False              False        0
```
So now we know the names of the DBs inside our SQL instance, we just need to chose a Consistency group name  to hold them and any prefixes and suffixes we want to use.  We then run our mount command like this:

```
PS /Users/anthony>  New-AGMLibMSSQLMount -appid 5534398 -targethostname demo-sql-5 -label "AV instance mount" -sqlinstance DEMO-SQL-5 -consistencygroupname avcg -dbnamelist "smalldb1,smalldb2" -dbnameprefix "testdev_" -dbnamesuffix "_av"
```

### Finding Images if the application is orphaned

Presuming we know the name of our orphan app and the host it once lived on.  Choose the backupname of the image you want by searching for the appname:

```
PS > get-agmimage -filtervalue appname=avdb1 | select id,host,consistencydate,backupname,jobclass | ft *

id      host                   consistencydate     backupname     jobclass
--      ----                   ---------------     ----------     --------
7397674 @{hostname=sydwinsql5} 2020-10-30 13:55:26 Image_10979893 snapshot
7397570 @{hostname=sydwinsql5} 2020-10-30 13:54:16 Image_10979874 snapshot
```