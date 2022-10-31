# Overview
This document describes how to configure PowerShell access to the Backup and DR Management Console.  This document will also provide guidance if you are converting from Actifio GO

## Prerequisites
To perform Backup and DR PowerShell operations, you need the following:

1. A Service Account with the correct roles needs to be selected or created in the relevant project  (that's the project that has access to the Management Console)
1. A host to run that service account, either:
    1. A Linux or Windows Compute Engine Instance with an attached service account which has GCloud CLI and PowerShell installed.
    1. A Linux, Mac or Windows host which has GCloud CLI and PowerShell installed and which has a downloaded JSON key for the relevant service account.  

## Timeouts 

Backup and DR uses OpenID Connect (OIDC) ID tokens that are valid for 1 hour (3,600 seconds).  When they expire you will see a message like this:
```
PS /> New-AGMLibSAPHANAMount

errormessage
------------
OpenID Connect token expired: JWT has expired
```
You will need to re-run Connect-AGM to generate a new token.

## Getting Management Console details

Once you have deployed Backup and DR, then a management console will be configured.     Open the Show API Credentials twisty to learn the Management Console API URL and OAuth 2.0 client ID.  You will need these.

In this example (yours will be different!):

* Management Console URL:  ```https://agm-666993295923.backupdr.actifiogo.com/actifio```
* OAuth 2.0 client ID:     ```486522031570-fimdb0rbeamc17l3akilvquok1dssn6t.apps.googleusercontent.com```


## Creating your Service Account

From Cloud Console IAM & Admin panel in the project where Backup and DR was activated, go to **Service Account** and choose **Create Service Account**.  You can also modify an existing one if desired.

Ensure it has **one** of the two following roles:


* ```Backup and DR User``` 
* ```Backup and DR Admin```

You then need to go to **IAM & Admin** > **Service Accounts**.  Find that service account, select it, go to **PERMISSIONS,** select **GRANT ACCESS**, enter the principal (email address) of the service account we will activate or attach with one of the following roles (you don't need both).  You can assign this to the same service account that was assigned the ```Backup and DR``` role:

* ```Service Account Token Creator```
* ```Service Account OpenID Connect Identity Token Creator```

> **Note**: Do not assign either of these ```Token Creator``` roles to a service account at the project level.  Doing so will allow that account to _impersonate_ any other service account, which will make that user able to login as any user that has access to a **Backup and DR** role.

Decide where/how you will run your service account. You have two options:
1. Compute Engine Instance with attached service account

In option 1 we are going to use a Compute Engine instance to run our API commands/automation and because a Compute Engine Instance can have an attached Service Account, we can avoid the need to install a service key on that host.   The host needs the GCloud CLI installed (which is automatic if you use a Google image to create the instance).  

In your project create or select an instance that you want to use for API operations.   Ensure the service account that is attached to the instance has the permissions detailed above.  You can use an existing instance or create a new one.   If you need to change/set the Service Account, the instance needs to be powered off.

2. Activate your service account on a host

In option 2, we are going to use a Compute Engine instance or external host/VM to run our API commands/automation, but we are going to 'activate' the Service account using a JSON Key.   The host needs the **gcloud** CLI installed.

We need to activate our service account since we are not executing this command from a Compute Engine instance with an attached service account.
So firstly we need to download a JSON key from the Google Cloud Console and copy that key to our relevant host:

1. Go to **IAM & Admin** →  **Service Accounts**
1. Select your Service Account
1. Go to **Keys**
1. Select **Add Key** → **Create new key**
1. Leave key type as JSON and select **CREATE**
1. Copy the downloaded key to the relevant host

Note that some projects may restrict key creation or set time limits on their expiration. 

Now from the host where your service account key is eventually placed we need to activate it:
```
gcloud auth activate-service-account powershell@avwservicelab1.iam.gserviceaccount.com --key-file=avwservicelab1-753d6ff386e3.json
gcloud config set account powershell@avwservicelab1.iam.gserviceaccount.com 
gcloud config set project avwservicelab1
```
At this point we can proceed with the next step.

### Management server details check - PowerShell

We can confirm our management console details as follows:
```
PS /> Get-GoogleCloudBackupDRConsole -project avwservicelab1 -location asia-southeast1

name           : projects/avwservicelab1/locations/asia-southeast1/managementServers/agm-64111
createTime     : 2022-04-19T01:38:31.793435583Z
updateTime     : 2022-04-28T09:51:52.374135508Z
state          : READY
networks       : {@{network=projects/avwarglabhost/global/networks/arg-host-network; peeringMode=PRIVATE_SERVICE_ACCESS}}
managementUri  : @{webUi=https://agm-666993295923.backupdr.actifiogo.com; api=https://agm-666993295923.backupdr.actifiogo.com/actifio}
type           : BACKUP_RESTORE
oauth2ClientId : 486522031570-fimdb0rbeamc17l3akilvquok1dssn6t.apps.googleusercontent.com
```
### Add the Service Account to the Management Console as a user with Management Console role
To ensure the user has the correct Management Console role (which is different to an IAM role) the first time it logs in, manually add the user to the Management Console BEFORE the first login.    After you create the user in Google IAM,  login to your Management Console,  go to  **Manage** → **Users** and select **Create User**

Now enter the Service account email as the Username and select the relevant roles and **Save User**.   

You can now proceed to login having _pre-added_ the user and assigned it a Management Console role.


### Login process - PowerShell

This uses the two existing PowerShell modules, ```AGMPowerCLI`` and ```AGMPowerLib```.
These modules can be used with both an Actifio GO AGM and Backup and DR Management Consoles.  The only difference is that we specify the service account as **-agmuser**, we do NOT need to specify a password, but we instead need to specify the oauth2ClientId using **-oauth2ClientId**.   If you do not specify the oauth2clientid then the login will fail.


#### Login to the Management Console

To login use syntax like this:
```
connect-agm -agmip agm-666993295923.backupdr.actifiogo.com -agmuser powershell@avwservicelab1.iam.gserviceaccount.com -oauth2ClientId 486522031570-fimdb0rbeamc17l3akilvquok1dssn6t.apps.googleusercontent.com
```
Here is an example:
```
PS /> connect-agm -agmip agm-666993295923.backupdr.actifiogo.com -agmuser powershell@avwservicelab1.iam.gserviceaccount.com -oauth2ClientId 486522031570-fimdb0rbeamc17l3akilvquok1dssn6t.apps.googleusercontent.com
Login Successful!
```
If your user does not have a Management Console role set, use the Management Console GUI to set it as per the instructions in Simplified User Add solution.

We can start issuing commands.  If your commands fail, then your user does not have a role set.   Set your role using the management console and then login again.
```
PS /> Get-AGMSLP 

@type           : slpRest
id              : 4358
href            : https://agm-504992018861.backupdr.actifiogo.com/actifio/slp/4358
syncdate        : 2022-04-07 00:37:56
stale           : False
description     : Local profile
name            : LocalProfile
performancepool : act_per_pool000
srcid           : 51
cid             : 4311
localnode       : backup-server-36842
clusterid       : 145126716485
createdate      : 2022-03-25 04:33:00
```

## Converting Scripts From Actifio GO to Backup and DR

There are three considerations when converting from Actifio GO:

1. Is the automation using AGM API commands or Sky API commands or Sky SSH
1. Configuration of the host where the automation is running 
1. The user ID being used by the automation for authentication

Let's look at each point:

### AGM API vs Sky API

Backup and DR only supports AGM API commands, sent to the Management Console.   If your automation is targeting a Sky Appliance using udsinfo and udstask commands sent either via ActPowerCLI (PowerShell), REST API command or an SSH session, then it cannot be used with Backup and DR and will need to be re-written.   If your automation is already using AGM API commands (or AGMPowerCLI), then very few changes will be needed.
### Automation Host Configuration

The automation host for Backup and DR API calls will need the gcloud CLI installed. Once installed the gcloud CLI will need access to a Google Cloud Service Account (with the correct roles), either through being executed on a GCE Instance running as that SA, or by using an activated JSON key for that service account.   The setup tasks for this typically only need to be done once, and are detailed in the sections above.

If using JSON keys, and the JSON keys expire, then a process to renew the keys will need to be established.

### Automation User ID

Actifio GO uses either an AGM local user or an LDAP user.   Backup and DR API uses an SA created using Google IAM. The establishment of the SA is a one time task.   The only change needed in the automation scripts is a syntax change to the logon command.   If using the AGMPowerCLI PowerShell module, this is a one-line change as shown below:

Actifio GO:   In this logon example we specify three things:   agmip, agmuser and passwordfile
```
connect-agm -agmip 192.168.1.100 -agmuser admin -passwordfile c:\pass.key
```
Backup and DR:   The changes needed are:
1. Change the agmip to the Management Console name
1. Change agmuser to the SA
1. Replace passwordfile with oauth2ClientId

For example:
```
connect-agm -agmip agm-666993295923.backupdr.actifiogo.com -agmuser powershell@avwservicelab1.iam.gserviceaccount.com -oauth2ClientId 486522031570-fimdb0rbeamc17l3akilvquok1dssn6t.apps.googleusercontent.com
```
### Stored Credentials

It is important to consider the security of the user credentials.   When using Actifio GO, the password for the user is either stored in a key file or possibly in a password vault (such as Google Secret Manager).   Either way if a user has access to the key file or the vault, they can manually run the automation or even run different backup API commands using those credentials.  

When using Service Account keys with Backup and DR, the long term credential is now managed by the gcloud client.   If a user has access to run gcloud commands then they can also manually run the automation or run different backup API commands. 

To prevent unauthorized access, be sure to secure access to the automation host, and set the minimum required role and organization on the service account when adding it to the Backup and DR Management Console.


## FAQ
### I can connect but don't seem to stay connected

You may see a pattern like this, where connect-agm works, but most commands say you are not logged in.
```
PS /Users/avw/Documents> Connect-AGM -agmip agm-666993295923.backupdr.actifiogo.com -agmuser iapaccess@avwservicelab1.iam.gserviceaccount.com -oauth2ClientId 486522031570-fimdb0rbeamc17l3akilvquok1dssn6t.apps.googleusercontent.com
Login Successful!
PS /Users/avw/Documents> Get-AGMSession

@type      : sessionRest
id         : 2cab68db-8a65-44c4-8861-8440adb3c5ea
href       : https://agm-666993295923.backupdr.actifiogo.com/actifio/session/2cab68db-8a65-44c4-8861-8440adb3c5ea
session_id : 2cab68db-8a65-44c4-8861-8440adb3c5ea
rights     : {@{id=Access System Monitor; href=https://agm-666993295923.backupdr.actifiogo.com/actifio/right/Access%20System%20Monitor; name=Access System Monitor}, @{id=Access SLA Architect; href=https://agm-666993295923.backupdr.actifiogo.com/actifio/right/Access%20SLA%20Architect; name=Access SLA Architect}, @{id=Access
             Application Manager; href=https://agm-666993295923.backupdr.actifiogo.com/actifio/right/Access%20Application%20Manager; name=Access Application Manager}, @{id=Access Domain Manager; href=https://agm-666993295923.backupdr.actifiogo.com/actifio/right/Access%20Domain%20Manager; name=Access Domain Manager}}
user       : @{id=185577; href=https://agm-666993295923.backupdr.actifiogo.com/actifio/user/185577; name=iapaccess@avwservicelab1.iam.gserviceaccount.com; dataaccesslevel=0; createdate=1655945788985000; localonly=True; version=0; orglist=System.Object[]; rolelist=System.Object[]; rightlist=System.Object[]}
authconfig : @{method=DATABASE}

PS /Users/avw/Documents> Get-AGMRole

errormessage
------------
Not logged in or session expired. Please login using Connect-AGM

PS /Users/avw/Documents
```

The issue is that your Management Console user has no role.   Go to the Management Console GUI and set the Users role.   Then run connect-AGM again.


### Can I use this Service Account to login to the Management Console WEB GUI?

No you cannot.   A service account cannot be used to login to a Web Browser to authorize Console access


### Can I use one service account into two projects?

Let's say we have two projects, ProjectA and ProjectB:

1. You activate Google Cloud Back and DR in both projects.   
1. You create a service account api@saprojectA  in projectA and give it the roles/permissions needed to perform API operations in ProjectA
1. You can now add  api@saprojectA to project B and provided you give it the same role/permissions it can now do API operations in both ProjectA and ProjectB

The one thing you cannot do is run an instance in ProjectB as the SA from ProjectA using Option 2: Activate your service account on a host
