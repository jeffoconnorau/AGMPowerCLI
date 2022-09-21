# AGMPowerCLI
A Powershell module to issue API calls to an Actifio Global Manager or a Google Cloud Backup and DR Management Console

### Table of Contents
**[What does this module do?](#what-does-this-module-do)**<br>
**[Usage](#usage)**<br>
**[What else do I need to know?](#what-else-do-i-need-to-know)**<br>
**[User Story: Bulk unprotection of VMs](#user-story-bulk-unprotection-of-vms)**<br>
**[User Story: Managing Protection of a GCP VM](#user-story-managing-protection-of-a-gcp-vm)**<br>
**[User Story: Managing GCP Cloud Credentials](#user-story-managing-gcp-cloud-credentials)**<br>
**[User Story: Adding GCP Instances](#user-story-adding-gcp-instances)**<br>
**[User Story: Bulk expiration](#user-story-bulk-expiration)**<br>
**[User Story: Appliance management](#user-story-appliance-management)**<br>
**[User Story: Consistency Group management](#user-story-consistency-group-management)**<br>
**[Contributing](#contributing)**<br>
**[Disclaimer](#disclaimer)**<br>

## What does this module do?
This module is intended to deliver the following:

* Allow the user to create and remove sessions so that API commands can be issued
* Issue commands to API end points 

There is a partner module:  AGMPowerLib found here:  https://github.com/Actifio/AGMPowerLib
The AGMPowerLib module contains what we call composite functions, these being complex combination of API endpoints.   
We chose to separate the two modules (a module for end points versus a module for composite functions), to make it easier to differentiate if you are working with a single end-point or working with a composite collection of endpoints.  

Our intention is that you should install both modules.

### What Actifio/Google products can I use AGMPowerCLI with?
AGMPowerCLI connects to and interacts with the following products/devices:

| Product | Device | Can connect to:
| ---- | ---- | --------
| Actifio | AGM  | yes         
| Actifio | Sky | no        
| Google Cloud Backup and DR | Management Console |  yes
| Google Cloud Backup and DR | Backup/recovery appliance |  no

### What versions of PowerShell will this module work with?

It was written and tested for Windows PowerShell 5 and PowerShell V7 with Linux, Mac OS and Windows

## Usage

> **Note**: When using Microsoft Windows, either always run PowerShell as Administrator or never run PowerShell as Administrator.   Don't mix things up. 

### 1) Install or Upgrade AGMPowerCLI

Install from PowerShell Gallery is the simplest approach.

If running PowerShell 5 on Windows first run this (some older Windows versions are set to use downlevel TLS which will result in confusing error messages):
```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```
Now run this command. It is normal to get prompted to upgrade or install the NuGet Provider.  You may see other warnings as well.
```
Install-Module -Name AGMPowerCLI
```
If the install worked, you can now move to Step 2.  

Many corporate servers will not allow downloads from PowerShell gallery or even access to GitHub from Production Servers, so for these use one of the Git download methods detailed below.

If you see this error make sure your TLS version has been set:

```
WARNING: Unable to resolve package source 'https://www.powershellgallery.com/api/v2'.
```

##### Upgrades using PowerShell Gallery

Note if you run 'Install-Module' to update an installed module, it will complain.  You need to run 'Update-module' instead.

If running PowerShell 5 on Windows first run this (some older Windows versions are set to use downlevel TLS which will result in confusing error messages):
```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```
Now run this command:
```
Update-Module -name AGMPowerCLI
```
It will install the latest version and leave the older version in place.  To see the version in use versus all versions downloaded use these two commands:
```
Get-InstalledModule AGMPowerCLI
Get-InstalledModule AGMPowerCLI -AllVersions
```
To uninstall all older versions run this command:
```
$Latest = Get-InstalledModule AGMPowerCLI; Get-InstalledModule AGMPowerCLI -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module
```
#### Install or upgrade using a clone of the GIT repo

1.  Using a GIT client on your Windows or Linux or Mac OS host, clone the AGMPowerCLI GIT repo.   A sample command is shared below.
2.  Now start PWSH and change directory to the AGMPowerCLI directory that should contain our module files.   
3.  There is an installer, Install-AGMPowerCLI.ps1 so run that with ./Install-AGMPowerCLI.ps1

If you find multiple installs, we strongly recommend you delete them all using the installer option and then run the installer again to have just one install.

A sample clone command is:
```
git clone https://github.com/Actifio/AGMPowerCLI.git AGMPowerCLI
```
#### Install or upgrade using a download of the GIT repo as a ZIP Download

1.  From GitHub, use the Green Code download button to download the AGMPowerCLI-main repo as a zip file
1.  Copy the Zip file to the server where you want to install it
1.  For Windows, Right select on the zip file, choose  Properties and then use the Unblock button next to the message:  "This file came from another computer and might be blocked to help protect  your computer."
1.  For Windows, now right select and use Extract All to extract the contents of the zip file to a folder.  It doesn't matter where you put the folder.  For Mac it should automatically unzip.  For Linux use the unzip command to unzip the folder or use the PowerShell command Expand-Archive.
1.  Now start PWSH and change directory to the AGMPowerCLI-main directory that should contain our module files.   
1.  There is an installer, Install-AGMPowerCLI.ps1 so run that with ./Install-AGMPowerCLI.ps1
If you find multiple installs, we strongly recommend you delete them all and run the installer again to have just one install.

For Download and install on Mac OS or Linux you could also use this set of commands:
```
wget https://github.com/Actifio/AGMPowerCLI/archive/refs/heads/main.zip
pwsh
Expand-Archive ./main.zip
./main/AGMPowerCLI-main/Install-AGMPowerCLI.ps1
rm main.zip
rm -r main
```

If the install fails with:
```
PS C:\Users\av\Downloads\AGMPowerCLI-main\AGMPowerCLI-main> .\Install-
AGMPowerCLI.ps1
.\Install-AGMPowerCLI.ps1: File C:\Users\av\Downloads\AGMPowerCLI-main\AGMPowerCLI-main\Install-AGMPowerCLI.ps1 cannot be loaded. 
The file C:\Users\av\Downloads\AGMPowerCLI-main\AGMPowerCLI-main\Install-AGMPowerCLI.ps1 is not digitally signed. 
You cannot run this script on the current system. For more information about running scripts and setting execution policy, see about_Execution_Policies at https://go.microsoft.com/fwlink/?LinkID=135170.
```
Then run this command:
```
Get-ChildItem .\Install-AGMPowerCLI.ps1 | Unblock-File
```
Then re-run the installer.  The installer will unblock all the files.

Here is a typical install:
```
Could not find an existing AGMPowerCLI Module installation.
Where would you like to install it?

1: C:\Users\av\Documents\PowerShell\Modules
2: C:\Program Files\PowerShell\Modules
3: c:\program files\powershell\7\Modules
4: C:\Windows\system32\WindowsPowerShell\v1.0\Modules\
5: C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules\

Please select an installation path: 2

Installation successful.

AGMPowerCLI Module installation location(s):

Name        Version ModuleBase
----        ------- ----------
AGMPowerCLI 0.0.0.6 C:\Program Files\PowerShell\Modules\AGMPowerCLI

PS C:\Users\av> Connect-AGM 10.65.5.38 av passw0rd -i
Login Successful!
PS C:\Users\av> Get-AGMVersion

product summary
------- -------
AGM     10.0.1.4673

PS C:\Users\av>
```

Now jump over to https://github.com/Actifio/AGMPowerLib and install AGMPowerLib.

##### Silent Install

You can run a silent install by adding **-silentinstall** or **-silentinstall0**

* **-silentinstall0** or **-s0** will install the module in 'slot 0'
* **-silentinstall** or **-s** will install the module in 'slot 1' or in the same location where it is currently installed
* **-silentuninstall** or **-u** will silently uninstall the module.   You may need to exit the session to remove the module from memory

By slot we mean the output of **$env:PSModulePath** where 0 is the first module in the list, 1 is the second module and so on.
If the module is already installed, then if you specify **-silentinstall** or **-s** it will reinstall in the same folder.
If the module is not installed, then by default it will be installed into path 1
```
PS C:\Windows\system32>  $env:PSModulePath.split(';')
C:\Users\avw\Documents\WindowsPowerShell\Modules <-- this is 0
C:\Program Files (x86)\WindowsPowerShell\Modules <-- this is 1
PS C:\Windows\system32>
```
Or for Unix:
```
PS /Users/avw> $env:PSModulePath.Split(':')
/Users/avw/.local/share/powershell/Modules    <-- this is 0
/usr/local/share/powershell/Modules           <-- this is 1
```
Here is an example of a silent install:
```
PS C:\Windows\system32> C:\Users\avw\Downloads\AGMPowerCLI-main\AGMPowerCLI-main\Install-AGMPowerCLI.ps1 -silentinstall 
Detected PowerShell version:    5
Downloaded AGMPowerCLI version: 0.0.0.35
Installed AGMPowerCLI version:  0.0.0.35 in  C:\Program Files (x86)\WindowsPowerShell\Modules\AGMPowerCLI\
```
Here is an example of a silent upgrade:
```
PS C:\Windows\system32> C:\Users\avw\Downloads\AGMPowerCLI-main\AGMPowerCLI-main\Install-AGMPowerCLI.ps1 -silentinstall 
Detected PowerShell version:    5
Downloaded AGMPowerCLI version: 0.0.0.34
Found AGMPowerCLI version:      0.0.0.34 in  C:\Program Files (x86)\WindowsPowerShell\Modules\AGMPowerCLI
Installed AGMPowerCLI version:  0.0.0.35 in  C:\Program Files (x86)\WindowsPowerShell\Modules\AGMPowerCLI
PS C:\Windows\system32>
```

##### Silent Uninstall

You can uninstall the module silently by adding **-silentuninstall**  or **-u** to the Install command.  

### 2)  Get some help

List the available commands in the AGMPowerCLI module:
```
Get-Command -module AGMPowerCLI
```
Find out the syntax and how you can use a specific command. For instance:
```
Get-Help Connect-AGM
```
If you need some examples on the command:
```
Get-Help Connect-AGM -examples
```
 
### 3a)  Save your AGM password locally - Actifio only. Click [here](https://github.com/Actifio/AGMPowerCLI/blob/main/GCBDR.md "GCBDR") for Google Cloud Backup and DR

Create an encrypted password file using the AGMPowerCLI **Save-AGMPassword** function:
```
Save-AGMPassword -filename "C:\temp\password.key"
```

The Save-AGMPassword function creates an encrypted password file on Windows, but on Linux and Mac it only creates an encoded password file.  
Note that you can also use this file with the Connect-Act command from ActPowerCLI.

##### Sharing Windows AGM key files

Currently if a Windows key file is created by a specific user, it cannot be used by a different user.    You will see an error like this:
```
Key not valid for use in specified state.
```
This will cause issues when running saved scripts when two different users want to run the same script with the same keyfile.    To work around this issue, please have each user create a keyfile for their own use.   Then when running a shared script, each user should execute the script specifying their own keyfile.  This can be done by using a parameter file for each script.

### 3b)  Save your AGM password remotely - Actifio only. Click [here](https://github.com/Actifio/AGMPowerCLI/blob/main/GCBDR.md "GCBDR") for Google Cloud Backup and DR

You can save your password in a secret manager and call it during login.   For example you could do this:

1. Enable Google Secret Manager API:  https://console.cloud.google.com/apis/library/secretmanager.googleapis.com
1. Create a secret storing your AGM password:  https://console.cloud.google.com/security/secret-manager
1. Create a service account with the **Secret Manager Secret Accessor** role:  https://console.cloud.google.com/iam-admin/serviceaccounts
1. Create or select an instance which you will use to run PowerShell and set the service account for this instance (which will need to be powered off).
1. On this instance install the Google PowerShell module:  **Install-Module GoogleCloud**
1. You can now fetch the AGM password using a command like this:  
```
gcloud secrets versions access latest --secret=agmadminpassword
```
 
### 4)  Login to your AGM - Actifio only. Click [here](https://github.com/Actifio/AGMPowerCLI/blob/main/GCBDR.md "GCBDR") for Google Cloud Backup and DR

To login to an AGM (10.61.5.114) as admin and enter password interactively:
```
Connect-AGM 10.61.5.114 admin -ignorecerts
```
Or login to the AGM using the password file created in the previous step:
```
Connect-AGM 10.61.5.114 admin -passwordfile "c:\temp\password.key" -ignorecerts
```
If you are using Google secret manager, then if your AGM password is stored in a secret called **agmadminpassword** then this syntax will work:
```
connect-agm 10.152.0.5 admin $(gcloud secrets versions access latest --secret=agmadminpassword) -i 
```
Note you can use **-quiet** to suppress messages.   This is handy when scripting.

#### Login using a different TCP Port

If you are connecting to AGM over port forwarding then you will want to override the default TCP port of 443.   To do this simple add your desired port to the AGMIP.   For instance if you are using local port forwarding through a bastion host where port 8443 is being forwarded to port 443:
```
Connect-AGM 127.0.0.1:8443 admin -passwordfile "c:\temp\password.key" -ignorecerts
```

### 5)  Run your first command:

```
PS /Users/anthony/git/> Get-AGMVersion

product summary
------- -------
AGM     10.0.1.4673
```

### 6) Example commands

There are three common options that may be available for a command (if shown with Get-Help)

#### id search
-id   This will fetch a specific ID

#### keyword search
-keyword   This is a case insensitive search of certain fields for a stated keyword.  This is useful for finding an object that has a unique value, like a unique DB name.  You  can only specify one keyword.

#### filtering
-filtervalue   This is a filtering function.  To get a list of available filters, run the command with option -o.   The filters allow for searches using equals, less than, greater than or fuzzy.   To combine searches use & between each filter and encase the whole thing in double quotes.   Here are some examples:

There are five filter types

| symbol | purpose | example | result
| ------ | ------- | ------- | ------
| = | equals | -filtervalue id=123 | will show objects with an ID equal to 123 
| < | less than | -filtervalue id<123  | will show objects with an ID less than 123
| > | great than | -filtervalue id>123 | will show objects with an ID greater than 123
| ~ | similar to | -filtervalue appname~smalldb | will show objects with an name similar to smalldb
| ! | not equals | -filtervalue apptype!VMBackup | will show objects with that are not apptype of VMbackup

Multiple filtervalues can be used and will combine results.  Note also they need to be encased in double quotes.

| example | result
| ------ | ------- 
| -filtervalue appname=smalldb  | filter on appname
| -filtervalue "appname=smalldb&hostname=prodserver"  | filter on appname and hostname
| -filtervalue id<10000   | filter on objects where the ID is less than 10000
| -filtervalue id>10000   | filter on objects where the ID is greater than 10000
| -filtervalue appname~smalldb  | fuzzy search for appname like smalldb,  so you could get SmallDb, smalldb1, smalldbold.
| filtervalue "appname=smalldb&appname=bigdb" | will show both smalldb and bigdb in the results.

#### Timeouts

The default timeout for initial logins is set to 60 seconds.   

For all other functions (after initial login) you can change the timeout by adding **-agmtimeout XX** to the **connect-agm** command where **XX** is the desired value.

So to set a 10 second timeout for all functions after login:
```
Connect-AGM 10.61.5.114 admin -passwordfile "c:\temp\password.key" -ignorecerts -agmtimeout 10
```

#### API Limit

The module has no API limit which means if you run Get-AGMJobHistory you can easily get results in the thousands or millions.   So we added a command to prevent giant lookups by setting a limit on the number of returned objects, although by default this limit is off.  You can set the limit with:   Set-AGMAPILimit

In the example below, we login and search for snapshot jobs and find there are over sixty thousand.  A smart move would be to use more filters (such as date or appname), but we could also limit the number of results using an API limit, so we set it to 100 and only get 100 jobs back:

```
PS /Users/anthony/git/ActPowerCLI> Connect-Act 172.24.1.117 av -passwordfile avpass.key -ignorecerts
Login Successful!
PS /Users/anthony/git/AGMPowerCLI> $jobs = Get-AGMJobHistory -filtervalue jobclass=snapshot
PS /Users/anthony/git/AGMPowerCLI> $jobs.id.count
32426
PS /Users/anthony/git/AGMPowerCLI> Set-AGMAPILimit 100
PS /Users/anthony/git/AGMPowerCLI> $jobs = Get-AGMJobHistory -filtervalue jobclass=snapshot
PS /Users/anthony/git/AGMPowerCLI> $jobs.id.count
100
```

You can reset the limit to 'unlimited' by setting it to '0'.

#### Get-AGMApplication

Fetch Applications to get their ID, protection status, host info.   In this example we know that smalldb3 is a unique value.

Get-AGMApplication -keyword smalldb3



### 7)  Disconnect from your appliance
Once you are finished, make sure to disconnect (logout).   If you are running many scripts in quick succession, each script should connect and then disconnect, otherwise each session will be left open to time-out on its own.
```
Disconnect-AGM
```



# What else do I need to know?


##  Time Zone handling

By default all dates shown will be in the local session timezone as shown by Get-TimeZone.  There are two commands to help you:
```
Get-AGMTimeZoneHandling
Set-AGMTimeZoneHandling -l
Set-AGMTimeZoneHandling -u 
```
In this example we see timestamps are being shown in local TZ (Melbourne), so we switch to UTC and grab a date example:

```
PS /Users/anthony/git/AGMPowerCLI> Get-AGMTimeZoneHandling
Currently timezone in use is local which is (UTC+10:00) Australian Eastern Standard Time
PS /Users/anthony/git/AGMPowerCLI> Set-AGMTimeZoneHandling -u
PS /Users/anthony/git/AGMPowerCLI> Get-AGMTimeZoneHandling
Currently timezone in use is UTC
PS /Users/anthony/git/AGMPowerCLI> Get-AGMUser -filtervalue name=av | select createdate

createdate
----------
2020-06-19 00:28:07
```
We then switch the timestamps back to local and validate the output of the same command shows Melbourne local time:

```
PS /Users/anthony/git/AGMPowerCLI> Set-AGMTimeZoneHandling -l
PS /Users/anthony/git/AGMPowerCLI> Get-AGMTimeZoneHandling
Currently timezone in use is local which is (UTC+10:00) Australian Eastern Standard Time
PS /Users/anthony/git/AGMPowerCLI> Get-AGMUser -filtervalue name=av | select createdate

createdate
----------
2020-06-19 10:28:07
```

## Date field format

All date fields are returned by AGM as EPOCH time (an offset from Jan 1, 1970).  The Module transforms these using the timezone discussed above.   If an EPOCH time is shown (which will be a long number), then this field has been missed and needs to be added to the transform effort.  Please open an issue to let us know.


## What about Self Signed Certs?

At this time we only offer the choice to ignore the cert.   Clearly you can manually import the cert and trust it, or you can install a trusted cert on your AGM to avoid the issue altogether.


## Detecting errors and failures

One design goal of AGMPowerCLI is for all user messages to be easy to understand and formatted nicely.   However when a command fails, the return code shown by $? will not indicate this.  For instance in these two examples we try to connect and check $? each time.  However the result is the same for both cases ($? being 'True', as opposed to 'False', meaning the last command was successfully run).

Successful login:
```
PS /Users/anthony> Connect-AGM 172.24.1.180 av passw0rd -i
Login Successful!
PS /Users/anthony> $?
True
```

Unsuccessful login:
```
PS /Users/anthony> Connect-AGM 172.24.1.180 av password -i

err_code errormessage
-------- ------------
   10011 Login failed

PS /Users/anthony> $?
True
```

The solution for the above is to check for errormessage for every command. 
Lets repeat the same exercise but using -q for quiet login

In a successful login the variable $loginattempt is empty

```
PS /Users/anthony> $loginattempt = Connect-AGM 172.24.1.180 av passw0rd -i -q
PS /Users/anthony> $loginattempt
```

But an unsuccessful login can be 'seen'.  

```
PS /Users/anthony> $loginattempt = Connect-AGM 172.24.1.180 av password -i -q
PS /Users/anthony> $loginattempt

err_code errormessage
-------- ------------
   10011 Login failed

PS /Users/anthony> $loginattempt.errormessage
java.lang.SecurityException: Login failed.
```

So we could test for failure by looking for the .errormessage

```
if ($loginattempt.errormessage)
{
  write-host "Login failed"
}
```

We can then take this a step further in a script.   If a script has clearly failed, then if we set an exit code, this can be read using $LASTEXITCODE.  We put this into a script (PS1).   NOTE!  If you run this inside a PWSH window directly, it will exit the PWSH session (rather than the PS1 script):

```
if ($loginattempt.errormessage)
{
  write-host "Login failed"'
  exit 1
}
```

We can then read for this exit code like this:

```
PS /Users/anthony> $LASTEXITCODE
1
```

 # Working with Common Functions in AGMPowerCLI versus Composite Functions in AGMPowerLib
 
 The goal of AGMPowerCLI is to expose all the REST API end points that are available on an AGM so you can automate functions using PowerShell.  However this requires a knowledge of the END points and particularly for commands that create new things (like mounts), these commands need a body that is made of well formed JSON.  For this reason we have started a second module that is dedicated to composite functions.   A composite function is a function that contains multiple end-points or a function that includes guided wizards.   
 
 ## Common Functions
 
 There are several functions exported out of the file AGMPowerCLICommonFunctions.ps1 that are intended to be backbone functions for all of the functions that need to interact with AGM.   While power users may choose to work with them directly, using them is optional, especially as we add more functions to AGMPowerLib.
 
### Get-AGMAPIData
This command sends a Get API call to an AGM.   Normally this function is not called directly, but by another function, such as Get-AGMUser.
However power users can use this function to simplify their own scripts if they so choose.

Here is an example, where we do the following:

1. Access the /application endpoint
1. Use a filtervalue to search in the appname field for apps that are like smalldb.  
1. Request the syncdate field get converted from epoch time to IS08601
1. Limit the number of objects (Apps) returned to one.
1. Sort by ID desc.   Now we are only getting back on application,  but by using this sort, we will get the most recently created one.

```
Get-AGMAPIData -endpoint /application -filtervalue appname~smalldb -datefields "syncdate" -limit 1 -sort id:desc
```

Now to be clear, we could do exactly the same thing with this command:
```
Get-AGMApplication -filtervalue appname~smalldb -limit 1 -sort id:desc
```
 
### Post-AGMAPIData
This command sends a Post API call to an AGM.  Normally this function is not called directly, but by another function.  However power users can use this function to simplify their own scripts if they so choose.
Here is an example, we create an org and return data relevant to that new org.  Note the returned data will be formatted JSON.  
The command does:

1.  Connects to the /org endpoint
1.  Sends a body composed of well formed JSON that supplies the Org name and Ord Description
1.  Requests that in the data that gets returned, that the modify date and createdate fields are concerted from epoch time to ISO8601

```
Post-AGMAPIData -endpoint /org -body '{ "description": "Melbourne test team","name": "MelTeam1" }' -datefields "modifydate,createdate"
```
We could do exactly the same with:

```
New-AGMOrg -orgname MelTeam1 -description "Melbourne test team"

```    
In this example we delete an org (ID 53688920):

```
Post-AGMAPIData -endpoint /org/53688920 -method "delete"
```
We could do exactly the same with:
```
Remove-AGMOrg 54382768
```


# User Stories

In this section we will share some examples of User Stories.  Note most user stories use the AGMPowerLib module, so also check them out here:
https://github.com/Actifio/AGMPowerLib/blob/main/README.md

## User Story: Bulk unprotection of VMs

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
connect-agm 
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
PS /Users/anthonyv> $appstounmanage = Import-Csv -Path .\missingvms.csv
PS /Users/anthonyv> $appstounmanage

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


## User Story: Managing Protection of a GCP VM

#### How to learn if a GCP VM is being backed up or not.

Use this command:
```
Get-AGMApplication -filtervalue appname=bastion
```
The term we look for is “Managed” = True 
```
PS /Users/avw> Get-AGMApplication -filtervalue apptype=GCPInstance | select appname,apptype,managed,id, @{N='sltid'; E={$_.sla.slt.id}}, @{N='slpid'; E={$_.sla.slp.id}} | ft

appname     apptype     managed id     sltid slpid
-------     -------     ------- --     ----- -----
consoletest GCPInstance   False 224079
bastion     GCPInstance    True 209913 6392  35557
```

#### How to apply backup to unmanaged GCP VM

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

#### How to learn the IP address of a GCP VM from AGM:

If we know the name of the GCP VM, then use this command: 
```
Get-AGMApplication -filtervalue appname=bastion
```
Here is an example:
```
PS /Users/avw> $appdata = Get-AGMApplication -filtervalue appname=bastion
PS /Users/avw> $appdata.host.ipaddress
10.152.0.3
PS /Users/avw>
```

## User Story: Managing GCP Cloud Credentials


#### Listing Cloud Credentials

```
PS /Users/avw/Downloads> Get-AGMCredential

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

#### Creating new cloud credential:


```
PS /Users/avw/Downloads> New-AGMCredential -name test -filename ./glabco-4b72ba3d6a69.json -zone australia-southeast1-c -clusterid "144292692833,145759989824"

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
PS /Users/avw/Downloads> New-AGMCredential -name test -filename ./glabco-4b72ba3d6a69.json -zone australia-southeast1-c -clusterid "144292692833,145759989824" -projectid glabco1

@type                    errors
-----                    ------
testCredentialResultRest {@{errorcode=4000; errormsg=No privileges for project or incorrect project id provided in credential json.; clusters=System.Object[]}}
```
Duplicate name
```
PS /Users/avw/Downloads> New-AGMCredential -name test -filename ./glabco-4b72ba3d6a69.json -zone australia-southeast1-c -clusterid "144292692833,145759989824"

err_code err_message
-------- -----------
   10023 Create cloud credential failed on appliance avwlab2sky error code 10006 message Unique cloud credential name required: test,Create cloud credential failed on appliance londonsky.c.avwlab2.internal error code 10006 message U…
```

#### Updating an existing cloud credential

The most common reason for doing this is to update the JSON key.  Use syntax like this where we specify the credential ID and the filename of the JSON file.
```
Set-AGMCredential -credentialid 1234 -filename keyfile.json
```
You can also use this command to update the default zone or the credential name as well.   However zone, name and clusterid are not mandatory and only need to be supplied if you are changing them.   The clusterid parameter would determine which appliances get updated, by default all relevant appliances are updated.   You can learn the credential ID with **Get-AGMCredential** and the clusterid will be in the sources field of the same output.   


## User Story: Adding GCP Instances

#### Listing new GCP VMs. Use this syntax:

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
PS /Users/avw> $discovery.items.vm | select vmname,instanceid

vmname      instanceid
------      ----------
consoletest 4240202854121875692
agm         6655459695622225630
```
The total number of VMs that were found and the total number fetched will be different.  In this example, 57 VMs can be found, but only 50 were fetched as the limit defaults to 50:
```
PS /Users/avw> Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid avwlab2

count items                             totalcount
----- -----                             ----------
   50 {@{vm=}, @{vm=}, @{vm=}, @{vm=}…}         57
```
By setting the limit to 60 we now fetch all 57 VMs:
```
PS /Users/avw> Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid avwlab2 -limit 60

count items                             totalcount
----- -----                             ----------
   57 {@{vm=}, @{vm=}, @{vm=}, @{vm=}…}         57

PS /Users/avw>
```

Or we could fetch the first 50 in one command and then in a second command, set an offset of 1, which will fetch all VMs from 51 onwards (offset it added to limit to denote the starting point).  In this example we fetch the remaining 7 VMs (since the limit is 50):
```
PS /Users/avw> Get-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid avwlab2 -limit 50 -offset 1

count items                             totalcount
----- -----                             ----------
    7 {@{vm=}, @{vm=}, @{vm=}, @{vm=}…}         57

PS /Users/avw>
```





#### Add new cloud VMs

Learn the instanceid and then use this command (comma separate the instance IDs):
```
New-AGMCloudVM -credentialid 35548 -clusterid 144292692833 -projectid "avwlab2" -zone "australia-southeast1-c" -instanceid "4240202854121875692,6655459695622225630"
```


#### Deleting a Cloud Credential
```
PS /Users/avw/Downloads> Remove-AGMCredential -credentialid 219764 -applianceid "145759989824,144292692833"
```
Update existing credential with new key and change its name
```
PS /Users/avw/Downloads> Set-AGMCredential -id 219764  -name test1 -filename ./glabco-4b72ba3d6a69.json

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


## User Story: Bulk expiration

You may have a requirement to expire large numbers of images at one time.   One way to approach this is to use the Remove-AGMImage command in a loop. However this may fail as shown in the example below.  The issue is that the first expiration job is still running while you attempt to execute the following jobs, which causes a collission:
```
PS /Users/avw> $images = Get-AGMImage -filtervalue appid=35590 | select backupname
PS /Users/avw> $images

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

PS /Users/avw> foreach ($image in $images)
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
PS /Users/avw> $images = Get-AGMImage -filtervalue appid=35590 | select backupname,expiration
PS /Users/avw> $images

backupname    expiration
----------    ----------
Image_0267271 2021-09-18 19:02:27
Image_0266247 2021-09-17 11:03:09
Image_0265223 2021-09-16 10:07:43
```
We then change them all to a date prior to today and confirm they changed:
```
PS /Users/avw> foreach ($image in $images) { Set-AGMImage -imagename $image.backupname -expiration "2021-09-14" }

xml                            backupRest
---                            ----------
version="1.0" encoding="UTF-8" backupRest
version="1.0" encoding="UTF-8" backupRest
version="1.0" encoding="UTF-8" backupRest

PS /Users/avw> $images = Get-AGMImage -filtervalue appid=35590 | select backupname,expiration
PS /Users/avw> $images

backupname    expiration
----------    ----------
Image_0267271 2021-09-14 00:00:00
Image_0266247 2021-09-14 00:00:00
Image_0265223 2021-09-14 00:00:00

PS /Users/avw>
```
The images will expire over the next hour.



## User Story: Appliance management

You may want to add or remove an Appliance from AGM.   You can list all the Appliances with this command:
```
PS /Users/avw> Get-AGMAppliance | select id,name,ipaddress

id    name       ipaddress
--    ----       ---------
7286  backupsky1 10.194.0.20
45408 backupsky2 10.194.0.38
```
We can then remove the Appliance by specifying the ID of the appliance with this command:
```
PS /Users/avw> Remove-AGMAppliance 45408
PS /Users/avw> Get-AGMAppliance | select id,name,ipaddress

id   name       ipaddress
--   ----       ---------
7286 backupsky1 10.194.0.20
```
We can add the Appliance back with this command.  Note we can do a dryrun to make sure the add will work, but you don't need to.  The main thing with a dry run is we need to see an approval token because that is key to actually adding the appliance.  
```
PS /Users/avw> New-AGMAppliance -ipaddress 10.194.0.38 -username admin -password password -dryrun | select-object approvaltoken,cluster,report

approvaltoken          cluster                                                      report
-------------          -------                                                      ------
05535A005F051E00480608 @{clusterid=141925880424; ipaddress=10.194.0.38; masterid=0} {"errcode":0,"summary":"Objects to be imported:\n\t.....
```
This is the same command but without the dryrun.   After the command finishes, we list the Appliances to see our new one has been added:
```
PS /Users/avw> New-AGMAppliance -ipaddress 10.194.0.38 -username admin -password password  | select-object cluster,report

cluster                                                                                                               report
-------                                                                                                               ------
@{id=45582; href=https://10.194.0.3/actifio/cluster/45582; clusterid=141925880424; ipaddress=10.194.0.38; masterid=0} {"errcode":0,"summary"...

PS /Users/avw> Get-AGMAppliance | select id,name,ipaddress

id    name       ipaddress
--    ----       ---------
45582 backdrsky2 10.194.0.38
7286  backupsky1 10.194.0.20

PS /Users/avw>
```

## User Story: Consistency Group management

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
## Contributing
Have a patch that will benefit this project? Awesome! Follow these steps to have
it accepted.

1.  Please sign our [Contributor License Agreement](CONTRIB.md).
1.  Fork this Git repository and make your changes.
1.  Create a Pull Request.
1.  Incorporate review feedback to your changes.
1.  Accepted!

## License
All files in this repository are under the
[Apache License, Version 2.0](LICENSE) unless noted otherwise.

## Disclaimer
This is not an official Google product.
