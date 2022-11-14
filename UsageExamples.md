
# Usage Examples
This document contains usage examples that include both AGMPowerCLI and AGMPowerLIB commands.

**[Appliances](#appliances)**<br>
**[Appliance Add And Remove](#appliance-add-and-remove)**<br>
**[Appliance Discovery Schedule](#appliance-discovery-schedule)**<br>
**[Appliance Info And Report Commands](#appliance-info-and-report-commands)**<br>
**[Appliance Parameter and Slot Management](#appliance-parameter-and-slot-management)**</br>
**[Appliance Timezone](#appliance-timezone)**<br>

**[Applications](#applications)**<br>
**[Application bulk unprotection](#application-bulk-unprotection)**<br>

**[Backup Plans](#backup-plans)**</br>
**[Displaying Backup Plan Policies](#displaying-backup-plan-policies)**</br>
**[Importing and Exporting Policy Templates](#importing-and-exporting-policy-templates)**</br>

**[Billing](#billing)**</br>
**[Display Backup SKU Usage](#display-backup-sku-usage)**</br>

**[Compute Engine Instances](#compute-engine-instances)**<br>
**[Compute Engine Cloud Credentials](#compute-engine-cloud-credentials)**<br>
**[Compute Engine Instance Discovery](#compute-engine-instance-discovery)**<br>
**[Compute Engine Instance Management](#compute-engine-instance-management)**<br>
**[Compute Engine Instance Conversion from VMware VM](#compute-engine-instance-conversion-from-vmware-vm)**</br>
**[Compute Engine Instance Multi Conversion from VMware VM](#compute-engine-instance-multi-conversion-from-vmware-vm)**</br>
**[Compute Engine Instance Mount](#compute-engine-instance-mount)**<br>
**[Compute Engine Instance Multi Mount Disaster Recovery](#compute-engine-instance-multi-mount-disaster-recovery)**<br>
**[Compute Engine Instance Onboarding Automation](#compute-engine-instance-onboarding-automation)**<br>

**[Consistency Groups](#consistency-groups)**<br>
**[Consistency Group Management](#consistency-group-management)**<br>

**[Images](#images)**<br>
**[Image expiration](#image-expiration)**<br>
**[Image creation with an On-Demand Job](#image-creation-with-an-ondemand-job)**<br>
**[Image creation in bulk using policy ID](#image-creation-in-bulk-using-policy-id)**<br>
**[Image import from OnVault](#image-import-from-onvault)**<br>
**[Image restore](#image-restore)**<br>

**[Mount](#mount)**</br>
**[Multi Mount for Ransomware Analysis](#multi-Mount-for-ransomware-analysis)**</br>

**[Organizations](#organizations)**<br>
**[Organization Creation](#organization-creation)**<br>

**[SAP HANA](#sap-hana)**</br>
**[SAP HANA Mount](#sap-hana-mount)**</br>
**[SAP HANA](#sap-hana)**</br>

**[SQL Server](#sql-server)**</br>
**[SQL Server Mount](#sql-server-mount)**</br>
**[SQL Server Mount with point in time recovery](#sql-server-mount-with-point-in-time-recovery)**</br>
**[SQL Server Mount and Migrate](#sql-server-mount-and-migrate)**</br>
**[SQL Server Multi Mount and Migrate](#sql-server-multi-mount-and-migrate)**</br>
**[SQL Server Instance Mount](#sql-server-instance-mount)**</br>
**[SQL Server protecting and rewinding child apps](#sql-server-protecting-and-rewinding-child-apps)**</br>

**[VMware](#vmware)**</br>
**[VMware Multi Mount](#vmware-multi-mount)**</br>

**[Workflows](#Workflows)**</br>
**[Running a Workflow](#running-a-workflow)**</br>


# Appliances


## Appliance add and remove

> **Note**:   You cannot perform Sky appliance add and remove in Google Cloud Backup and DR.  This is for Actifio only.

You may want to add or remove a Sky Appliance from AGM.   You can list all the Sky Appliances with this command:
```
Get-AGMAppliance | select id,name,ipaddress
```
Output should look like this:
```
id    name       ipaddress
--    ----       ---------
7286  backupsky1 10.194.0.20
45408 backupsky2 10.194.0.38
```
We can then remove the Sky Appliance by specifying the ID of the appliance with this command:
```
Remove-AGMAppliance 45408
```
We list the appliances with:
```
Get-AGMAppliance | select id,name,ipaddress
```
Output should look like this:
```
id   name       ipaddress
--   ----       ---------
7286 backupsky1 10.194.0.20
```
We can add the Sky Appliance back with this command.  Note we can do a dryrun to make sure the add will work, but you don't need to.  The main thing with a dry run is we need to see an approval token because that is key to actually adding the appliance.  
```
New-AGMAppliance -ipaddress 10.194.0.38 -username admin -password password -dryrun | select-object approvaltoken,cluster,report
```
Output should look like this:
```
approvaltoken          cluster                                                      report
-------------          -------                                                      ------
05535A005F051E00480608 @{clusterid=141925880424; ipaddress=10.194.0.38; masterid=0} {"errcode":0,"summary":"Objects to be imported:\n\t.....
```
This is the same command but without the dryrun:
```
New-AGMAppliance -ipaddress 10.194.0.38 -username admin -password password  | select-object cluster,report
```
Output should look like this:
```
cluster                                                                                                               report
-------                                                                                                               ------
@{id=45582; href=https://10.194.0.3/actifio/cluster/45582; clusterid=141925880424; ipaddress=10.194.0.38; masterid=0} {"errcode":0,"summary"...
```
We list the appliances with:
```
Get-AGMAppliance | select id,name,ipaddress
```
Output should look like this:
```
id    name       ipaddress
--    ----       ---------
45582 backdrsky2 10.194.0.38
7286  backupsky1 10.194.0.20
```
## Appliance discovery schedule

To set the start time when auto discovery runs (instead of the default 2am), first learn the appliance ID:
```
Get-AGMAppliance | select id,name
```
Output should look like this:
```
id     name
--     ----
591780 backup-server-67154
406219 backup-server-29736
```
Display if an existing schedule is set (if no schedule is shown, then the default of 2am is in use):
```
$applianceid = 406219
Get-AGMAPIApplianceInfo -applianceid $applianceid -command getschedule -arguments "name=autodiscovery"
```
Output should look like this:
```
time  frequency
----  ---------
10:00 daily
```
To set the schedule use the following syntax.  In this example we set it to 9am rather than 10am.
```
$applianceid = 406219
Set-AGMAPIApplianceTask -applianceid $applianceid -command setschedule -arguments "name=autodiscovery&frequency=daily&time=09:00"
```
Output should look like this:
```
status
------
     0
```
Check schedule with this command:
```
Get-AGMAPIApplianceInfo -applianceid $applianceid -command getschedule -arguments "name=autodiscovery"
```
Output should look like this:
```
time  frequency
----  ---------
09:00 daily
```

## Appliance info and report commands

> **Note**:   If you want to manage appliance parameters such as slots, use the **Get-AGMLibApplianceParameter** and **Set-AGMLibApplianceParameter** commands documented [here](https://github.com/Actifio/AGMPowerLib#user-story-appliance-parameter-management-and-slot-limits).

You can run info and report commands on an appliance using AGMPowerCLI.  To do this we need to tell the Management Console which appliance to run the command on. So first learn your appliance ID with **Get-AGMAppliance**.  In this example the appliance we want to work with is ID 70194.
```
Get-AGMAppliance | select id,name
```
Output should look like this:
```
id     name
--     ----
406219 backup-server-29736
70194  backup-server-32897
```
### Running info commands
We can use **Get-AGMAPIApplianceInfo** to send info (also known as udsinfo) commands.   In this example we send the **udsinfo lshost** command to the appliance with ID 70194.
```
Get-AGMAPIApplianceInfo -applianceid 70194 -command lshost | select id,hostname
```
Output should look like this:
```
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
Get-AGMAPIApplianceReport -applianceid 70194 -command reportlist
```
Output should look like this:
```
ReportName             ReportFunction                                                                           RequiredRoleRights
----------             --------------                                                                           ------------------
reportadvancedsettings Show all Advanced policy options that have been set                                      AdministratorRole
```
In this example we run the *reportapps* command:
```
Get-AGMAPIApplianceReport -applianceid 70194 -command reportapps | select hostname,appname,"MDLStat(GB)"
```
Output should look like this:
```
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
Get-AGMAPIApplianceReport -applianceid 70194 -command reportapps -arguments "-a tiny" | select hostname,appname,"MDLStat(GB)"
```
Output should look like this:
```
HostName AppName MDLStat(GB)
-------- ------- -----------
tiny     tiny    20.000
```
#### Running a commnd with multiple arguments
If you need to send multiple arguments separate them with an **&**, for example, this command send the **reportimages** command to appliance ID 406219 with the **-a 0** and **-s** parameters and exports it to CSV.
```
Get-AGMAPIApplianceReport -applianceid 406219 -command reportimages -arguments "-a 0&-s" |  Export-Csv disks.csv
```

## Appliance Parameter and Slot Management

Each backup appliance has a set of parameters that are used to:

* Enable and disable functions.  These parameters are usually: 0 (off) or 1 (on)
* Set slot limits to control concurrently running jobs
* Set values such as timeouts

### Displaying and setting parameters

If you have a single appliance then you can run this command to display all available parameters:
```
Get-AGMLibApplianceParameter
```
If you have multiple appliances then learn the appliance ID of the relevant appliance and then use that ID, like this:
```
Get-AGMAppliance | select id,name
```
Output should look like this:
```
id     name
--     ----
406219 backup-server-29736
406230 backup-server-32142
```
Now get the parameters for your selected appliance:
```
Get-AGMLibApplianceParameter -applianceid 406219
```
Output should look like this:
```
enableexpiration                      : 1
< output truncated>
```
To display a specific parameter use syntax like this (you may need the **-applianceid** parameter):
```
Get-AGMLibApplianceParameter -param enablescheduler
```
To set a parameter use syntax like this (you may need the **-applianceid** parameter).  In this example we disable the scheduler by setting it to 0:
```
Get-AGMLibApplianceParameter -param enablescheduler
Set-AGMLibApplianceParameter -param enablescheduler -value 0
```
### Changing maximum backup jobs per host (appliance level - affects all hosts)

There is a system parameter that controls the maximum number of backup jobs that can be run against every host on that appliance. By default this value is 1, meaning a maximum of one backup job can be run per host. Scheduled jobs will queue behind the running job. Ondemand jobs with the -queue option will join the queue waiting for the running job to finish.

You can display and change this setting using the following command (you may need the **-applianceid** parameter).  In this example we allow 2 backup jobs per host:
```
Get-AGMLibApplianceParameter -param backupjobsperhost
Set-AGMLibApplianceParameter -param backupjobsperhost -value 2
```
### Changing maximum mount jobs per host (appliance level - affects all hosts)

By default only one mount job can run on a host at one point in time.

This value can be displayed using this syntax (you may need the **-applianceid** parameter):
```
Get-AGMLibApplianceParameter -param maxconcurrentmountsperhost
```
It can be changed with syntax like this (you may need the **-applianceid** parameter).  In this example we allow two concurrent mount jobs per host:
```
Set-AGMLibApplianceParameter -param maxconcurrentmountsperhost -value 2
```
Note this is a system wide parameter. There is no way to set this on a per host basis.

### Changing maximum mount and backup jobs per appliance using slots (appliance level - affects all hosts)


Each backup appliance uses a pacing mechanism known as *slots* to manage the number of jobs that can run simultaneously on that appliance.   This means that if has a policy has more applications attempting to start a backup job than there are available slots, that the appliance running your jobs may hit a slot limit, resulting in the excess jobs over the slot limit going into *queued* status, waiting for free slots, rather than starting immediately.    There is nothing inherantly wrong this, its simply a form of *pacing*.

To manage this we can adjust what are called slot values.  Note that while we are using AGMPowerLib commands to do this, you need to ensure your AGMPowerCLI is on version 0.0.0.35 or higher.   You can check your AGMPowerCLI version with this command:
**Get-Command -module AGMPowerCLI**

Firstly learn the ID of the relevant Appliance.  In this case the appliance running our jobs is **project1sky** so we will use applianceid **361153**
```
Get-AGMAppliance | select id,name
```
Output should look like this:
```
id     name
--     ----
361153 project1sky
296357 londonsky.c.project1.internal
```
Now depending on which job type, we modify different slots.

#### Slot limits for mount jobs
We need to learn the current value of the params that relate to **dataaccess** slots. This is because a mount job is an data access job, meaning each mount job uses one data access slot while it is running.  There are three relevant slots:
* **reserveddataaccessslots** This is the guaranteed number of data access jobs that can run at any time.  
* **maxdataaccessslots** This controls the maximum number of data access jobs that can run at any time.  
* **unreservedslots** Unreserved slots are used if all the reserved slots are in use but more jobs wants to run up to the maximum number for that type.

We learn the values with:
```
Get-AGMLibApplianceParameter -applianceid 361153 -param reserveddataaccessslots
Get-AGMLibApplianceParameter -applianceid 361153 -param maxdataaccessslots
Get-AGMLibApplianceParameter -applianceid 361153 -param unreservedslots
```
Here is an example:
```
Get-AGMLibApplianceParameter -applianceid 361153 -param reserveddataaccessslots
```
Output should look like this:
```
reservedondemandslots
---------------------
3
```
We can set the slots to larger values like this:
```
Set-AGMLibApplianceParameter -applianceid 361153 -param reserveddataaccessslots -value 10
Set-AGMLibApplianceParameter -applianceid 361153 -param maxdataaccessslots -value 15
Set-AGMLibApplianceParameter -applianceid 361153 -param unreservedslots -value 15
```
Here is an example:
```
Set-AGMLibApplianceParameter -applianceid 361153 -param reserveddataaccessslots -value 10
```
Output should look like this:
```
reservedondemandslots changed from 3 to 10
```
#### Slot limits for OnVault jobs
We need to learn the current value of the params that relate to **onvault** slots.  Note this is listed as **vault**
* **reservedvaultslots** This is the guaranteed number of OnVault jobs that can run at any time.  
* **maxvaultslots** This controls the maximum number of OnVault jobs that can run at any time.  
* **unreservedslots** Unreserved slots are used if all the reserved slots are in use but more jobs wants to run up to the maximum number for that type.

We learn the values with:
```
Get-AGMLibApplianceParameter -applianceid 361153 -param reservedvaultslots
Get-AGMLibApplianceParameter -applianceid 361153 -param maxvaultslots
Get-AGMLibApplianceParameter -applianceid 361153 -param unreservedslots
```
Set can the slots to larger values like this:
```
Set-AGMLibApplianceParameter -applianceid 361153 -param reservedvaultslots -value 10
Set-AGMLibApplianceParameter -applianceid 361153 -param maxvaultslots -value 15
Set-AGMLibApplianceParameter -applianceid 361153 -param unreservedslots -value 15
```
#### Slot limits for snapshot jobs
We need to learn the current value of the params that relate to **snapshot** slots.
* **reservedsnapslots** This is the guaranteed number of snapshot jobs that can run at any time.  
* **maxsnapslots** This controls the maximum number of snapshot jobs that can run at any time.  
* **unreservedslots** Unreserved slots are used if all the reserved slots are in use but more jobs wants to run up to the maximum number for that type.

We learn the values with:
```
Get-AGMLibApplianceParameter -applianceid 361153 -param reservedsnapslots
Get-AGMLibApplianceParameter -applianceid 361153 -param maxsnapslots
Get-AGMLibApplianceParameter -applianceid 361153 -param unreservedslots
```
We set the slots to larger values like this:
```
Set-AGMLibApplianceParameter -applianceid 361153 -param reservedsnapslots -value 10
Set-AGMLibApplianceParameter -applianceid 361153 -param maxsnapslots -value 15
Set-AGMLibApplianceParameter -applianceid 361153 -param unreservedslots -value 15
```
## Appliance timezone
To display Appliance timezone, learn the appliance ID and then query the relevant appliance:
```
Get-AGMAppliance | select id,name
```
Output should look like this:
```
id     name
--     ----
591780 backup-server-67154
406219 backup-server-29736

Get-AGMAppliance 406219 | select timezone
```
Output should look like this:
```
timezone
--------
UTC
```
To set Appliance timezone, use the following syntax, making sure to specify a valid timezone:

```
$timezone = "Australia/Sydney"
$applianceid = 406219
Set-AGMAPIApplianceTask -applianceid $applianceid -command "chcluster" -arguments "timezone=$timezone&argument=11"
```
Output should look like this:
```
status
------
     0

```
Now wait 3 minutes (this takes a little time to update).   If you see the old timezone, please wait a little longer.
```
Get-AGMAppliance 406219 | select timezone
```
Output should look like this:
```
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
$appstounmanage = Import-Csv -Path .\missingvms.csv
$appstounmanage
```
Output should look like this:
```
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


# Backup Plans

Note that Backup Plans is the new term for the SLA Architect.  

## Displaying Backup Plan Policies

If you wish to display general information about the policies in your backup plan templates then use this command:
```
Get-AGMLibPolicies
```
If you wish to know which policies are using enforced retention use this command:
```
Get-AGMLibPolicies -enforcedretention
```
If you wish to know where your compute engine instance snapshots are going use this command:
```
Get-AGMLibPolicies -snapshotlocation
```
If you wish to display all advanced policy options use this command:
```
Get-AGMLibPolicies -advancedpolicysettings
```

## Importing and Exporting Policy Templates

In this user story we are going to export our Policy Templates (also called Service Level Templates or SLTs) from AGM in case we want to import them into a different AGM.

First we validate our SLTs.

```
Get-AGMSLT | select id,name

id    name
--    ----
25606 FSSnaps_RW_OV
17796 FSSnaps
6523  Snap2OV
6392  PDSnaps
```
We now export all the SLTs to a file called export.json.  If we only want to export specific SLTs, then don't specify **-all** and you will get a help menu.
```
Export-AGMLibSLT -all -filename export.json
```
We now login to our target AGM

We validate there are no Templates.   Currently this function expects there to be no templates in the target.  However if there are, as long as there are no name clashes, the import will still succeed.  In this example there are no templates in the target.
```
Get-AGMSLT
```
Output should look like this:
```
count items
----- -----
    0 {}
```
We now import the Templates and then validate we now have four imported SLTs:
```
Import-AGMLibSLT -filename export.json
```
Output should look like this:
```
count items
----- -----
    4 {@{@type=sltRest; id=21067; href=https://10.194.0.3/actifio/slt/21067; name=FSSnaps_RW_OV; override=true; policy_href=https://10.194.0.3/actifio/slt/21067/policy}, @{@type=sltRest; id=21070; href=https://10.194.0.3/acti…
```
We check what happened:
```
Get-AGMSLT | select id,name
```
Output should look like this:
```
id    name
--    ----
21081 PDSnaps
21072 Snap2OV
21070 FSSnaps
21067 FSSnaps_RW_OV
```
Our import is now complete.

# Billing

# Display Backup SKU Usage

Usage for the Backup and DR Service is charged on a per GiB of protected application (front end) data.    Pricing is documented here:
https://cloud.google.com/backup-disaster-recovery/pricing

If you wish to display how large your applications are in GiB per SKU type (to help allocate Backup SKU usage between business departments or just to understand how large an application is), then you can use the following command:
```
Get-AGMLibBackupSKUUsage
```
Output will look like this:
```
Get-AGMLibBackupSKUUsage

appliancename  : backup-server-29736
applianceid    : 406219
apptype        : VMBackup
hostname       : avw tiny
appname        : AVW Tiny
skudescription : Default Backup SKU for VM (Compute Engine and VMware) and File system data
skuusageGiB    : 4.051
```
If the SKU description is not listed then please open an Issue in GitHub and share the listed apptype.


# Compute Engine Instances

## Compute Engine Cloud Credentials

### Listing Cloud Credentials

```
Get-AGMCredential
```
Output should look like this:
```
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
New-AGMCredential -name test -filename ./glabco-4b72ba3d6a69.json -zone australia-southeast1-c -clusterid "144292692833,145759989824"
```
Output should look like this:
```
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
New-AGMCredential -name test -filename ./glabco-4b72ba3d6a69.json -zone australia-southeast1-c -clusterid "144292692833,145759989824" -projectid glabco1

@type                    errors
-----                    ------
testCredentialResultRest {@{errorcode=4000; errormsg=No privileges for project or incorrect project id provided in credential json.; clusters=System.Object[]}}
```
Duplicate name
```
New-AGMCredential -name test -filename ./glabco-4b72ba3d6a69.json -zone australia-southeast1-c -clusterid "144292692833,145759989824"

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
Remove-AGMCredential -credentialid 219764 -applianceid "145759989824,144292692833"
```
Update existing credential with new key and change its name
```
Set-AGMCredential -id 219764  -name test1 -filename ./glabco-4b72ba3d6a69.json
```
Output should look like this:
```
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
$discovery.items.vm | select vmname,instanceid
```
Output should look like this:
```
vmname      instanceid
------      ----------
consoletest 4240202854121875692
agm         6655459695622225630
```
The total number of VMs that were found and the total number fetched will be different.  In this example, 57 VMs can be found, but only 50 were fetched as the limit defaults to 50:
```
Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid avwlab2
```
Output should look like this:
```
count items                             totalcount
----- -----                             ----------
   50 {@{vm=}, @{vm=}, @{vm=}, @{vm=}…}         57
```
By setting the limit to 60 we now fetch all 57 VMs:
```
Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid avwlab2 -limit 60
```
Output should look like this:
```
count items                             totalcount
----- -----                             ----------
   57 {@{vm=}, @{vm=}, @{vm=}, @{vm=}…}         57

```

Or we could fetch the first 50 in one command and then in a second command, set an offset of 1, which will fetch all VMs from 51 onwards (offset it added to limit to denote the starting point).  In this example we fetch the remaining 7 VMs (since the limit is 50):
```
Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid avwlab2 -limit 50 -offset 1
```
Output should look like this:
```
count items                             totalcount
----- -----                             ----------
    7 {@{vm=}, @{vm=}, @{vm=}, @{vm=}…}         57

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
Get-AGMApplication -filtervalue apptype=GCPInstance | select appname,apptype,managed,id, @{N='sltid'; E={$_.sla.slt.id}}, @{N='slpid'; E={$_.sla.slp.id}} | ft
```
Output should look like this:
```
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
$appdata = Get-AGMApplication -filtervalue appname=bastion
$appdata.host.ipaddress
10.152.0.3

```

## Compute Engine Instance Conversion from VMware VM

In this user story we are going to use VMware VM snapshots (or system state backups) to create a new Compute EngineInstance.  This will be done by using the **New-AGMLibGCEConversion** command.

This command requires several inputs so first we explore how to get them.

### Creating a single Compute Engine Instance Instance from VMware/System State Backup

The best way to create the syntax for this command, at least for the first time you run it,  is to simply run the **New-AGMLibGCEConversion** command without any parameters.
This starts what we called *guided mode* which will help you learn all the syntax to run the command.
The guided menus will ask questions in roughly the same order as the menus appear in the AGM Web GUI.
The end result is you will get several choices:

1. Run the command there and then
1. Print out a simple command to run later.   Note you may want to edit this command as we explain in a moment.
1. Print out a sample CSV file to use with  **New-AGMLibGCEConversionMulti**

#### Determining which image is used for the mount

The sample command printed by guidedmode has an imageid, an appid and an appname. Consider:
```
-appid       If you specify this, then the most recent image for that app will be mounted.  This is the most exact choice to get the latest image.
-appname     If you specify this, then the most recent image for that app will be mounted provided the appname is unique.   If the appname is not unique, then you will need to switch to appid.
-imageid     If you specify this, then this image will be mounted. You will need to learn this imageid before you run the command.
-imagename   If you specify this, then this image will be mounted. You will need to learn this imagename before you run the command.
```
In general the best choice is **-appid** as it saves you having to work out the imageid or name and gives you the most recent image (for the latest RPO).
If constructing a CSV file for multi mount you always need to include the **appname**, even if you are using the **appid**.  This is to ensure we can identify the source app.

#### Manually constructing output

If you want to manually construct the output, or get some variables to tweak the output consider the following tips:

To learn which Cloud Credential srcids are available use the following command.  Note that this is appliance specific, so when you specify a srcid you are specifing a service account that is stored on a specific appliance.  This means if you want to split the workload across multiple appliances, then you can do this by using the relevant srcid of each appliance (although this also need the relevant applications to be imported into the relative appliances when using OnVault backups).
```
Get-AGMLibCredentialSrcID
```
To learn the AppIDs use this command (note the ApplianceName is where the images were created, in other words the source appliance, not the one running the mount):
```
Get-AGMApplication -filtervalue "apptype=SystemState&apptype=VMBackup" | select id,appname,@{N='appliancename'; E={$_.cluster.name}} | sort-object appname
```
To learn the image ID or image name, you could use this command (change jobclass to snapshot or StreamSnap if needed):
```
Get-AGMImage -filtervalue "apptype=SystemState&apptype=VMBackup&jobclass=OnVault" | select appname,id,name,consistencydate,@{N='diskpoolname'; E={$_.diskpool.name}} | sort-object appname,consistencydate | format-table
```

There are many parameters that may need to be supplied:
```
-appid           The application ID of the source VMWare VM or System State you want to mount.  If you use this you don't need to specify an image ID or imagename.   It will use the latest image of that application.
-appname         The application name of the source VMWare VM or System State you want to mount.  This needs to be unique.  If you use this you don't need to specify an image ID or imagename.   It will use the latest image of that application.
-imageid         You need to supply either the imageid or the imagename or both (or specify -appid instead to get the latest image).  To avoid using this, you can specify -appid or -appname instead
-imagename       You need to supply either the imageid or the imagename or both (or specify -appid instead to get the latest image).  To avoid using this, you can specify -appid or -appname instead
-srcid           Learn this with Get-AGMLibCredentialSrcID.  You need to use the correct srcid that matches the appliance that is going to run the mount.
-serviceaccount  The service account.
-projectname     This is the unique Google Project name where the new instance will be created.
-sharedvpcprojectid  If the instance is being created in a service project, what is the ID the project that is sharing the VPC (optional)
-nodegroup       If creating an instance into a sole tenant node group, this is the name of the node group (optional)
-region          This is the GCP Region such as:   australia-southeast1
-zone            This is the GCP Zone such as: australia-southeast1-c
-instancename    This is the name of the new instance that will be created.   It needs to be unique in that project
-machinetype     This is the GCP instance machine type such as:  e2-micro
-networktags     Comma separate as many tags as you have, for instance:   -networktags "http-server,https-server"   
-labels          Labels are key value pairs.   Separate key and value with colons and each label with commas.   For example:   -labels "pet:cat,food:fish"
-nic0network     The network name in URL format for nic0
-nic0subnet      The subnet name in URL format for nic0
-nic0externalip  Only 'none' and 'auto' are valid choices.  If you don't use this variable then the default for nic0 is 'none'
-nic0internalip  Only specify this is you want to set an internal IP.  Otherwise the IP for nic0 will be auto assigned.   
-poweroffvm      By default the new Compute EngineInstance will be left powered on after creation.   If you want it to be created but then powered off, then specify this flag.
-migratevm       By default the new Compute EngineInstance will be dependent on the Actifio Appliance.  To migrate all data onto Compute Engine Persistent Disk, then specify this flag.
-preferedsource  Optional,  used if we want to force selection of images from a particular storage pool, either snapshot, streamsnap or onvault  (use lower case)
```
Optionally you can request a second NIC using nic1:
```
-nic1network     The network name in URL format for nic1
-nic1subnet      The subnet name in URL format for nic1
-nic1externalip  Only 'none' and 'auto' are valid choices.  If you don't use this variable then the default for nic1 is 'none'
-nic1internalip  Only specify this is you want to set an internal IP.  Otherwise the IP for nic1 will be auto assigned.   
```
Optionally you can specify that all disks be a different type:
```
-disktype        Has to be one  of pd-balanced, pd-extreme, pd-ssd, pd-standard   All disks in the instance will use this disk type
```
This bring us to command like this one:
```
New-AGMLibGCEConversion -imageid 56410933 -srcid 1234 -region australia-southeast1 -zone australia-southeast1-c -projectname myproject -instancename avtest21 -machinetype e2-micro -networktags "http-server,https-server" -labels "dog:cat,sheep:cow" -nic0network "https://www.googleapis.com/compute/v1/projects/projectname/global/networks/default" -nic0subnet "https://www.googleapis.com/compute/v1/projects/projectname/regions/australia-southeast1/subnetworks/default" -nic0externalip auto -nic0internalip "10.152.0.200" -poweroffvm 
```

What is not supported right now:
1)  Specifying more than one internal IP per subnet.
2)  Specifying different disk types per disk

If you get timeouts, then increase the timeout value with **-timeout 60** when running connect-agm


## Compute Engine Instance Multi Conversion from VMware VM

The expected configuration in this scenario is that the end-user will be looking to recover workloads from VMware into a GCP Zone

| Production Site  | DR Site |
| ------------- | ------------- |
| VMware | GCP Zone |

The goal is to offer a simplified way to manage failover from Production to DR where:
* The backup mechanism is to use VMware snapshots or System State backup
* These images are created by an on-premises Backup Appliance and then replicated into cloud either in an OnVault pool or via StreamSnap.
* DR occurs by issuing commands to the DR Appliance to create new Compute Engine Instance Instances (most likely after importing the OnVault images)
* You may need to first run an OnVault import using this method: https://github.com/Actifio/AGMPowerLib#importing-onvault-images

The best way to create the syntax for this command, at least for the first time you run it,  simply run the **New-AGMLibGCEConversion** command without any parameters.
This starts what we called *guided mode* which will help you create the command.
The guided menus will appear in roughly the same order as the menus appear in the AGM Web GUI.
The end result is you wil get two choices:

1. Print out a simple command
1. Print out a sample CSV file to use with  **New-AGMLibGCEConversionMulti**

If you want to manually construct the output, or get some variables to tweak the output consider the following tips:


### VMware to Compute Engine Instance CSV file

We can take the **New-AGMLibGCEConversion** command to create a new GCP VM and store the parameters needed to run that command in a CSV file. 

If the applications are not yet imported you can use the appname  field provided the VMnames are unique.
Here is an example of the CSV file:
```
srcid,appid,appname,projectname,sharedvpcprojectid,region,zone,instancename,machinetype,serviceaccount,nodegroup,networktags,poweroffvm,migratevm,labels,preferedsource,disktype,nic0network,nic0subnet,nic0externalip,nic0internalip,nic1network,nic1subnet,nic1externalip,nic1internalip
391360,296433,"Centos2","project1","hostproject1","europe-west2","europe-west2-a","newvm1","n1-standard-2","systemstaterecovery@project1.iam.gserviceaccount.com","nodegroup1","https-server",False,True,status:failover,onvault,pd-standard,https://www.googleapis.com/compute/v1/projects/project1/global/networks/actifioanz,https://www.googleapis.com/compute/v1/projects/project1/regions/europe-west2/subnetworks/default,auto,,https://www.googleapis.com/compute/v1/projects/project1/global/networks/default,https://www.googleapis.com/compute/v1/projects/project1/regions/europe-west2/subnetworks/default,,  
       
```
The main thing is the headers in the CSV file needs to be exactly as shown as they are the parameters we pass to the command (although the order is not important).
We can then run a command like this specifying our CSV file:
```
New-AGMLibGCEConversionMulti -instancelist recoverylist.csv 
```
This will load the contents of the file **recoverylist.csv** and use it to start multiple **New-AGMLibGCEConversion** jobs.   They will run in parallel but be started serially.

What is not supported right now:

1.  Specifying more than one internal IP per subnet.
1.  Specifying different disk types per disk
1.  More than two NICS per instance

#### Monitoring the jobs created by a multi mount by creating an object

When you run a multimount, by default all jobs will run before any output is printed.   What we output is a nicely formatted object listing each line in the CSV, the app details, the command that was run and the results.  

The best way to manage this is to load this output into your own object, so do something like this:
```
$newrun = New-AGMLibGCEConversionMulti -instancelist april12test1.csv
```
Then display the output like this:
```
$newrun

appname : Centos3
appid   :
result  : started
message : Job_0866903Optional[Job_0866903] to mount londonsky.c.project1.internal_Image_0499948 started
command : New-AGMLibGCEConversion -projectname project1 -machinetype n1-standard-2 -instancename "apr12test1centos3" -nic0network "https://www.googleapis.com/compute/v1/projects/project1/global/networks/actifioanz" -nic0subnet "https://www.googleapis.com/compute/v1/projects/project1/regions/australia-southeast1/subnetworks/australia" -region "australia-southeast1" -zone "australia-southeast1-a" -srcid
          "391360" -appname "Centos3" -serviceaccount "systemstaterecovery@project1.iam.gserviceaccount.com" -preferedsource onvault

appname : centos2
appid   :
result  : failed
message : Failed to resolve centos2 to a unique valid VMBackup or System State app.  Use Get-AGMLibApplicationID and try again specifying -appid
command : New-AGMLibGCEConversion -projectname project1 -machinetype n1-standard-2 -instancename "apr12test1centos2" -nic0network "https://www.googleapis.com/compute/v1/projects/project1/global/networks/actifioanz" -nic0subnet "https://www.googleapis.com/compute/v1/projects/project1/regions/australia-southeast1/subnetworks/australia" -region "australia-southeast1" -zone "australia-southeast1-a" -srcid
          "391360" -appname "centos2" -serviceaccount "systemstaterecovery@project1.iam.gserviceaccount.com" -preferedsource onvault
```
You can then find all the jobs that didn't start like this:
```
$newrun | where-object {$_.result -ne "started"}

appname : centos2
appid   :
result  : failed
message : Failed to resolve centos2 to a unique valid VMBackup or System State app.  Use Get-AGMLibApplicationID and try again specifying -appid
command : New-AGMLibGCEConversion -projectname project1 -machinetype n1-standard-2 -instancename "apr12test1centos2" -nic0network "https://www.googleapis.com/compute/v1/projects/project1/global/networks/actifioanz" -nic0subnet "https://www.googleapis.com/compute/v1/projects/project1/regions/australia-southeast1/subnetworks/australia" -region "australia-southeast1" -zone "australia-southeast1-a" -srcid
          "391360" -appname "centos2" -serviceaccount "systemstaterecovery@project1.iam.gserviceaccount.com" -preferedsource onvault
```
Once you understand the error you can manually learn the command like this, so you can edit it and run it manually:
```
($newrun | where-object {$_.result -ne "started"}).command
```


#### Monitoring the jobs created by a multi mount by creating an object
If you want to just see the output as each job is run, then add **-textoutput**

The output will look like this:
```
New-AGMLibGCEConversionMulti -instancelist april12test1.csv -textoutput

The following command encountered this error:       Instance Name already in use
New-AGMLibGCEConversion -projectname project1 -machinetype n1-standard-2 -instancename "apr12test1centos1" -nic0network "https://www.googleapis.com/compute/v1/projects/project1/global/networks/actifioanz" -nic0subnet "https://www.googleapis.com/compute/v1/projects/project1/regions/australia-southeast1/subnetworks/australia" -region "australia-southeast1" -zone "australia-southeast1-a" -srcid "391360" -appname "Centos1" -serviceaccount "systemstaterecovery@project1.iam.gserviceaccount.com" -preferedsource onvault

The following command started this job:  Job_0867154Optional[Job_0867154] to mount londonsky.c.project1.internal_Image_0499948 started
New-AGMLibGCEConversion -projectname project1 -machinetype n1-standard-2 -instancename "apr12test1centos3" -nic0network "https://www.googleapis.com/compute/v1/projects/project1/global/networks/actifioanz" -nic0subnet "https://www.googleapis.com/compute/v1/projects/project1/regions/australia-southeast1/subnetworks/australia" -region "australia-southeast1" -zone "australia-southeast1-a" -srcid "391360" -appname "Centos3" -serviceaccount "systemstaterecovery@project1.iam.gserviceaccount.com" -preferedsource onvault


```

### Managing the mounted Compute Engine Instance Instance 

Once we have created a new GCP Instance from PD snapshot, there is no dependency on Actifio because the disks for the instance are all Persistent Disks rather than shared disks from an Actifio Storage Pool,  but the mount is still shown as an Active Image, which means it needs to be managed.   We can see the Active Images with this command:
```
Get-AGMLibActiveImage

imagename        : Image_0021181
apptype          : GCPInstance
appliancename    : project1sky
hostname         : windows
appname          : windows
mountedhost      : avrecovery4
allowedip        :
childappname     : avrecovery4
consumedsize_gib : 0
daysold          : 0
label            :
imagestate       : Mounted
```
We have two choices on how to handle this image:

1. Unmount and delete. This command deletes the mounted image record on the Actifio GO side and the Compute Engine Instance on the GCP side.

```
 Remove-AGMMount Image_0021181  -d
```
2. Preserve the image on GCP side. This command deletes the mounted image record on Actifio GO side but leaves the Compute Engine Instance on the GCP side. In the AGM GUI this is called forgetting the image.   You can see the only difference with the choice above is the -p for preserve.
```
 Remove-AGMMount Image_0021181  -d -p
```



## Compute Engine Instance Mount

In this user story we are going to use Persistent Disk Snapshots to create a new Compute Engine Instance.  This will be done by using the following command:   **New-AGMLibGCPInstance**

This command requires several inputs so first we explore how to get them.

### Demo video

This video will help you understand how to use this command:   https://youtu.be/hh1seRvRZos

### Creating a single Compute Engine Instance from Snapshot

The best way to create the syntax for this command, at least for the first time you run it,  is to simply run the **New-AGMLibGCPInstance** command without any parameters.
This starts what we called *guided mode* which will help you learn all the syntax to run the command.
The guided menus will appear in roughly the same order as the menus appear in the AGM Web GUI.
The end result is you will get several choices:

1. Run the command
1. Print out a simple command to run later.   Note you may want to edit this command as we explain in the next section.
1. Print out a sample CSV file to use with  **New-AGMLibGCPInstanceMultiMount**

#### Determining which image is used for the mount

The sample command printed by guidedmode has an imageid, an appid and an appname. Consider:
```
-appid       If you specify this, then the most recent image for that app will be mounted.  This is the most exact choice to get the latest image.
-appname     If you specify this, then the most recent image for that app will be mounted provided the appname is unique.   If the appname is not unique, then you will need to switch to appid.
-imageid     If you specify this, then this image will be mounted. You will need to learn this imageid before you run the command.
-imagename   If you specify this, then this image will be mounted. You will need to learn this imagename before you run the command.
```
In general the best choice is **-appid** as it saves you having to work out the imageid or imagename and gives you the most recent image (for the best RPO), 
If constructing a CSV file for multi mount you always need to specify the appname, even if you are using the appid.  This is to ensure we can identify the source app.

#### Manually constructing output

If you want to manually construct the output, or get some variables to tweak the output, consider the following tips:

To learn which Applications are suitable use this command:
```
Get-AGMApplication -filtervalue "apptype=GCPInstance&managed=True" | select id,appname,@{N='appliancename'; E={$_.cluster.name}}
```
You could use the same command to export to CSV, like this:
```
Get-AGMApplication -filtervalue "apptype=GCPInstance&managed=True" | select id,appname | Export-Csv -Path ./applist.csv
Get-Content ./applist.csv
```

To learn which Cloud Credential srcids are available use this command:
```
Get-AGMLibCredentialSrcID
```
Make sure that the credential is on the same appliance that is managing the application.
To learn the image ID or image name, you could use this command:
```
Get-AGMImage -filtervalue "apptype=GCPInstance&jobclass=snapshot" | select appname,id,name,consistencydate,diskpool | ft
```
There are many parameters that need to be supplied:
```
-appid           The application ID of the source GCP Instance you want to mount.  If you use this you don't need to specify an image ID or name.   It will use the latest snapshot of that application.
-imageid         You need to supply either the imageid or the imagename or both (or specify -appid instead to get the latest image)
-imagename       You need to supply either the imageid or the imagename or both (or specify -appid instead to get the latest image)
-srcid           Learn this with Get-AGMLibCredentialSrcID.   You need to use the correct srcid that matches the appliance that is protecting the application. 
-serviceaccount  The service account that is being used to request the instance creation.  This is optional.  Otherwise it will use the account from the cloud credential (which is the preferred method)
-projectname     This is the unique Google Project name 
-zone            This is the GCP Zone such as: australia-southeast1-c
-instancename    This is the name of the new instance that will be created.   It needs to be unique in that project
-machinetype     This is the GCP instance machine type such as:  e2-micro
-networktags     Comma separate as many tags as you have, for instance:   -networktags "http-server,https-server"   
-labels          Labels are key value pairs.   Separate key and value with colons and each label with commas.   For example:   -labels "pet:cat,drink:milk"
-retainlabel     Specify true and then any labels in the selected image will be retained in the new Compute Engine instance. Partial label retention is not supported.
-nic0hostproject The project ID of the host project.  This is only needed if nic0network is not in URL format and if the target project is a service project
-nic0network     The network name in URL format for nic0
-nic0subnet      The subnet name in URL format for nic0
-nic0externalip  Only 'none' and 'auto' are valid choices.  If you don't use this variable then the default for nic0 is 'none'
-nic0internalip  Only specify this is you want to set an internal IP.  Otherwise the IP for nic0 will be auto assigned.   
-poweronvm       By default the new Compute Engine Instance will be powered on.   If you want it to be created but left powered off, then specify: -poweronvm false
                 There is no need to specify: -poweronvm true 
```
Optionally you can request a second NIC with these parameters:
```
-nic1hostproject The project ID of the host project.  This is only needed if nic0network is not in URL format and if the target project is a service project
-nic1network     The network name in URL format for nic1
-nic1subnet      The subnet name in URL format for nic1
-nic1externalip  Only 'none' and 'auto' are valid choices.  If you don't use this variable then the default for nic1 is 'none'
-nic1internalip  Only specify this is you want to set an internal IP.  Otherwise the IP for nic1 will be auto assigned.  
```
Optionally you can also change the disk type of the disks in the new GCP VM:
```
-disktype        Has to be one of:   pd-balanced, pd-extreme, pd-ssd, pd-standard   All disks in the instance will use this disk type
```
You can specify any labels you want to supply for this new Compute Engine VM with -label, for instance:

 **-label "pet:cat,drink:milk"**

However if you add **-retainlabel true** then any labels that were used the Compute Engine Instance when the snapshot was created will be applied to the new VM.
Lets imagine the original VM had a label:

**bird:parrot** 

and we specify the following:   

**-retainlabel true -label "pet:cat,drink:milk"**  

then the new VM will have all three labels (the two new ones and the retained one from the original VM).

This brings us to a command like this one:
```
New-AGMLibGCPInstance -imageid 56410933 -srcid 1234 -zone australia-southeast1-c -projectname myproject -instancename avtest21 -machinetype e2-micro -networktags "http-server,https-server" -labels "dog:cat,sheep:cow" -nic0network "default" -nic0subnet "default" -nic0externalip auto -nic0internalip "10.152.0.200" -poweronvm false -retainlabel true
```

## Compute Engine Instance Multi Mount Disaster Recovery

The expected configuration in this scenario is that the end-user wants to recover workloads from one GCP zone into another one:

| Production Site  | DR Site |
| ------------- | ------------- |
| GCP Zone | GCP Zone |

The goal is to offer a simplified way to manage failover or failback where:
* The backup mechanism is persistent disk snapshots
* The images are created by a Backup Appliance in an alternate zone
* DR occurs by issuing commands to the DR Appliance to create new Compute Engine Instances in the DR zone.

### Demo video

This video will help you understand how to use this command:   

https://youtu.be/hh1seRvRZos

Note this is the same as the video linked in the previous section.

### Compute Engine Instance to Compute Engine Instance CSV file

In the previous section we explored using the **New-AGMLibGCPInstance** command to create a new GCP VM.  

What we can do is store the parameters needed to run that command in a CSV file.  
We can generate the CSV file by running **New-AGMLibGCPInstance** in guided mode.
We then run the **New-AGMLibGCPInstanceMultiMount** command specifying the CSV file.

Here is an example of the CSV file:
```
appid,srcid,projectname,zone,instancename,machinetype,serviceaccount,networktags,labels,nic0hostproject,nic0network,nic0subnet,nic0externalip,nic0internalip,nic1hostproject,nic1network,nic1subnet,nic1externalip,nic1internalip,disktype,poweronvm,retainlabel
35590,28417,prodproject1,australia-southeast1-c,tinym,e2-micro,,"http-server,https-server","dog:cat,sheep:cow",,default,default,,, ,,,,pd-balanced,TRUE,TRUE
51919,28417,prodproject1,australia-southeast1-c,mysqlsourcem,e2-medium,,,,default,default,auto,,,actifioanz,australia,auto,10.186.0.200,,,,
36104,28417,prodproject1,australia-southeast1-c,mysqltargetm,e2-medium,,,,,default,default,,10.152.0.200,,,,,pd-ssd,TRUE,TRUE
```
The main thing is the headers in the CSV file needs to be exactly as shown, as they are the parameters we pass to the command (although the field order is not important).
We can then run a command like this specifying our CSV file:
```
New-AGMLibGCPInstanceMultiMount -instancelist recoverylist.csv
```
This will load the contents of the file recoverylist.csv and use it to run multiple **New-AGMLibGCPInstance** jobs.  The jobs will run in parallel (up to the slot limit). In PowerShell 5 they are started in series, however beginning with PowerShell 7 they are started in parallel in groups of 5 (which you can change with -limit XX)
 
If you specify both appid and appname, then the appname column will be ignored.  However having appname is mandatory as it gives you the name of the source application.

What is not supported right now:

1.  Specifying more than one internal IP per subnet.
1.  Specifying different disk types per disk

#### Cleaning up after a multi-mount run

After the multi-mount has finished you may have a large number of Compute Engine Instances to clean up or retain.
One simple strategy is to run this command:
```
Remove-AGMLibMount -gceinstanceforget
```
This will remove the mounted info from AGM side, but leave the instances in place on Google Side.
Then on the Google Console side, keep or delete them as you wish.

#### Monitoring the jobs created by a multi mount by creating an object

When you run a multimount, by default all jobs will run before any output is printed.   What we output is a nicely formatted object listing each line in the CSV, the app details, the command that was run and the results.  

The best way to manage this is to load this output into your own object, so do something like this:
```
$newrun = New-AGMLibGCPInstanceMultiMount -instancelist april12test1.csv
```
Then display the output like this:
```
$newrun
```
You can then find all the jobs that didn't start like this:
```
$newrun | where-object {$_.result -ne "started"}
```
Once you understand the error you can manually learn the command like this, so you can edit it and run it manually:
```
($newrun | where-object {$_.result -ne "started"}).command
```


#### Monitoring the jobs created by a multi mount by realtime output to the screen
If you just want to see the status output as each job is run, then add **-textoutput**

The output will look like this:
```
New-AGMLibGCEConversionMulti -instancelist april12test1.csv -textoutput

The following command encountered this error:       Instance Name already in use
New-AGMLibGCEConversion -projectname project1 -machinetype n1-standard-2 -instancename "apr12test1centos1" -nic0network "https://www.googleapis.com/compute/v1/projects/project1/global/networks/actifioanz" -nic0subnet "https://www.googleapis.com/compute/v1/projects/project1/regions/australia-southeast1/subnetworks/australia" -region "australia-southeast1" -zone "australia-southeast1-a" -srcid "391360" -appname "Centos1" -serviceaccount "systemstaterecovery@project1.iam.gserviceaccount.com" -preferedsource onvault

The following command started this job:  Job_0867154Optional[Job_0867154] to mount londonsky.c.project1.internal_Image_0499948 started
New-AGMLibGCEConversion -projectname project1 -machinetype n1-standard-2 -instancename "apr12test1centos3" -nic0network "https://www.googleapis.com/compute/v1/projects/project1/global/networks/actifioanz" -nic0subnet "https://www.googleapis.com/compute/v1/projects/project1/regions/australia-southeast1/subnetworks/australia" -region "australia-southeast1" -zone "australia-southeast1-a" -srcid "391360" -appname "Centos3" -serviceaccount "systemstaterecovery@project1.iam.gserviceaccount.com" -preferedsource onvault
```



## Compute Engine Instance Onboarding Automation

If we are onboarding large numbers of Compute Engine Instances or we want to auto protect new instances using automation, we can use a function called: **New-AGMLibGCEInstanceDiscovery**

This function needs a CSV file as input to supply the following data to the function:

* **credentialid**  This is used to determine which stored credential is used to connect to Google Cloud. Learn this by running Get-AGMLibCredentialSrcID
* **applianceid**  This is used to determine which backup appliance will manage the new Compute Engine Instance. Learn this by running Get-AGMLibCredentialSrcID
* **project**  this is the project where we are going to look for new Compute Engine Instances
* **zone** this is the zone where we are going to look for new Compute Engine Instances

So if you have two projects, then ensure the credential you have added as a Cloud Credential has been added to both projects as a service account in IAM and then add a line in the CSV for each zone in that project where you want to search.  This does mean if you add new zones to your project you will need to update the CSV to search in those zones.
An example CSV file is as follows:
```
credentialid,applianceid,project,zone
6654,143112195179,avwarglab1,australia-southeast1-c
6654,143112195179,avwarglab1,australia-southeast2-a
6654,143112195179,avwarglab1,australia-southeast2-b
```
When you run  **New-AGMLibGCEInstanceDiscovery** you have to specify one of these two choices:
* **-nobackup**  This will add all new Compute Engine Instances it finds without protecting them
* **-backup**  This will add  all new Compute Engine Instances it finds and for each Instance it will look for a label called **googlebackupplan** (or a label you specify with **-usertag**)  If the value for that label is the name of an existing policy template, it will automatically protect that instance using that template

An example run is as follows.  In the first zone, no new instances were found.  In the second zone, 3 were found and two protected.   A second run is made on each zone where more than 50 instances need to be processed (since we process 50 at a time).  The third zone had no new VMs.   
```
> New-AGMLibGCEInstanceDiscovery -discoveryfile ./disco.csv -backup

count                : 0
totalcount           : 0
credentialid         : 6654
applianceid          : 143112195179
project              : avwarglab1
zone                 : australia-southeast1-c
newgceinstances      : 0
newgceinstancebackup : 0

count                : 3
items                : {@{vm=}, @{vm=}, @{vm=}}
totalcount           : 3
credentialid         : 6654
applianceid          : 143112195179
project              : avwarglab1
zone                 : australia-southeast2-a
newgceinstances      : 3
newgceinstancebackup : 2

count                : 0
totalcount           : 0
credentialid         : 6654
applianceid          : 143112195179
project              : avwarglab1
zone                 : australia-southeast2-b
newgceinstances      : 0
newgceinstancebackup : 0
```
Some FAQ:


1. How do I tag the VM?    

You need to add a label where the name is *googlebackupplan* and the value is the name of a valid template, in this example it is *snap*
```
googlebackupplan : snap
```
2. What if I want to use my own own label?   

You can do that and then specify it with **-usertag**.   So lets say you add a label to each relevant VM where the label name is *corporatepolicy* and the value is a valid template name, then when you run the command, add **-usertag "corporatepolicy"**

The whole command would look like:
```
New-AGMLibGCEInstanceDiscovery -discoveryfile ./disco.csv -backup -usertag "corporatepolicy"
```
3. How do I learn the names of the templates to use as values for the tags?    

You can either look at Templates in the SLA Architect in AGM or run: **Get-AGMSLT**

4. What if I don't want all instances to be added to AGM   

This function has to add them all to ensure each instance is examined.   If you add them to AGM and then delete them from AGM, they won't be added back in a second run because an Actifio label with a value of **unmanaged** will be added to them.



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
$images = Get-AGMImage -filtervalue appid=35590 | select backupname
$images

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

foreach ($image in $images)
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
$images = Get-AGMImage -filtervalue appid=35590 | select backupname,expiration
$images

backupname    expiration
----------    ----------
Image_0267271 2021-09-18 19:02:27
Image_0266247 2021-09-17 11:03:09
Image_0265223 2021-09-16 10:07:43
```
We then change them all to a date prior to today and confirm they changed:
```
foreach ($image in $images) { Set-AGMImage -imagename $image.backupname -expiration "2021-09-14" }

xml                            backupRest
---                            ----------
version="1.0" encoding="UTF-8" backupRest
version="1.0" encoding="UTF-8" backupRest
version="1.0" encoding="UTF-8" backupRest

$images = Get-AGMImage -filtervalue appid=35590 | select backupname,expiration
$images

backupname    expiration
----------    ----------
Image_0267271 2021-09-14 00:00:00
Image_0266247 2021-09-14 00:00:00
Image_0265223 2021-09-14 00:00:00
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
New-AGMLibImage -appid 409016 -label "tinyrun1"
Running this command: New-AGMLibImage  -appid 409016 -policyid 425081 -label tinyrun1
```
Now we search for a job with that label:
```
Get-AGMJobStatus -filtervalue "label=tinyrun1" | select jobname,status,progress,startdate

jobname     status    progress startdate
-------     ------    -------- ---------
Job_0185433 running          7 2022-11-11 09:18:44
```
But the label has to be unique or you can end up in situation like this where we run a second job with the previously used label:
```
New-AGMLibImage -appid 409016 -label "tinyrun1"
Running this command: New-AGMLibImage  -appid 409016 -policyid 425081 -label tinyrun1
```
First we find the old job (because the new job has not started yet):
```
Get-AGMJobStatus -filtervalue "label=tinyrun1" | select jobname,status,progress,startdate

jobname     status    progress startdate
-------     ------    -------- ---------
Job_0185433 succeeded          2022-11-11 09:18:44
```
Now we find the old job and the new job:
```
Get-AGMJobStatus -filtervalue "label=tinyrun1" | select jobname,status,progress,startdate

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
Start-AGMLibPolicy -policyid 6393 -backuptype dblog
Starting job for hostname: mysqlsource   appname: mysqlsource   appid: 51919 using: snap policyID: 6393 from SLTName: PDSnaps
Starting job for hostname: mysqltarget   appname: mysqltarget   appid: 36104 using: snap policyID: 6393 from SLTName: PDSnaps
Starting job for hostname: tiny   appname: tiny   appid: 35590 using: snap policyID: 6393 from SLTName: PDSnaps

```
We can then monitor the jobs like this:
```
Get-AGMJob -filtervalue "policyname=OndemandOV" | select status,progress

status  progress
------  --------
running       97
running       98
```
Your logic would work like this:
1. Count the relevant apps.  In this example we have 2.
```
$appgrab = Get-AGMApplication -filtervalue "sltname=FSSnaps_RW_OV"
$appgrab.count
2
```
2. Count the current images.  We currently have 6 OnVault images.
```
$imagegrab = Get-AGMImage -filtervalue "sltname=FSSnaps_RW_OV&jobclass=OnVault"
$imagegrab.count
6
```
3. Run a new OnVault job.  We get two jobs started.
```
Start-AGMLibPolicy -policyid 25627
Starting job for appid 20577 using cloud policy ID 25627 from SLT FSSnaps_RW_OV
Starting job for appid 6965 using cloud policy ID 25627 from SLT FSSnaps_RW_OV
```
4.  Scan for running jobs until they all finish
```
Get-AGMJob -filtervalue "policyname=OndemandOV" | select status,progress

status             progress
------             --------
queued                    0
queued (readiness)        0

Get-AGMJob -filtervalue "policyname=OndemandOV" | select status,progress

status  progress
------  --------
running        2
running        2

Get-AGMJob -filtervalue "policyname=OndemandOV" | select status,progress

status    progress
------    --------
running         98
succeeded      100

Get-AGMJob -filtervalue "policyname=OndemandOV" | select status,progress

status progress
------ --------




```
5. Count the images and ensure they went up by the number of apps.   Note that if expiration run at this time, this will confuse the issue.
You can see here we went from 6 to 8.
```
$imagegrab = Get-AGMImage -filtervalue "sltname=FSSnaps_RW_OV&jobclass=OnVault"
$imagegrab.count
8

```

## Image Import from OnVault

Prior to running your scripts you may want to import the latest OnVault images into your appliance.  To learn the syntax, just run the command without any options.   It will run guided mode.  We can also learn everything we need, step by step as shown below.

In general we just run the command with two parameters like this.
```
Import-AGMLibOnVault -diskpoolid 20060633 -applianceid 1415019931 
```
Learn Diskpool ID with this command.  The appliance named here is the appliance we are importing into.  So its not the source appliance, but the target appliance that is going to use the imported images:
```
Import-AGMLibOnVault -listdiskpools
```
Now take the diskpool ID to learn the appliance ID.  This is the appliance ID of the appliance that made the images:
```
Import-AGMLibOnVault -diskpoolid 199085 -listapplianceids
```
If you want to import a specific application, learn the application ID with this command.  Note the backupcount is the number of images in the pool, not how many will be imported (which could be less):
```
Import-AGMLibOnVault -diskpoolid 199085 -applianceid 1415019931 -listapps
```
Then use the appid you learned to import: 
```
 Import-AGMLibOnVault -diskpoolid 199085 -applianceid 1415019931 -appid 4788
```
Or just import every image in that disk pool:
```
 Import-AGMLibOnVault -diskpoolid 199085 -applianceid 1415019931
```
If you want to monitor the import, add **-monitor** to the command:
```
Import-AGMLibOnVault -diskpoolid 199085 -applianceid 1415019931 -monitor
```
Note you can also add **-forget** to forget learned images, or **-owner** to take ownership of those images.

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

# Mount

## Multi Mount for Ransomware Analysis

There are many cases where you may want to mount many filesystems in one hit.  A simple scenario is ransomware, where you are trying to find an uninfected or as yet unattacked (but infected) image for each production filesystem.   So lets mount as many images as we can as quickly as we can so we can find unaffected filesystems and start the recovery.

There is a composite function that is designed to help you find all the commands.   You can start this by running:  
```
Start-AGMLibRansomwareRecovery
```

### Stopping the Scheduler and/or expiration 

Prior to beginning recovery efforts you may want to stop the scheduler and expiration on large numbers of Apps or even your whole environment.
If you created Logical Groups this is one convenient way to manage this.   
There are two commands you can use:

* Get-AGMLibSLA      This command will list the Scheduler and Expiration status for all your apps, or if you use -appid or -slaid, for a specific app
* Set-AGMLibSLA      This command will let you set the scheduler or Expiration status for all your apps, specific apps or specific Logical Groups.

#### Building a list of images
First we build an object that contains a list of images.  For this we can use **Get-AGMLibImageRange** in a syntax like this, where in this example we get all images of filesystems created in the last day:
```
$imagelist = Get-AGMLibImageRange -apptype FileSystem -appliancename sa-sky -olderlimit 1
```
If we know that images created in the last 24 hours are all infected, we could use this (up to 3 days old but not less than 1 day old):
```
$imagelist = Get-AGMLibImageRange -apptype FileSystem -appliancename sa-sky -olderlimit 3 -newerlimit 1
```
We can also use the Template Name (SLT) to find our apps.  This is a handy way to separate apps since you can create as many SLTs as you like and use them as a unique way to group apps.
```
$imagelist = Get-AGMLibImageRange -sltname FSSnaps_RW_OV -olderlimit 3 -newerlimit 1
```

#### Editing your $Imagelist 

You could create a CSV of images, edit it and then convert that into an object.  This would let you delete all the images you don't want to recover, or create chunks to recover (say 20 images at a time)

In this example we grab 20 days of images:

```
Get-AGMLibImageRange -apptype FileSystem -appliancename sa-sky -olderlimit 20 | Export-Csv -Path .\images.csv
```

We now edit the CSV  we created **images.csv** to remove images we don't want.   We then import what is left into our $imagelist variable:
```
$imagelist = Import-Csv -Path .\images.csv
```
Now we have our image list, we can begin to create our recovery command.

#### Define our scanning host list
 
We need to define a single host to use as our mount target or an array of hosts.

```
Get-AGMHost -filtervalue "hostname~mysql" | select id,hostname

id   hostname
--   --------
7376 mysqltarget
6915 mysqlsource

$hostlist = @(7376,6915)
```
We could also define a specific host like this:
```
$hostid = 7376
```
#### Run our multi-mount command

We can now fire our new command using the settings we defined and our image list:
```
New-AGMLibMultiMount -imagelist $imagelist -hostlist $hostlist -mountpoint /tmp/
```
For uniqueness we have quite a few choices to generate mounts with useful names.   A numeric indicator will always be added to each mountpoint as a suffix.  Optionally we can use any of the following.   They will be added in the order they are listed here:

* -h or hostnamesuffix   :  which will add the host name of the image to the mountpoint
* -a or -appnamesuffix   :  which will add the appname of the image to the mountpoint
* -i  or -imagesuffix    :  which will add the image name of the image to the mountpoint
* -c or -condatesuffix   :  which will add the consistency date of the image to the mountpoint


This will mount all the images in the list and round robin through the host list.

If you don't specify a label, all the image will get the label **MultiFS Recovery**   This will let you easily spot your mounts by doing this:
```
$mountlist = Get-AGMLibActiveImage | where-object  {$_.label -eq "MultiFS Recovery"}
```
When you are ready to unmount them, run this script:
```
foreach ($mount in $mountlist.imagename)
{
Remove-AGMMount $mount -d
}
```
#### Updating Labels
We can use the following command to update the Label of a specific image:
```
Set-AGMImage
```
However we could update a large number of images with this command:
```
Set-AGMLibImage
```
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
$org = Get-AGMOrg -orgid 526553
$org.resourcecollection

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
$org = Get-AGMOrg -orgid 526553
$org.resourcecollection.hostlist
442009
449560
```

# SAP HANA

# SAP HANA Mount

In this 'story' a user wants to mount a HANA database from the latest snapshot of a HANA Instance (HDB) to a host. Most aspects of the story are the same as above, however they need some more information to run their mount command. They learn the App ID of the HANA database where ```act``` is the name of the HANA database.
```
Get-AGMLibApplicationID act |ft

id     friendlytype hostname   hostid appname appliancename applianceip applianceid  appliancetype managed
--     ------------ --------   ------ ------- ------------- ----------- -----------  ------------- -------
577110 SAPHANA      coe-hana-1 577093 act     sky1          10.60.1.7   141767697828 Sky              True
```
So now we know the id of the Database inside our HANA instance, we just need to specify the HANA user store key (userstorekey) that has rights to recover the database on the target host (targethostname), a new database SID (dbsid) to use, and lastly to specify a target host filesystem mount point (mountpointperimage) for the HANA instance to run from. We then run our mount command like this:

```
New-AGMLibSAPHANAMount -appid 577110 -targethostname coe-hana-2 -dbsid "TGT" -userstorekey "ACTBACKUP" -mountpointperimage "/tgt" -label "Test HANA database"
```
If you run ```New-AGMLibSAPHANAMount``` in guided mode, you can take the option to generate a CSV file.   This can be used to run New-AGMLibSAPHANAMultiMount

## User Story: SAP HANA Database Multi Mount

You can run ```New-AGMLibSAPHANAMount``` in guided mode and take the option to generate a CSV file.     You can then edit it to mount multiple new SAP HANA instances at once.   A sample file would look like this:
```
appid,appname,mountapplianceid,imagename,targethostid,dbsid,userstorekey,mountpointperimage,label,recoverypoint,mountmode,mapdiskstoallesxhosts,sltid,slpid
835132,"act","144091747698","Image_0160795","749871","act","actbackup","/mount","label1","2022-11-07 17:00:39","nfs","false","108758","706611"
```
The following fields are mandatory:
* ```appname```   the appname field is used to ensure you know which instances you are looking at.   Of course if all your SAP HANA instances are called  ```act``` this still might not help.
* ```mountapplianceid```  this is the id of the appliance that will run the mount.  You can learn this with ```Get-AGMAppliance```
* ```targethostid``` this is the ID of the host we are mounting to.   You can learn this with ```Get-AGMHost```
* ```dbsid```  this is the new DB SID we are creating 
* ```userstorekey```  this is the stored credential the agent will use to authorize its host side activities
* ```mountpointperimage```  this is the mount point where the mount will be placed

The following fields are optional:
* ```appid```  If the appnames are all unique, we don't need appid.  If you are working on an imported image, the source appid may not be useful.  Learn this with ```Get-AGMApplication```
* ```label```  the label is handy as it lets us leave comments about this mount, but it is not mandatory
* ```recoverypoint```  the recoverypoint is only useful if there are logs to roll forward.  You don't have to specify it.   For a mount we don't roll forward logs
* ```mountmode``` VMware only (are we using NFS, vRDM or pRDM)
* ```mapdiskstoallesxhosts```  VMware only (are we mapping to all ESXi hosts)
* ```sltid```  template ID if re-protection is requested. Learn this with ```Get-AGMSLT```
* ```slpid```  profile ID if re-protection is requested. Learn this with ```Get-AGMSLP```

# SQL Server

## SQL Server Mount

In this 'story' a user wants to mount the latest snapshot of a SQL DB to a host

The user finds the appID for the source DB

```
Get-AGMLibApplicationID smalldb

id      friendlytype hostname appname appliancename applianceip  appliancetype managed
--      ------------ -------- ------- ------------- -----------  ------------- -------
5552336 SQLServer    hq-sql   smalldb sa-sky        172.24.1.180 Sky              True
261762  Oracle       oracle   smalldb sa-sky        172.24.1.180 Sky              True
```

The user validates the name of the target host:

```
Get-AGMLibHostID demo-sql-4

id       hostname   osrelease                                    appliancename applianceip  appliancetype
--       --------   ---------                                    ------------- -----------  -------------
43673548 demo-sql-4 Microsoft Windows Server 2019 (version 1809) sa-sky        172.24.1.180 Sky
```

The user validates the SQL instance name on the target host.  Because the user isn't sure about naming of the hostname  they used '~' to get a fuzzy search.  Because they couldn't remember the exact apptype for SQL instance, they again just used a fuzzy search for 'instance':

```
Get-AGMApplication -filtervalue "hostname~demo-sql-4&apptype~instance" | select pathname

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
New-AGMLibMSSQLMount -appid 5552336 -mountapplianceid 1415071155 -targethostname demo-sql-4 -label "test and dev made easy" -sqlinstance DEMO-SQL-4 -dbname avtest

```

The user finds the running job:

```
Get-AGMLibRunningJobs

jobname      jobclass   apptype         hostname                    appname               appid    appliancename startdate           progress targethost
-------      --------   -------         --------                    -------               -----    ------------- ---------           -------- ----------
Job_24358189 mount      SqlServerWriter hq-sql                      smalldb               5552336  sa-sky        2020-06-24 14:50:08       53 demo-sql-4
```

The user tracks the job to success:

```
Get-AGMLibFollowJobStatus Job_24358189

jobname      status  progress queuedate           startdate           duration
-------      ------  -------- ---------           ---------           --------
Job_24358189 running       95 2020-06-24 14:49:33 2020-06-24 14:50:08 00:01:30


jobname      status    message startdate           enddate duration
-------      ------    ------- ---------           ------- --------
Job_24358189 succeeded         2020-06-24 14:50:08         00:01:36
```

The user validates the mount exists:

```
Get-AGMLibActiveImage

imagename      apptype         hostname        appname appid    mountedhostname childappname appliancename consumedsize label
---------      -------         --------        ------- -----    --------------- ------------ ------------- ------------ -----
Image_24358189 SqlServerWriter hq-sql          smalldb 5552336  demo-sql-4      avtest       sa-sky                   0 test and dev made easy
```

The user works with the DB until it is no longer needed.

The user then un-mounts the DB, specifying -d to delete the mount:

```
Remove-AGMMount Image_24358189 -d
```

The user confirms if the mount created a child app
```
Get-AGMLibApplicationID avtest

id       friendlytype hostname   appname appliancename applianceip  appliancetype managed
--       ------------ --------   ------- ------------- -----------  ------------- -------
52410625 SQLServer    demo-sql-4 avtest  sa-sky        172.24.1.180 Sky             False
```

The user deletes the child app:
```
Remove-AGMApplication 52410625
```
### Finding Images if the application is orphaned

Presuming we know the name of our orphan app and the host it once lived on.  Choose the backupname of the image you want by searching for the appname:

```
get-agmimage -filtervalue appname=avdb1 | select id,host,consistencydate,backupname,jobclass | ft *

id      host                   consistencydate     backupname     jobclass
--      ----                   ---------------     ----------     --------
7397674 @{hostname=sydwinsql5} 2020-10-30 13:55:26 Image_10979893 snapshot
7397570 @{hostname=sydwinsql5} 2020-10-30 13:54:16 Image_10979874 snapshot
```

## SQL Server Mount and Migrate

In this user story we are going to use SQL Mount and Migrate to move an Actifio Mount back to server disk

### Create the mount

First we create the mount.  In this example we ran **New-AGMLibMSSQLMount** to build a command.
The final command looks like this:
```
New-AGMLibMSSQLMount -appid 884945 -mountapplianceid 1415071155 -label "test1" -targethostid 655169 -sqlinstance "SYDWINSQL5" -dbname "avtest77"
```

Rather than learn the image ID, we can store the appid and mount appliance ID and then let AGM find the latest snapshot:
```
-appid 884945 -mountapplianceid 1415071155
```
We set a label.  This is optional but a very good idea on every mount:
```
-label "test1"
```
We set the target host ID and target SQL instance on that host:
```
-targethostid 655169 -sqlinstance "SYDWINSQL5"
```
We set the DB name for the mounted DB.
```
-dbname "avtest77"
```

### Check the mount
Once the mount has been created, we are ready to start the migrate.   We can check our mount with:  **Get-AGMLibActiveImage**

### Start the migrate

We run **New-AGMLibMSSQLMigrate** to build our migrate command.   The final command looks like this:

```
New-AGMLibMSSQLMigrate -imageid 6859821 -files -restorelist "SQL_smalldb.mdf,D:\Data,d:\avtest1;SQL_smalldb_log.ldf,E:\Logs,e:\avtest1"
```
To break down this command:
* This starts a migrate with default copy thread of 4 and default frequency set to 24 hours for ImageID 6859821.   We could have set thread count and frequency with syntax like:  **-copythreadcount 2 -frequency 2**
* Files will be renamed to match the new database name because we didn't specify:  **-dontrenamedatabasefiles**
* Because **-files** was specified, the **-restorelist** must contain the file name, the source location and the targetlocation.
* Each file is separated by a semicolon,  the three fields for each file are comma separated.
* In this example, the file **SQL_smalldb.mdf** found in **D:\Data** will be migrated to **d:\avtest1**
* In this example, the file **SQL_smalldb_log** found in **E:\Logs** will be migrated to **e:\avtest1**
* The order of the fields must be **filename,sourcefolder,targetfolder** so for two files **filename1,source1,target1;filename2,source2,target2**

We could have specified volume migration rather than file migration, or we could have not specified either and let the files go back to their original locations (provided those locations exist).

### Change migrate settings

To change migrate settings we can run:  **Set-AGMLibMSSQLMigrate** and follow the prompts.  Or we can use syntax like this:
```
Set-AGMLibMSSQLMigrate -imageid 6860452 -copythreadcount 2 -frequency 2
```
This syntax sets the copy threads to 2 and the frequency to 2 hours for Image ID 6860452.   You can learn the image ID with **Get-AGMLibActiveImage -i** or **Set-AGMLibMSSQLMigrate**
This command is the same as using *Update Migration Frequency* in the Active Mounts panel of AGM.
You can check the migration settings with a command like this:
```
Get-AGMImage -id 6859821 | select-object migrate-frequency,migrate-copythreadcount,migrate-configured

migrate-frequency migrate-copythreadcount migrate-configured
----------------- ----------------------- ------------------
               24                       4               True
```

### Cancel the migrate 

If we decide to cancel the migrate we can run this command:
```
Remove-AGMMigrate -imageid 6860452
```
You can learn the image ID with **Get-AGMLibActiveImage -i** or **Set-AGMLibMSSQLMigrate**
This command is the same as using *Cancel Migration* in the Active Mounts panel of AGM.

### Run an on-demand migration job

The frequency you set will determine how often migrate jobs are run.   You can run on-demand migrations with:
```
Start-AGMMigrate -imageid 56072427 
```
This runs a migration job for Image ID 56072427.  You can learn the image ID with **Get-AGMLibActiveImage -i** or **Set-AGMLibMSSQLMigrate**
This command is the same as using *Run Migration Job Now* in the Active Mounts panel of AGM.

You can monitor this job with this command.  We need to know the App ID of the source application.  It will show both running and completed jobs
```
/Users/anthonyv/Documents/github/AGMPowerLib> get-agmjobstatus -filtervalue "jobclass=Migrate&appid=884945" | select-object status,startdate,enddate | sort-object startdate

status    startdate           enddate
------    ---------           -------
succeeded 2020-10-09 14:41:55 2020-10-09 14:42:15
succeeded 2020-10-09 14:51:58 2020-10-09 14:52:19
running   2020-10-09 14:54:55
```

### Run a finalize job
When you are ready to switch over, we need to run a finalize with this job:    
```
Start-AGMMigrate -imageid 56072427 -finalize
```
This command runs a Finalize job for Image ID 56072427. You can learn the image ID with **Get-AGMLibActiveImage -i** or **Set-AGMLibMSSQLMigrate**
This command is the same as using *Finalize Migration* in the Active Mounts panel of AGM.

You can monitor this job with this command.  We need to know the App ID of the source application.  It will show both running and completed jobs
```
/Users/anthonyv/Documents/github/AGMPowerLib> get-agmjobstatus -filtervalue "jobclass=Finalize&appid=884945" | select-object status,startdate,enddate | sort-object startdate

status    startdate           enddate
------    ---------           -------
succeeded 2020-10-09 15:02:15 2020-10-09 15:04:06
```

## SQL Server Multi Mount and Migrate

In this user story we are going to use SQL Mount and Migrate to move an Actifio Mount back to server disk but we are going to run multiple mounts and migrates in a single pass using a CSV file

This video also documents the process:   https://youtu.be/QX5Sn3XHbCM

### Create the CSV sourcefile

The easiest way to create the CSV file is to run **New-AGMLibMSSQLMount** and take the option to output a CSV file at the end.

Once you have the file then edit it to add additional databases.  
* If you don't know the App ID, then specify the AppName (provided it is unique)
* If you don't know the target host ID, then specify the expected TaregtHostName (provided it is unique)
* If the target host doesn't exist, but you know what the target instance name will be, then make sure to specify **true** in the discovery column

Here is an example of a file:
```
appid,appname,imagename,imageid,mountapplianceid,targethostid,targethostname,sqlinstance,recoverypoint,recoverymodel,overwrite,label,dbname,consistencygroupname,dbnamelist,dbrenamelist,dbnameprefix,dbnamesuffix,recoverdb,userlogins,username,password,base64password,mountmode,mapdiskstoallesxhosts,mountpointperimage,sltid,slpid,discovery,perfoption,migrate,copythreadcount,frequency,dontrenamedatabasefiles,volumes,files,restorelist
,WINDOWS\SQLEXPRESS,,,143112195179,,win-target,WIN-TARGET\SQLEXPRESS,,Same as source,no,sqlinst1,,avcg1,,"model,model1;CRM,crm1",,,TRUE,FALSE,,,,,,,,,,,yes,4,1,,,,
```

### Create the CSV runfile

Where the source file needs to exist before you start,  the runfile will be created the first time you run **New-AGMLibMSSQLMulti** by specifying the name of a new file that doesnt yet exist.
The idea is that you will use this file throughout one DR or test event.   Once all databases are finalized then you can delete the runfile and start your next test using a a new file

If you want to use the latest point in time image, leave imagename and imageid columns empty.   If you want the image rolled forward to the latest log point in time, just enter **latest** in the recoverypoint column.

### Checking image state
At any point in the process, we use **-checkimagestate** to validate whether our mounts exist.  
```
New-AGMLibMSSQLMulti -sourcefile recoverylist.csv  -runfile rundate22052022.csv -checkimagestate
```
The first time you run this command, the output will look like this:
```
id                 :
appname            : WINDOWS\SQLEXPRESS
targethostname     : win-target
childapptype       : ConsistencyGroup
childappname       : avcg1
label              : sqlinst1
previousimagestate :
currentimagestate  : NoMountedImage
```
* id is blank because there is no image yet created by a mount
* previousimagestate is blank because there is no image
* currentimagestate says NoMountedImage because there is no image

### Running the multi mount.
We start all the mounts at once with this command:
```
New-AGMLibMSSQLMulti -sourcefile recoverylist.csv  -runfile rundate22052022.csv -runmount
```
This will run multiple New-AGMLibMSSQLMount jobs.  If run twice, any collisions with existing mounts will not run. 
This means if a mount fails, after you resolve the cause of the issue you can just run the same command again without interfering with existing mounts.
After you run **New-AGMLibMSSQLMulti**  with **-runmount** then check the state with **-checkimagestate**

We expect it to initially show this, where id is still blank, but previousimagestate is telling you a mount was started.
```
id                 :
appname            : WINDOWS\SQLEXPRESS
targethostname     : win-target
childapptype       : ConsistencyGroup
childappname       : avcg1
label              : sqlinst1
previousimagestate : MountStarted
currentimagestate  : NoMountedImage
```
Once the mount job completes we will see this, where the ID is now known and currentimagestate is mounted.
```
id                 : 82789
appname            : WINDOWS\SQLEXPRESS
targethostname     : win-target
childapptype       : ConsistencyGroup
childappname       : avcg1
label              : sqlinst1
previousimagestate : MountStarted
currentimagestate  : Mounted
```
If you run the **-runmount** again, the existing mounts will be unaffected, but previousimagestate will change to: *MountFailed: mount is unsuccessful due to duplicate application on the same host/instance not allowed:*

### Starting the migration
Once all our images are mounted, we can start migrating.   If you run this command with some mounts still running, then migration will only start on those mounts that are ready and you will need to run startmigration again.
```
New-AGMLibMSSQLMulti -sourcefile recoverylist.csv -runfile rundate22052022.csv -startmigration
```
This will start migrate jobs for any SQL Db where the migrate field is set to true.
When you check after migrate has been requested you will see this, where previousimagestate and currentimagestate both say MigrateStarted:
```
id                 : 82789
appname            : WINDOWS\SQLEXPRESS
targethostname     : win-target
childapptype       : ConsistencyGroup
childappname       : avcg1
label              : sqlinst1
previousimagestate : MigrateStarted
currentimagestate  : MigrateStarted
```
Once the first migrate job has finished we will see this where currentimagestate is FinalizeEligible
```
id                 : 82789
appname            : WINDOWS\SQLEXPRESS
targethostname     : win-target
childapptype       : ConsistencyGroup
childappname       : avcg1
label              : sqlinst1
previousimagestate : MigrateStarted
currentimagestate  : FinalizeEligible
```
We can run additional migrate jobs (in addition to the scheduled ones), with this command:
```
New-AGMLibMSSQLMulti -sourcefile recoverylist.csv -runfile rundate22052022.csv -runmigration
```
If you use -runmigration without having first run -startmigration then nothing will happen.

### Starting the finalize
This last option may not be desirable in all cases.  A finalize is disruptive while the switch is made.   You may wish to run this last step one by one using the GUI.  Note if you need multiple finalize jobs per host, you need to run them one at a time.   This might mean running **-finalizemigration** multiple times.
```
New-AGMLibMSSQLMulti -sourcefile recoverylist.csv -runfile rundate22052022.csv -finalizemigration
```
After running the command you will initially see this, where previousimagestate is FinalizeStarted.
```
id                 : 82789
appname            : WINDOWS\SQLEXPRESS
targethostname     : win-target
childapptype       : ConsistencyGroup
childappname       : avcg1
label              : sqlinst1
previousimagestate : FinalizeStarted
currentimagestate  : FinalizeEligible
```
Once finalize is finished you will see this, where currentimagestate is ImageNotFound.  This is normal because at the end of the finalize the mount gets deleted.    Once you see this, validate the DB on the target host and you are complete.
```
id                 : 82789
appname            : WINDOWS\SQLEXPRESS
targethostname     : win-target
childapptype       : ConsistencyGroup
childappname       : avcg1
label              : sqlinst1
previousimagestate : FinalizeStarted
currentimagestate  : ImageNotFound
```




## SQL Server mount with point in time recovery

In this 'story' a user wants to mount a specific snapshot of a SQL DB to a host rolled to a specific point in time.   We start with an appname:

The user finds the appID for the source DB

```
Get-AGMLibApplicationID smalldb

id      friendlytype hostname appname appliancename applianceip  appliancetype managed
--      ------------ -------- ------- ------------- -----------  ------------- -------
5552336 SQLServer    hq-sql   smalldb sa-sky        172.24.1.180 Sky              True
261762  Oracle       oracle   smalldb sa-sky        172.24.1.180 Sky              True

```
We now get a list of images:

```
Get-AGMLibImageDetails 5552336

backupname            jobclass     consistencydate     endpit
----------            --------     ---------------     ------
Image_24351142        snapshot     2020-06-24 11:55:37 2020-06-25 15:07:16
Image_24386274        snapshot     2020-06-25 11:46:22 2020-06-25 15:07:16
```
We have two snapshots and logs as well.

The user runs a mount command specifying the source appid, target host and SQL Instance and DB name on the target as well as a recovery point in ISO 860 format and image name.  However they specify the wrong date, one earlier than the consistency point:

```
New-AGMLibMSSQLMount -imagename Image_24351142 -appid 5552336 -targethostname demo-sql-4 -label "test and dev made easy" -sqlinstance DEMO-SQL-4 -dbname avtest -recoverypoint "2020-06-23 16:00"

errormessage
------------
Specified recovery point 2020-06-23 16:00 is earlier than image consistency date 2020-06-24 11:55:37.  Specify an earlier image.

```
They fix the date and successfully run the command:
```
New-AGMLibMSSQLMount -imagename Image_24351142 -appid 5552336 -targethostname demo-sql-4 -label "test and dev made easy" -sqlinstance DEMO-SQL-4 -dbname avtest -recoverypoint "2020-06-24 16:00"
```

## SQL Server Instance mount

In this 'story' a user wants to mount two databases from the latest snapshot of a SQL Instance to a host.  Most aspects of the story are the same as above, however they need some more information to run their mount command.   They learn the App ID of the SQL Instance:

```
Get-AGMLibApplicationID  HQ-SQL

id      friendlytype hostname appname appliancename applianceip  appliancetype managed
--      ------------ -------- ------- ------------- -----------  ------------- -------
5534398 SqlInstance  hq-sql   HQ-SQL  sa-sky        172.24.1.180 Sky              True
```

We now learn the instance members:
```
Get-AGMApplicationInstanceMember 5534398

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
Get-AGMApplicationInstanceMember 5534398 | Select-Object -ExpandProperty eligiblelist | ft

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
 New-AGMLibMSSQLMount -appid 5534398 -targethostname demo-sql-5 -label "AV instance mount" -sqlinstance DEMO-SQL-5 -consistencygroupname avcg -dbnamelist "smalldb1,smalldb2" -dbnameprefix "testdev_" -dbnamesuffix "_av"
```

## SQL Server protecting and rewinding child apps

In this story, we create a child app of a SQL DB that is protected by an on-demand template.

First we create the child app.   There are several things about this command.   Firstly it does not specify an image ID, it will just use the latest snapshot.   It specifies the SLTID and SLPID to manage the child app.  This command was generated by running **New-AGMLibMSSQLMount** in guided mode.  
```
New-AGMLibMSSQLMount -appid 884945 -mountapplianceid 1415071155  -label "avtest" -targethostid 655169 -sqlinstance "SYDWINSQL5" -dbname "avtestrp10" -sltid 6318469 -slpid 655697
```
We validate the child app was created:
```
Get-AGMLibApplicationID avtestrp10

id            : 6403028
friendlytype  : SQLServer
hostname      : sydwinsql5
appname       : avtestrp10
appliancename : sydactsky1
applianceip   : 10.65.5.35
appliancetype : Sky
managed       : True
slaid         : 6403030
```
We run an on-demand snapshot of the child app (the mount) when we are ready to make that first bookmark:
```
New-AGMLibImage -appid 6403028

jobname     status  queuedate           startdate
-------     ------  ---------           ---------
Job_9900142 running 2020-09-04 17:00:41 2020-09-04 17:00:41
```
The image is created quickly:
```
Get-AGMLibLatestImage 6403028

appliance       : sydactsky1
hostname        : sydwinsql5
appname         : avtestrp10
appid           : 6403028
jobclass        : snapshot
backupname      : Image_9900142
id              : 6403125
consistencydate : 2020-09-04 17:01:06
endpit          :
sltname         : bookmarkOnDemand
slpname         : Local Only
policyname      : SnapOnDemand
```
We can now continue to use our development child-app in the knowledge we can re-wind to a known good point.    

If we need to re-wind, we simply run the following command, referencing the image ID:
```
Restore-AGMLibMount -imageid 6403125
```
We learn the jobname with this command:
```
Get-AGMLibRunningJobs | ft *
```
We then monitor the job, it runs quickly as its a rewind
```
Get-AGMLibFollowJobStatus Job_9900239

jobname   : Job_9900239
status    : succeeded
message   : Success
startdate : 2020-09-04 17:03:47
enddate   : 2020-09-04 17:05:08
duration  : 00:01:20
```
We can then continue to work with our child app, creating new snapshots or even new child apps using those snapshots.

# VMware

# VMware Multi Mount

There are many cases where you may want to mount many VMs in one hit.  A simple scenario is ransomware, where you are trying to find an uninfected or as yet unattacked (but infected) image for each production VM.   So lets mount as many images as we can as quickly as we can so we can find unaffected VMs and start the recovery.

There is a composite function that is designed to help you find all the commands.   You can start this by running:  
```
Start-AGMLibRansomwareRecovery
```


### Building a list of images
First we build an object that contains a list of images.  For this we can use Get-AGMLibImageRange in a syntax like this:
```
$imagelist = Get-AGMLibImageRange
```
In this example we get all images of VMs created in the last day:
```
$imagelist = Get-AGMLibImageRange -apptype VMBackup -appliancename sa-sky -olderlimit 1
```
If we know that images created in the last 24 hours are all infected, we could use this (up to 3 days old but not less than 1 day old):
```
$imagelist = Get-AGMLibImageRange -apptype VMBackup -appliancename sa-sky -olderlimit 3 -newerlimit 1
```
We can also use the Template Name (SLT) to find our apps.  This is a handy way to separate apps since you can create as many SLTs as you like and use them as a unique way to group apps.
```
$imagelist = Get-AGMLibImageRange -sltname FSSnaps_RW_OV
```

### Editing your $Imagelist 

You could create a CSV of images, edit it and then convert that into an object.  This would let you delete all the images you don't want to recover, or create chunks to recover (say 20 images at a time)

In this example we grab 20 days of images:

```
Get-AGMLibImageRange -apptype VMBackup -appliancename sa-sky -olderlimit 20 | Export-Csv -Path .\images.csv
```

We now edit the CSV  we created **images.csv** to remove images we don't want.   We then import what is left into our $imagelist variable:
```
$imagelist = Import-Csv -Path .\images.csv
```
Now we have our image list, we can begin to create our recovery command.

### Define our VMware environment 
 
First we learn our vcenter host ID and set id:
```
Get-AGMHost -filtervalue "isvcenterhost=true" | select id,hostname,srcid

id      hostname                  srcid
--      --------                  -----
5552172 scvmm.sa.actifio.com      4661
5552150 hq-vcenter.sa.actifio.com 4460
5534713 vcenter-dr.sa.actifio.com 4371

$vcenterid = 5552150
```
Now learn your ESXHost IDs and make a simple array.  We need to choose ESX hosts thatr have datastores in common, because we are going to round robin across the ESX hosts and datastores.
```
Get-AGMHost -filtervalue "isesxhost=true&vcenterhostid=4460" | select id,hostname

id       hostname
--       --------
26534616 sa-esx8.sa.actifio.com
5552168  sa-esx6.sa.actifio.com
5552166  sa-esx5.sa.actifio.com
5552164  sa-esx1.sa.actifio.com
5552162  sa-esx2.sa.actifio.com
5552160  sa-esx4.sa.actifio.com
5552158  sa-esx7.sa.actifio.com

$esxhostlist = @(5552166,5552168)
$esxhostlist
5552166
5552168
```
Now make an array of datastores:
```
$datastorelist = ((Get-AGMHost -id 5552166).sources.datastorelist | select-object name,freespace | sort-object name | Get-Unique -asstring | select name).name

$datastorelist
IBM-FC-V3700
Pure
```

### Run our multi-mount command

We can now fire our new command using the VMware settings we defined and our image list:
```
New-AGMLibMultiVM -imagelist $imagelist -vcenterid $vcenterid -esxhostlist $esxhostlist -datastorelist 
```
For uniqueness we have quite a few choices to generate VMs with useful names.   If you do nothing, then a numeric indicator will be added to each VM as a suffix.  Otherwise we can use:

* -prefix xxxx           :   where xxxx is a prefix
* -suffix yyyy           :   where yyyy is a suffix
* -c or -condatesuffix   :  which will add the consistency date of the image as a suffix
* -i  or -imagesuffix    :  which will add the image name of the image as a suffix

This will mount all the images in the list and round robin through the ESX host list and data store list.

If you don't specify a label, all the VMs will get the label **MultiVM Recovery**   This will let you easily spot your mounts by doing this:
```
$mountlist = Get-AGMLibActiveImage | where-object  {$_.label -eq "MultiVM Recovery"}
```
When you are ready to unmount them, run this script:
```
foreach ($mount in $mountlist.imagename)
{
Remove-AGMMount $mount -d
}
```

#### esxhostid vs esxhostlist

You can just specify one esxhost ID with -esxhostid.   If you are using NFS datastore and you will let DRS rebalance later, this can make things much faster

#### datastore vs datastorelist

You can also specify a single datastore rather than a list.



# Workflows

## Running a Workflow

Note there is no function to create Workflows, so continue to use the GUI for this.   
There are two functions for workflows:

* Get-AGMLibWorkflowStatus
* Start-AGMLibWorkflow 

For both commands, you don't need any details, just run the command and a wizard will run.   You can use this to learn things like workflow IDs and App IDs so that you can then use these commands as part of automation.

We can start a workflow with a command like this:
```
Start-AGMLibWorkflow -workflowid 9932352
```
We can then run a refresh of this workflow with this command:
```
Start-AGMLibWorkflow -workflowid 9932352 -refresh
```
To find out the status of the workflow and follow the progress, use -m (for monitor mode) as it will follow the workflows progress till it stops running:
```
Get-AGMLibWorkflowStatus -workflowid 9932352 -m
```
We shoud see something like this:
```
status    : RUNNING
startdate : 2020-10-17 11:52:55
enddate   :
duration  : 00:00:03
result    :
jobtag    : avtestwf_momuser_1404389_9932352_10715728

status    : SUCCESS
startdate : 2020-10-17 11:52:55
enddate   : 2020-10-17 11:55:26
duration  : 00:02:31
result    :
jobtag    : avtestwf_momuser_1404389_9932352_10715728
```
If we want to see the results from the previous run, we can use -p (for previous) like this:
```
Get-AGMLibWorkflowStatus -workflowid 9932352 -p
```
If you want to find any jobs that were ran (or are running) by that workflow, use the job_tag like this:
```
Get-AGMJobStatus -filtervalue jobtag=avtestwf_momuser_1404389_9932352_10715570
```
For example:
```
Get-AGMJobStatus -filtervalue jobtag=avtestwf_momuser_1404389_9932352_10715728 | select-object jobclass,status,startdate,enddate

jobclass    status    startdate           enddate
--------    ------    ---------           -------
reprovision running   2020-10-17 11:52:57  

Get-AGMJobStatus -filtervalue jobtag=avtestwf_momuser_1404389_9932352_10715728 | select-object jobclass,status,startdate,enddate

jobclass    status    startdate           enddate
--------    ------    ---------           -------
reprovision succeeded 2020-10-17 11:52:57 2020-10-17 11:55:08
```