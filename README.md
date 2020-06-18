# AGMPowerCLI
A Powershell module for Powershell V7 for Actifio Global Manager.

It is currently very limited in function and is considered beta.


### What versions of PowerShell will this module work with?

It was written and tested for PowerShell V7 with Linux, Mac OS and Windows

## Usage


### 1)    Determine where to place AGMPowerCLI if needed

Find out where we should place the AGMPowerCLI PowerShell module in the environment by querying the PSModulePath environment variable:
```
Get-ChildItem Env:\PSModulePath | format-list
```
Try to avoid installing AGMPowerCLI into multiple folders.  You can check for existing installs with this command:
```
(Get-Module -ListAvailable AGMPowerCLI).path
```

### 2)    Install or Upgrade AGMPowerCLI

The commands are basically the same for each OS.
To upgrade simpley run the two Invoke-WebRequest commands.  If you get permission denied because the existing files are read only, delete the old files first.

#### Linux OS Install directions

Presuming you are happy to place into the example folder, these instructions can be followed.   We create a folder for the module and then download the files into that folder.   The module should auto load.

To upgrade repeat the same process except you don't need to create the directory.

```
pwsh
mkdir /opt/microsoft/powershell/7/Modules/AGMPowerCLI
cd /opt/microsoft/powershell/7/Modules/AGMPowerCLI
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLI.psd1 -OutFile AGMPowerCLI.psd1
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLI.psm1 -OutFile AGMPowerCLI.psm1      
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLIConnectFunctions.ps1	 -OutFile AGMPowerCLIConnectFunctions.ps1	
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLIGetFunctions.ps1 -OutFile AGMPowerCLIGetFunctions.ps1
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLIPrivateFunctions.ps1 -OutFile AGMPowerCLIPrivateFunctions.ps1           
Connect-AGM
```

#### Mac OS Install directions

Presuming you are happy to place into the example folder, these instructions can be followed.   We create a folder for the module and then download the files into that folder.   The module should auto load:

To upgrade repeat the same process except you don't need to create the directory.

```
pwsh
mkdir ~/.local/share/powershell/Modules/AGMPowerCLI
cd ~/.local/share/powershell/Modules/AGMPowerCLI
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLI.psd1 -OutFile AGMPowerCLI.psd1
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLI.psm1 -OutFile AGMPowerCLI.psm1      
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLIConnectFunctions.ps1	 -OutFile AGMPowerCLIConnectFunctions.ps1	
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLIGetFunctions.ps1 -OutFile AGMPowerCLIGetFunctions.ps1
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLIPrivateFunctions.ps1 -OutFile AGMPowerCLIPrivateFunctions.ps1         
Connect-AGM
```

#### Windows OS Install directions

Presuming you are happy to place into the example folder, these instructions can be followed.   We create a folder for the module and then download the files into that folder.   The module should auto load:

To upgrade repeat the same process except you don't need to create the directory.

```
pwsh
mkdir "C:\Program Files\PowerShell\7\Modules\AGMPowerCLI"
cd "C:\Program Files\PowerShell\7\Modules\AGMPowerCLI"
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLI.psd1 -OutFile AGMPowerCLI.psd1
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLI.psm1 -OutFile AGMPowerCLI.psm1      
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLIConnectFunctions.ps1	 -OutFile AGMPowerCLIConnectFunctions.ps1	
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLIGetFunctions.ps1 -OutFile AGMPowerCLIGetFunctions.ps1
Invoke-WebRequest -SkipCertificateCheck -Uri https://raw.githubusercontent.com/Actifio/AGMPowerCLI-Beta/main/AGMPowerCLIPrivateFunctions.ps1 -OutFile AGMPowerCLIPrivateFunctions.ps1
Connect-AGM
```


### 3)  Get some help

Help may not exist yet for all functions

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

### 4)  Save your password

Create an encrypted password file using the AGMPowerCLI Save-AGMPassword function:
```
Save-AGMPassword -filename "C:\temp\password.key"
```

The Save-AGMPassword cmdlet creates an encyrpted password file on Windows, but on Linux and Mac it only creates an encoded password file.  This is not a shortcoming with the new Module since existing function is matched but ideally we should find an encryption method for non-Windows OS.   This is a 'to-do'

##### Sharing Windows key files

Currently if a Windows key file is created by a specific user, it cannot be used by a different user.    You will see an error like this:
```
Key not valid for use in specified state.
```
This will cause issues when running saved scripts when two differerent users want to run the same script with the same keyfile.    To work around this issue, please have each user create a keyfile for their own use.   Then when running a shared script, each user should execute the script specifying their own keyfile.  This can be done by using a parameter file for each script.


### 5)  Login to your appliance

To login to an AGM (10.61.5.114) as admin and enter password interactvely:
```
Connect-AGM 10.61.5.114 admin -ignorecerts
```
Or login to the AGM using the password file created in the previous step:
```
Connect-AGM 10.61.5.114 admin -passwordfile "c:\temp\password.key" -ignorecerts
```
You will need to store the certificate during first login if you don't use **-ignorecerts**

Note you can use **-quiet** to supress messages.   This is handy when scripting.

### 6)  Find out the current version of AGMPowerCLI:

```
(Get-Module AGMPowerCLI).Version

Major  Minor  Build  Revision
-----  -----  -----  --------
0      0      0      1
```

### 7) Example commands

There are four common options that may be available for a commnad (if shown with Get-Help)

-id   This will fetch a specific ID
-keyword   This is a case insensitive search of certain fields for a stated keyword.  This is useful for finding an object that has a unique value, like a unique DB name.  You  can only specify one keyword.
-filtervalue   This is a filtering function.  To get a list of available filters, run the command with option -o.   The filters allow for searches using equals, less than, greater than or fuzzy.   To combine searches use & between each filter and encase the whole thing in double quotes.   Here are some examples:

-filtervalue appname=smalldb          -->  Filter on appname
-filtervalue "appname=smalldb&hostname=prodserver"  --> filter on appname and hostname
-filtervalue id<10000    -->  filter on objects where the ID is less than 10000
-filtervalue id>10000     -->  filter on objects where the ID is greater than 10000
-filtervalue appname~smalldb   -->  fuzzy search for appname like smalldb,  so you could get SmallDb, smalldb1, smalldbold.






### 8)  Disconnect from your appliance
Once you are finished, make sure to disconnect (logout).   If you are running many scripts in quick succession, each script should connect and then disconnect, otherwise each session will be left open to time-out on its own.
```
Disconnect-AGM
```



# What else do I need to know?


## API Limit

The module has no API limit which means if you run Get-AGMJobHistory you can easily get results in the thousands or millions.   So we added a command to prevent giant lookups by setting a limit on the number of returned objects, although by default this limit is off.  You can set the limit with:   Set-AGMAPILimit

In the example below, we login and search for snapshot jobs and find there are over sixty thousand.  A smart move would be to use more filters (such as date or appname), but we could also limit the number of results using an APIlimit, so we set it to 100 and only get 100 jobs back:

```
PS /Users/anthony/git/ActPowerCLI> Connect-Act 172.24.1.180 av -passwordfile avpass.key -ignorecerts
Login Successful!
PS /Users/anthony/git/ActPowerCLI> $jobs = Get-AGMJobHistory -filtervalue jobclass=snapshot
PS /Users/anthony/git/ActPowerCLI> $jobs.jobname.count
60231
PS /Users/anthony/git/ActPowerCLI> Set-AGMAPILimit 100
PS /Users/anthony/git/ActPowerCLI> $jobs = Get-AGMJobHistory 
PS /Users/anthony/git/ActPowerCLI> $jobs.jobname.count
100
```

You can reset the limit to 'unlimited' by setting it to '0'.

## Out-GridView for Mac

We have found that Out-GridView on Mac does not work for most SARG commands.   This is a bug in OGV and not the report,  as OGV with PS7 on Windows works fine.   As an alternative download and use Out-HTMLview  on Mac



## What about Self Signed Certs?

At this time you only have the choice to ignore the cert.   Clearly you can manually import the cert and trust it, or you can install a trusted cert on the Appliance to avoid the issue altogether.





# Detecting errors and failures

One design goal of ActPowerCLI is for all user messages to be easy to understand and formatted nicely.   However when a command fails, the return code shown by $? will not indicate this.  For instance in these two examples I try to connect and check $? each time.  However the result is the same for both cases ($? being 'True', as opposed to 'False', meaning the last command was successfully run).

Successful login:
```
PS /Users/anthony/git/ActPowerCLI> Connect-AGM 172.24.1.180 av passw0rd -i
Login Successful!
PS /Users/anthony/git/ActPowerCLI> $?
True
```

Unsuccessful login:
```
PS /Users/anthony/git/ActPowerCLI> Connect-AGM 172.24.1.180 av password -i

err_code errormessage
-------- ------------
   10011 Login failed

PS /Users/anthony/git/ActPowerCLI> $?
True
```

The solution for the above is to check for errormessage for every command. 
Lets repeat the same exercise but using -q for quiet login

In a successful login the variable $loginattempt is empty

```
PS /Users/anthony/git/ActPowerCLI> $loginattempt = Connect-AGM 172.24.1.180 av passw0rd -i -q
PS /Users/anthony/git/ActPowerCLI> $loginattempt
```

But an unsuccessful login can be 'seen'.  

```
PS /Users/anthony/git/ActPowerCLI> $loginattempt = Connect-AGM 172.24.1.180 av password -i -q
PS /Users/anthony/git/ActPowerCLI> $loginattempt

err_code errormessage
-------- ------------
   10011 Login failed

PS /Users/anthony/git/ActPowerCLI> $loginattempt.errormessage
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
