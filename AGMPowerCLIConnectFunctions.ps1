function Connect-AGM
{
    <#
    .SYNOPSIS
    Connects to AGM to create a Session ID

    .DESCRIPTION
    The Connect-AGM connects to AGM to get a session ID to use on all subsequent calls

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Connect-AGM -agmip 172.24.1.117 -agmuser admin
    This will connect to AGM with a username of "admin" to the IP address 172.24.1.117.
    The prompt will request a secure password.

    .EXAMPLE
    Connect-AGM -agmip 172.24.1.117 -agmuser admin -passwordfile av.key
    This will connect to AGM with a username of "admin" to the IP address 172.24.1.117.
    The password will be provided by using a previously created password file using Save-AGMPassword

    .EXAMPLE
    Connect-AGM 172.24.1.117 admin password -i
    This will connect to AGM with a username of "admin" to the IP address 172.24.1.117.  It unsecurely supplies the password and bypasses the SSL certificate check by specifying -i

    #>

    
    Param([String]$agmip,[String]$agmuser,[String]$agmpassword,[String]$passwordfile,[switch][alias("q")]$quiet, [switch][alias("p")]$printsession,[switch][alias("i")]$ignorecerts,[int]$actmaxapilimit)

    # max objects returned will be unlimited.   Otherwise user can supply a limit
    if (!($agmmaxapilimit))
    {
        $agmmaxapilimit = 0
    }
    $global:agmmaxapilimit = $agmmaxapilimit

    if (!($agmip))
    {
    $agmip = Read-Host "IP or Name of AGM"
    }

    if ($ignorecerts)
    {
      $global:IGNOREAGMCERTS = "y"
    }
    else
    {
        Try
        {
            $resp = Invoke-RestMethod -Uri https://$agmip -TimeoutSec 15
        }
        Catch
        {
            $RestError = $_
        }
        if ($RestError -like "The operation was canceled.")
        {
            Get-AGMErrorMessage -messagetoprint "No response was received from $agmip after 15 seconds"
            return;
        }
        elseif ($RestError -like "Connection refused")
        {
            Get-AGMErrorMessage -messagetoprint "Connection refused received from $agmip"
            return;
        }
        elseif ($RestError)
        {
            Write-Host -ForeGroundColor Yellow "The SSL certificate from https://$agmip is not trusted. Please choose one of the following options";
            Write-Host -ForeGroundColor Yellow "(I)gnore & continue";
            Write-Host -ForeGroundColor Yellow "(C)ancel";
            $validresp = ("i", "I", "c", "C");
            $certaction = $null

            # prompt until we get a proper response.
            while ( $validresp.Contains($certaction) -eq $false )
            {
                $certaction = Read-Host "Please select an option";
            }
            # based on the action, do the right thing.
            if ( $certaction -eq "i" -or $certaction -eq "I" )
            {
                # set IGNOREACTCERTS so that we ignore self-signed certs
                $global:IGNOREAGMCERTS = "y";
            }
            elseif ( $certaction -eq "c" -or $certaction -eq "C" )
            {
                # just exit
                return;
            }
        }
    }

    if (!($agmuser))
    {
    $agmuser = Read-Host "AGM user"
    }

    if (!($passwordfile))
    {
        if (!($agmpassword))
        {
            # prompt for a password
            [SecureString]$passwordenc = Read-Host -AsSecureString "Password";
        }
        else
        {
            [SecureString]$passwordenc = (ConvertTo-SecureString $agmpassword -AsPlainText -Force)
        }
    }
    else
    {
        # if the password file provided is relative or absolute doesn't matter. Test for it first
        if ( Test-Path $passwordfile )
        {
            [SecureString]$passwordenc = Get-Content $passwordfile | ConvertTo-SecureString;
        }
        else
        {
            Get-AGMErrorMessage -messagetoprint "Password file: $passwordfile could not be opened."
            return;
        }
    }

    $Url = "https://$agmip/actifio/session"
    $creds = New-Object System.Management.Automation.PSCredential ("$agmuser", $passwordenc)

    $RestError = $null
    Try
    {
        $resp = Invoke-RestMethod -SkipCertificateCheck -Method POST -Uri $Url -Credential $creds  -TimeoutSec 15
    }
    Catch
    {
        $RestError = $_
    }
    if ($RestError -like "The operation was canceled.")
    {
        Get-AGMErrorMessage -messagetoprint "No response was received from $agmip after 15 seconds"
        return;
    }
    elseif ($RestError -like "Connection refused")
    {
        Get-AGMErrorMessage -messagetoprint "Connection refused received from $agmip"
        return;
    }
    elseif ($RestError)
    {
        $loginfailedsniff = Test-AGMJSON $RestError
        if ($loginfailedsniff.err_code -eq "10011")
        {
            $agmerror = @()
            $agmerrorcol = "" | Select err_code,errormessage
            [int]$agmerrorcol.err_code = "10011"
            $agmerrorcol.errormessage = "Login failed"
            $agmerror = $agmerror + $agmerrorcol
            $agmerror
        }
        else
        {
            $loginfailedsniff
        }
    }
    else
    {
        $global:AGMSESSIONID = $resp.session_id
        $global:AGMIP = $agmip
        $GLOBAL:AGMTimezone = "local"
        if ($quiet)
        {
            return
        }
        elseif ($printsession)
        {
            Write-Host "$agmsessionid"
            return
        }
        else 
        {
            Write-Host "Login Successful!"
            return
        }
    }
}

function Disconnect-AGM
{
    <#  
    .SYNOPSIS
    Connects to AGM to delete a Session ID

    .DESCRIPTION
    The Disconnect-AGM connects to AGM to delete a session ID

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Disconnect-AGM
    

    #>


    Param([switch][alias("q")]$quiet,[switch][alias("p")]$printsession)


    if ( (!($AGMSESSIONID)) -or (!($AGMIP)) )
    {
        Get-AGMErrorMessage -messagetoprint "Not logged in or session expired. Please login using Connect-AGM"
        return
    }
    
    $RestError = $null
    Try
    {
        if ($IGNOREAGMCERTS)
        {
            $resp = Invoke-RestMethod -Method DELETE -SkipCertificateCheck -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "https://$AGMIP/actifio/session/$AGMSESSIONID"
        }
        else 
        {
            $resp = Invoke-RestMethod -Method DELETE -Headers @{ Authorization = "Actifio $AGMSESSIONID" } -Uri "https://$AGMIP/actifio/session/$AGMSESSIONID"
        }
    }
    Catch
    {
        $RestError = $_
    }
    if ($RestError) 
    {
        Test-AGMJSON "$RestError"
    }
    else
    {
        if ($quiet)
        {
            $global:AGMSESSIONID = ""
            return
        }
        elseif ($printsession) 
        {
            Write-Host "Successfully deleted session ID $AGMSESSIONID"   
            $global:AGMSESSIONID = ""
            return         
        }
        else 
        {
            Write-Host "Success!"   
            $global:AGMSESSIONID = ""
            return 
        }
    }
} 

Function Save-AGMPassword([string]$filename)
{
	<#
	.SYNOPSIS
	Save credentials so that scripting is easy and interactive login is no longer needed.

	.EXAMPLE
	Save-AGMPassword -filename admin-pass.key
	Save the password for use later.

	.DESCRIPTION
	Store the credentials in a file which can be used to login to AGM.

	Providing a AGM IP and a AGM User will prompt for a password which will then be 
	stored in the file location provided.

	To change the credentials, simply re-run the cmdlet.

	.PARAMETER filename
	Required. Absolute or relative location where the file should be saved. 
	example: .\actpass
	example: C:\Users\admin\actpass

    #>


	# if no file is provided, prompt for one
	if (!($filename))
	{
		$filename = Read-Host "Filename";
	}

	# if the filename already exists. don't overwrite it. error and exit.
	if ( Test-Path $filename ) 
	{
		Get-AGMErrorMessage -messagetoprint "The file: $filename already exists. Please delete it first.";
		return;
	}

	# prompt for password 
	$password = Read-Host -AsSecureString "Password"

	$password | ConvertFrom-SecureString | Out-File $filename

	if ( $? )
	{
		Write-Host "Password saved to $filename."
		Write-Host "You may now use -passwordfile with Connect-AGM to provide a saved password file."
	}
	else 
	{
		Get-AGMErrorMessage -messagetoprint "An error occurred in saving the password";
	}
}



# offer a way to limit the maximum number of results in a single lookup
function Set-AGMAPILimit([Parameter(Mandatory = $true)]
[ValidateRange("NonNegative")][int]$userapilimit )
{
     <#  
    .SYNOPSIS
    Offers a way to globally limit the number of objects returned by any API get request.

    .DESCRIPTION
    The AGM GUI by default displays a fixed number of objects per page,  limiting the amount of data fetched when a page is displayed.
    By default the PowerShell module will get every object available for the Get being used, unless the user specifies a limit with that get command.
    For object types like job history this can result in possibly millions of objects (jobs) being returned.
    So if you are exploring the API then setting a global limit can allow you to issue gets without concern about how many objects will be fetched.

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Set-AGMAPILimit 10
    This means that every Get command supplied by the base module will only return 10 objects maxium, unless the -limit option is used
 
    .EXAMPLE
    Set-AGMAPILimit 0
    This resets the global limit to 0 which is unlimited, meaning AGM will return every object that it has for the relevant Get.

    #>

    $global:agmmaxapilimit = $userapilimit
}


# offer a way to control timezone used in output.  By default we use User local time for all data
function Set-AGMTimeZoneHandling ([switch][alias("l")]$local,[switch][alias("u")]$utc)
{
     <#  
    .SYNOPSIS
    Offers a way to change which timezone timestamps are shown in.

    .DESCRIPTION
    By default the PowerShell module shows all timestamp in the local timezone of the powershell session.   
    You can validate which timezone that is with:  Get-TimeZone
    You can validate whether the AGM Module is using local or UTC with:  Get-AGMTimeZoneHandling

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Set-AGMTimeZoneHandling -l
    Show all timestamps in the local timezone of the PowerShell session.
 
    .EXAMPLE
    Set-AGMTimeZoneHandling -u
    Show all timestamps in UTC (GMT).

    #>


    if ($utc)
    {
        $GLOBAL:AGMTimezone = "UTC"
    }
    if ($local)
    {
        $GLOBAL:AGMTimezone = "local"
    }
}

function Get-AGMTimeZoneHandling 
{
    <#  
    .SYNOPSIS
    Offers a way to display how timezones are being handled.

    .DESCRIPTION
    By default the PowerShell module shows all timestamp in the local timezone of the powershell session.   
    You can validate which timezone that is with:  Get-TimeZone
    You can change whether the AGM Module is using local or UTC with:  Set-AGMTimeZoneHandling

    .NOTES
    Written by Anthony Vandewerdt

    .EXAMPLE
    Get-AGMTimeZoneHandling
    Show whether the AGM Module is using local or UTC
 
    #>


    if (!($AGMTimezone))
    {
        Get-AGMErrorMessage -messagetoprint "Timezone handling has not been set-up.  Run Set-AGMTimeZoneHandling or Connect-Act";
    }
    elseif ($AGMTimezone -eq "local")
    {
        $currentlocal = Get-TimeZone
        Write-Host "Currently timezone in use is $GLOBAL:AGMTimezone which is $currentlocal"
    }
    else 
    {
        Write-Host "Currently timezone in use is $GLOBAL:AGMTimezone"
    }
}