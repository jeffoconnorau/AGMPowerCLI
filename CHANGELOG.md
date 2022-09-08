# Change log

Started Change log file as per release 0.0.0.39

## AGMPowerCLI  0.0.0.41
* Added New-AGMConsistencyGroup, Remove-AGMConsistencyGroup, Set-AGMConsistencyGroup and Set-AGMConsistencyGroupMember 

## AGMPowerCLI  0.0.0.40
* Added -password to Save-AGMPassword

## AGMPowerCLI  0.0.0.39
* [GitHub commits](https://github.com/Actifio/AGMPowerCLI/commits/v0.0.0.39)
* Default timeout of 60 seconds is causing timeouts on GCE Instance operations. Increasing to 300 seconds
* Remove-AGMSLA will error if a non-protected Appid is specified rather than requesting an SLA ID
* Get-AGMAPIApplianceInfo will now allow user to use $id
* Get-AGMCloudVM can handle minor API change in GCBDR by looking for projectid rather than project
