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
            Write-Host "No response was received from $agmip after 15 seconds"
            return;
        }
        elseif ($RestError -like "Connection refused")
        {
            Write-Host "Connection refused received from $agmip"
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
            Write-Error "Password file: $passwordfile could not be opened."
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
    if ($RestError)
    {
        Test-AGMJSON $RestError
    }
    else
    {
        $global:AGMSESSIONID = $resp.session_id
        $global:AGMIP = $agmip
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


    Test-AGMConnection
    
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
	Save credentials so that scripting is easy and interactive login is no longer 
	needed.

	.EXAMPLE
	Save-AGMPassword -filename ./5b-admin-pass
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
		Write-Error "The file: $filename already exists. Please delete it first.";
		return;
	}

	# prompt for password 
	$password = Read-Host -AsSecureString "Password"

	$password | ConvertFrom-SecureString | Out-File $filename

	if ( $? )
	{
		echo "Password saved to $filename."
		echo "You may now use -passwordfile with Connect-AGM to provide a saved password file."
	}
	else 
	{
		Write-Error "An error occurred in saving the password";
	}
}



# offer a way to limit the maximum number of results in a single lookup
function Set-AGMAPILimit([Parameter(Mandatory = $true)]
[ValidateRange("NonNegative")][int]$userapilimit )
{
    $global:agmmaxapilimit = $userapilimit
}