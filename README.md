# AGMPowerCLI
A Powershell module to issue API calls to an Actifio Global Manager or a Google Cloud Backup and DR Management Console

### Table of Contents
**[What does this module do?](#what-does-this-module-do)**<br>
**[Usage](#usage)**<br>
**[What else do I need to know?](#what-else-do-i-need-to-know)**<br>
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
 
### 3a)  Save your AGM password locally - Actifio only

This is for Actifio only. Click [here](https://github.com/Actifio/AGMPowerCLI/blob/main/GCBDR.md "GCBDR") for Google Cloud Backup and DR

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

### 3b)  Save your AGM password remotely - Actifio only

This is for Actifio only. Click [here](https://github.com/Actifio/AGMPowerCLI/blob/main/GCBDR.md "GCBDR") for Google Cloud Backup and DR

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
 
### 4)  Login to your AGM - Actifio only

This is for Actifio only. Click [here](https://github.com/Actifio/AGMPowerCLI/blob/main/GCBDR.md "GCBDR") for Google Cloud Backup and DR

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

This is for Actifio only.

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

This is for Actifio only. Click [here](https://github.com/Actifio/AGMPowerCLI/blob/main/GCBDR.md "GCBDR") for Google Cloud Backup and DR

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
PS > $jobs = Get-AGMJobHistory -filtervalue jobclass=snapshot
PS > $jobs.id.count
32426
PS > Set-AGMAPILimit 100
PS > $jobs = Get-AGMJobHistory -filtervalue jobclass=snapshot
PS > $jobs.id.count
100
```

You can reset the limit to 'unlimited' by setting it to '0'.

#### Get-AGMApplication

Fetch Applications to get their ID, protection status, host info.   In this example we know that smalldb3 is a unique value.
```
Get-AGMApplication -keyword smalldb3
```
### 7)  Disconnect from your appliance
Once you are finished, make sure to disconnect (logout).   If you are running many scripts in quick succession, each script should connect and then disconnect, otherwise each session will be left open to time-out on its own.
```
Disconnect-AGM
```
# What else do I need to know?

##  Time Zone handling

By default all dates shown will be in the local session timezone as shown by the standard PowerShell command ```Get-TimeZone```
```
Get-TimeZone
```
This means you will see all logged events in the local time of the host running this PowerShell session.

You can change the AGMPowerCLI timezone setting to local or UTC with the following two commands:
```
Set-AGMTimeZoneHandling -l
Set-AGMTimeZoneHandling -u 
```
In this example we see timestamps are being shown in local TZ (Melbourne), so we switch to UTC and grab a date example:

```
PS > Get-AGMTimeZoneHandling
Currently timezone in use is local which is (UTC+10:00) Australian Eastern Standard Time
PS > Set-AGMTimeZoneHandling -u
PS > Get-AGMTimeZoneHandling
Currently timezone in use is UTC
PSI> Get-AGMUser -filtervalue name=av | select createdate

createdate
----------
2020-06-19 00:28:07
```
We then switch the timestamps back to local and validate the output of the same command shows Melbourne local time:

```
PS > Set-AGMTimeZoneHandling -l
PS > Get-AGMTimeZoneHandling
Currently timezone in use is local which is (UTC+10:00) Australian Eastern Standard Time
PS > Get-AGMUser -filtervalue name=av | select createdate

createdate
----------
2020-06-19 10:28:07
```

## Date field format

All date fields are returned by AGM as EPOCH time (an offset from Jan 1, 1970).  The Module transforms these using the timezone discussed above.   If an EPOCH time is shown (which will be a long number), then this field has been missed and needs to be added to the transform effort.  Please open an issue to let us know.

## What about Self Signed Certs?

Google Cloud Backup and DR does not use self signed certs so no handling here is necessary.

For an Actifio AGM we only offer the choice to ignore the cert.   Clearly you can manually import the cert and trust it, or you can install a trusted cert on your AGM to avoid the issue altogether.

## Detecting errors and failures

One design goal of AGMPowerCLI is for all user messages to be easy to understand and formatted nicely.   However when a command fails, the return code shown by ```$?``` will not indicate this.  For instance in these two examples we try to connect and check ```$?``` each time.  However the result is the same for both cases ($? being 'True', as opposed to 'False', meaning the last command was successfully run).

Successful login:
```
PS > Connect-AGM 172.24.1.180 av passw0rd -i
Login Successful!
PS > $?
True
```

Unsuccessful login:
```
PS > Connect-AGM 172.24.1.180 av password -i

err_code errormessage
-------- ------------
   10011 Login failed

PS > $?
True
```

The solution for the above is to check for errormessage for every command. 
Lets repeat the same exercise but using -q for quiet login

In a successful login the variable $loginattempt is empty

```
PS > $loginattempt = Connect-AGM 172.24.1.180 av passw0rd -i -q
PS > $loginattempt
```

But an unsuccessful login can be 'seen'.  

```
PS > $loginattempt = Connect-AGM 172.24.1.180 av password -i -q
PS > $loginattempt

err_code errormessage
-------- ------------
   10011 Login failed

PS > $loginattempt.errormessage
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
PS > $LASTEXITCODE
1
```

 # Working with Common Functions in AGMPowerCLI versus Composite Functions in AGMPowerLib
 
 The goal of AGMPowerCLI is to expose all the REST API end points that are available on an AGM so you can automate functions using PowerShell.  However this requires a knowledge of the END points and particularly for commands that create new things (like mounts), these commands need a body that is made of well formed JSON.  For this reason we have started a second module that is dedicated to composite functions.   A composite function is a function that contains multiple end-points or a function that includes guided wizards.   

# Usage Examples

Usage examples are in a separate document that you will find [here](UsageExamples.md)   Note that some usage examples will use the AGMPowerLib module, so also ensure you have that installed:
https://github.com/Actifio/AGMPowerLib/blob/main/README.md

The following links have all moved but are here in case users has them bookmarked

* [User Story: Bulk unprotection of VMs](UsageExamples.md#application-bulk-unprotection)
* [User Story: Managing Protection of a GCP VM](UsageExamples.md#compute-engine-instance-management)
* [User Story: Managing GCP Cloud Credentials](UsageExamples.md#compute-engine-instances)
* [User Story: Adding GCP Instances](UsageExamples.md#compute-engine-instance-discovery)
* [User Story: Bulk expiration](UsageExamples.md#image-expiration)
* [User Story: Appliance management](UsageExamples.md#appliance-add-and-remove)
* [User Story: Consistency Group management](UsageExamples.md#consistency-group-management)
* [User Story: Running appliance info and report commands](UsageExamples.md#appliance-info-and-report-commands)
* [User Story: Setting Appliance timezone](UsageExamples.md#appliance-timezone)
* [User Story: Setting Appliance discovery schedule](UsageExamples.md#appliance-discovery-schedule)
* [User Story: Org Creation](UsageExamples.md#organization-creation)
* [User Story: Restoring an Application](UsageExamples.md#image-restore)


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
