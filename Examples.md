In this 'story' a user wants to mount the latest snapshot of a SQL DB to a host

The User creates a password key

```
PS /Users/anthony> Save-AGMPassword
Filename: av.key
Password: **********
Password saved to av.key.
You may now use -passwordfile with Connect-AGM to provide a saved password file.
```

The user connects to AGM:

```
PS /Users/anthony> Connect-AGM 172.24.1.117 av -passwordfile av.key -i
Login Successful!
```

The user finds the appID for the source DB

```
PS /Users/anthony> Get-AGMDBMApplicationID smalldb

id      friendlytype hostname appname appliancename applianceip  appliancetype managed
--      ------------ -------- ------- ------------- -----------  ------------- -------
5552336 SQLServer    hq-sql   smalldb sa-sky        172.24.1.180 Sky              True
261762  Oracle       oracle   smalldb sa-sky        172.24.1.180 Sky              True
```

The user validates the name of the target host:

```
PS /Users/anthony> Get-AGMDBMHostID demo-sql-4

id       hostname   osrelease                                    appliancename applianceip  appliancetype
--       --------   ---------                                    ------------- -----------  -------------
43673548 demo-sql-4 Microsoft Windows Server 2019 (version 1809) sa-sky        172.24.1.180 Sky
```

The user runs a mount command specifying the source appid, target host and SQL Instance and DB name on the target:

```
PS /Users/anthony> New-AGMMSSQLMount -appid 5552336 -targethostname demo-sql-4 -label "test and dev made easy" -sqlinstance DEMO-SQL-4 -dbname avtest

```

The user finds the running job:

```
PS /Users/anthony> Get-AGMRunningJobs

jobname      jobclass   apptype         hostname                    appname               appid    appliancename startdate           progress targethost
-------      --------   -------         --------                    -------               -----    ------------- ---------           -------- ----------
Job_24358189 mount      SqlServerWriter hq-sql                      smalldb               5552336  sa-sky        2020-06-24 14:50:08       53 demo-sql-4
```

The user tracks the job to success:

```
PS /Users/anthony> Get-AGMFollowJobStatus Job_24358189

jobname      status  progress queuedate           startdate           duration
-------      ------  -------- ---------           ---------           --------
Job_24358189 running       95 2020-06-24 14:49:33 2020-06-24 14:50:08 00:01:30


jobname      status    message startdate           enddate duration
-------      ------    ------- ---------           ------- --------
Job_24358189 succeeded         2020-06-24 14:50:08         00:01:36
```

The user validates the mount exists:

```
PS /Users/anthony> Get-AGMActiveImage

imagename      apptype         hostname        appname appid    mountedhostname childappname appliancename consumedsize label
---------      -------         --------        ------- -----    --------------- ------------ ------------- ------------ -----
Image_24358189 SqlServerWriter hq-sql          smalldb 5552336  demo-sql-4      avtest       sa-sky                   0 test and dev made easy
```

The user works with the DB until it is no longer needed.

The user then unmounts the DB, specifying -d to delete the mount:

```
PS /Users/anthony> Remove-AGMMount Image_24358189 -d
```

The user confirms if the mount created a child app
```
PS /Users/anthony> Get-AGMDBMApplicationID avtest

id       friendlytype hostname   appname appliancename applianceip  appliancetype managed
--       ------------ --------   ------- ------------- -----------  ------------- -------
52410625 SQLServer    demo-sql-4 avtest  sa-sky        172.24.1.180 Sky             False
```

The user deletes the child app:
```
PS /Users/anthony> Remove-AGMApplication 52410625
```
