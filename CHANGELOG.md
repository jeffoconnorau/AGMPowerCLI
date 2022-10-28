# Change log

Started Change log file as per release 0.0.0.39

## AGMPowerCLI 0.0.0.45
* Get-AGMSLTPolicy will now support -sltid as well as -id, plus -policyid to display just one policy and -settableoption to display any policy options

## AGMPowerCLI 0.0.0.44
* If service account token generator role was missing, no error was printing in PS7.  

## AGMPowerCLI 0.0.0.43
* Add Set-AGMPromoteUser
* Auto run Set-AGMPromoteUser when Remove-AGMUser is used with GCBDR
* Add New-AGMUser and Set-AGMUser

## AGMPowerCLI 0.0.0.42
* Taught Disconnect-AGM to work with GCBDR

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
