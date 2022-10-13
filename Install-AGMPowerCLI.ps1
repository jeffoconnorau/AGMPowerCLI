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

function GetAGMPowerCLIInstall
{
  # Returns the known installation locations for the AGMPowerCLI Module
  return Get-Module -ListAvailable -Name AGMPowerCLI -ErrorAction SilentlyContinue | Select-Object -Property Name, Version, ModuleBase
}

function GetPSModulePath 
{
    # Returns all available PowerShell Module paths  
    # Windows uses semi-colons, Linux and Mac use colons, go figure.
    $platform=$PSVersionTable.platform
	if ( $platform -match "Unix" )
	{
		return $env:PSModulePath.Split(':')
    }
    else 
    {
      $hostVersionInfo = (get-host).Version.Major
      if ( $hostVersionInfo -lt "6" )
      {
        return $env:PSModulePath.Split(';') 
      }
      else 
      {
        return $env:PSModulePath.Split(';') -notmatch "WindowsPowerShell"
      }
    }

}

function InstallMenu 
{
  # Creates a menu of available install or upgrade locations for the module
  Param(
    [Array]$InstallPathList,
    [ValidateSet('installation','upgrade or delete')]
    [String]$InstallAction
  )
  $i = 1
  foreach ($Location in $InstallPathList)
  {
    Write-Host -Object "$i`: $Location"
    $i++
  }

  While ($true) 
  {
    [int]$LocationSelection = Read-Host -Prompt "`nPlease select an $InstallAction path"
    if ($LocationSelection -lt 1 -or $LocationSelection -gt $InstallPathList.Length)
    {
      Write-Host -Object "Invalid selection. Please enter a number in range [1-$($InstallPathList.Length)]"
    } 
    else
    {
      break
    }
  }
  
  return $InstallPathList[($LocationSelection - 1)]
}

function RemoveModuleContent 
{
  # Attempts to remove contents from an existing installation
  Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction Stop -Confirm:$true
}

function CreateModuleContent
{
  $platform=$PSVersionTable.platform
  # Attempts to create a new folder and copy over the AGMPowerCLI Module contents
  try
  {
    if ( $platform -notmatch "Unix" )
    {
    $null = Get-ChildItem -Path $PSScriptRoot\AGMPowerCLI* -Recurse | Unblock-File
    }
    $null = New-Item -ItemType Directory -Path $InstallPath -Force -ErrorAction Stop
    $null = Copy-Item $PSScriptRoot\AGMPowerCLI* $InstallPath -Force -Recurse -ErrorAction Stop
    $null = Test-Path -Path $InstallPath -ErrorAction Stop
    $commandcheck = get-command -module AGMPowerCLI
    if (!($commandcheck))
    {
      Write-Host -Object "`nInstallation failed."
    }
    else {
      Write-Host -Object "`nInstallation successful."
    }
    
  }
  catch 
  {
    throw $_
  }
}

function ReportAGMPowerCLI
{
  # Removes the AGMPowerCLI Module from the active session and displays a list of all current install locations
  Remove-Module -Name AGMPowerCLI -ErrorAction SilentlyContinue
  GetAGMPowerCLIInstall
}

### Code


$hostVersionInfo = (get-host).Version.Major
if ( $hostVersionInfo -lt "5" )
{
    Write-Host "This module only works with PowerShell Version 5 or above.  You are running version $hostVersionInfo."
    Write-Host "You will need to install PowerShell Version 5 or higher and try again"
    break
}

Import-LocalizedData -BaseDirectory $PSScriptRoot\ -FileName AGMPowerCLI.psd1 -BindingVariable ActModuleData

function silentinstall0
{
  Write-host 'Detected PowerShell version:   ' $hostVersionInfo 
  Write-host 'Downloaded AGMPowerCLI version:' $ActModuleData.ModuleVersion
  $platform=$PSVersionTable.platform
  # if we find an install then we upgrade it
  [Array]$ActInstall = GetAGMPowerCLIInstall
  if ($ActInstall.name.count -gt 1)
  {
    Write-Host -Object "`nMultipe installations detected.  Silent Installation failed."
  }
  if ($ActInstall.name.count -eq 1)
  {
    $InstallPath = $ActInstall.ModuleBase
    Write-host 'Found AGMPowerCLI version:     ' $ActInstall.Version 'in ' $InstallPath 
    Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction Stop -Confirm:$false
  }
  else 
  {
    $InstallPathList = GetPSModulePath
    $InstallPath = $InstallPathList[0]
    if ( $platform -notmatch "Unix" )
    {
      $InstallPath = $InstallPath + '\AGMPowerCLI\'
    }
    else {
      $InstallPath = $InstallPath + '/AGMPowerCLI/'
    }
    
  }
  
  if ( $platform -notmatch "Unix" )
  {
  $null = Get-ChildItem -Path $PSScriptRoot\AGMPowerCLI* -Recurse | Unblock-File
  }
  $null = New-Item -ItemType Directory -Path $InstallPath -Force -ErrorAction Stop
  $null = Copy-Item $PSScriptRoot\AGMPowerCLI* $InstallPath -Force -Recurse -ErrorAction Stop
  $null = Test-Path -Path $InstallPath -ErrorAction Stop
  $commandcheck = get-command -module AGMPowerCLI
  if (!($commandcheck))
  {
    Write-Host 'Silent Installation failed.'
  }
  else {
    Write-Host 'Installed AGMPowerCLI version: ' $ActModuleData.ModuleVersion 'in ' $InstallPath 
  }
  exit
}

function silentinstall
{
  Write-host 'Detected PowerShell version:   ' $hostVersionInfo 
  Write-host 'Downloaded AGMPowerCLI version:' $ActModuleData.ModuleVersion
  $platform=$PSVersionTable.platform
  # if we find an install then we upgrade it
  [Array]$ActInstall = GetAGMPowerCLIInstall
  if ($ActInstall.name.count -gt 1)
  {
    Write-Host -Object "`nMultipe installations detected.  Silent Installation failed."
  }
  if ($ActInstall.name.count -eq 1)
  {
    $InstallPath = $ActInstall.ModuleBase
    Write-host 'Found AGMPowerCLI version:     ' $ActInstall.Version 'in ' $InstallPath 
    Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction Stop -Confirm:$false
  }
  else 
  {
    $InstallPathList = GetPSModulePath
    $InstallPath = $InstallPathList[1]
    if ( $platform -notmatch "Unix" )
    {
      $InstallPath = $InstallPath + '\AGMPowerCLI\'
    }
    else {
      $InstallPath = $InstallPath + '/AGMPowerCLI/'
    }
    
  }
  
  if ( $platform -notmatch "Unix" )
  {
  $null = Get-ChildItem -Path $PSScriptRoot\AGMPowerCLI* -Recurse | Unblock-File
  }
  $null = New-Item -ItemType Directory -Path $InstallPath -Force -ErrorAction Stop
  $null = Copy-Item $PSScriptRoot\AGMPowerCLI* $InstallPath -Force -Recurse -ErrorAction Stop
  $null = Test-Path -Path $InstallPath -ErrorAction Stop
  $commandcheck = get-command -module AGMPowerCLI
  if (!($commandcheck))
  {
    Write-Host 'Silent Installation failed.'
  }
  else {
    Write-Host 'Installed AGMPowerCLI version: ' $ActModuleData.ModuleVersion 'in ' $InstallPath 
  }
  exit
}

if (($args[0] -eq "-silentinstall0") -or ($args[0] -eq "-s0"))
{
  silentinstall0
}

if (($args[0] -eq "-silentinstall") -or ($args[0] -eq "-s"))
{
  silentinstall
}

if (($args[0] -eq "-silentuninstall")  -or ($args[0] -eq "-u"))
{
  [Array]$ActInstall = GetAGMPowerCLIInstall
  foreach ($Location in ([Array]$ActInstall = GetAGMPowerCLIInstall).ModuleBase)
        {
        $InstallPath = $Location
        Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction Stop -Confirm:$false   
        }
      exit
}
Clear-Host
Write-host 'Detected PowerShell version:   ' $hostVersionInfo
Write-host 'Downloaded AGMPowerCLI version:' $ActModuleData.ModuleVersion
Write-host ""

[Array]$ActInstall = GetAGMPowerCLIInstall
if ($ActInstall.Length -gt 0)
{
    Write-Host 'Found an existing AGMPowerCLI Module installation in the following locations:' 
    ReportAGMPowerCLI | Format-Table
    write-host ""
    Write-host "Upgrade or delete menu (choose a folder to upgrade to"$ActModuleData.ModuleVersion"or choose the delete option):"
    $ActInstall += @{
        Name       = 'Delete All'
        Version    = 0.0.0.0
        ModuleBase = 'DELETE all listed installations of the AGMPowerCLI Module'
        }
    $InstallPath = InstallMenu -InstallPathList $ActInstall.ModuleBase -InstallAction 'upgrade or delete'
    
    if ($InstallPath.Split(' ')[0] -eq 'DELETE')
    {
        foreach ($Location in ([Array]$ActInstall = GetAGMPowerCLIInstall).ModuleBase)
        {
        $InstallPath = $Location
        RemoveModuleContent      
        }
        break
    }
    else
    {
        RemoveModuleContent
        CreateModuleContent
    }
    }
    else
    {
    Write-Host "Could not find an existing AGMPowerCLI Module installation."
    Write-Host "Where would you like to install AGMPowerCLI version"$ActModuleData.ModuleVersion
    Write-Host ""
    $InstallPath = InstallMenu -InstallPathList (GetPSModulePath) -InstallAction installation
    $InstallPath = $InstallPath + '\AGMPowerCLI\'
    CreateModuleContent
}

Write-Host -Object "`nAGMPowerCLI Module installation location(s):"
ReportAGMPowerCLI | Format-Table