<#

This script is used to find Trunk Ports on HP Comware 5. 
Created by Eugene Reader 2017


To install Posh-SSH on the computer this runs on input this command:
"iex (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")"


Posh-SSH (https://github.com/darkoperator/Posh-SSH)
#>

##############################################################################################################################################################
##############################################################################################################################################################

<#
CAPTURE CREDENTIALS

You must run this code manually before setting it to run automatically. This will allow you to store the passwords as Secure Strings and you need to accept SSH key.

This section of the code will verify that credentials are present. If they are not, it will prompt for the password. I have hardcoded the username in as I intend
to use the same username for all devices I log into. I also will only store a single password for the username. This means that all devices must have the same password.
If the password changes, you will need to delete the file associated with the password. C:\PowershellCreds.txt contains the password for $AdminName 
Delete file and you will be prompted for the password. 
#>

$AdminName = "USER" #Username used to log in
$CredsFile = "C:\Powershell\PowershellCreds.txt"
$FileExists = Test-Path $CredsFile
$endDate = (Get-Date).ToString("MM.dd HHmm")
$NetworkDevices = Import-Csv C:\Users\ereader\Documents\IP.csv

#Password for $AdminName

if  ($FileExists -eq $false) {
    New-Item $saveFile -ItemType directory
    Write-Host 'Credential file not found. Enter password:' -ForegroundColor Red
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $CredsFile
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName,$password}

sleep 2

# Run through the devices listed in the NetworkDevices variable

Foreach ($i in $NetworkDevices)
{
    #Create Variable during each iteration, it is disposed once used
    Write-Host 'Using the stored credential file' -ForegroundColor Green
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName,$password

    #start Session for device acceptkey automatically accepts SSH fingerprint
    New-SSHSession -ComputerName $i.IPAddress -Credential($Cred) -AcceptKey

    #create Session Stream
    $SSHStream = New-SSHShellStream -SessionId 0
    sleep 5


    #Open Command Line for 1910 and 2928
    $SSHStream.WriteLine('_cmdline-mode on')
    $SSHStream.WriteLine('y')
    $SSHStream.WriteLine('512900')
    

    #Open Command Line for 1920
    $SSHStream.WriteLine('_cmdline-mode on')
    $SSHStream.WriteLine('y')
    $SSHStream.WriteLine('Jinhua1920unauthorized')

    
    
    #Turn off Screen-Length
    $SSHStream.WriteLine('sc di')
    #After log in, run Sys
    $SSHStream.WriteLine('sys')
    sleep 1

    #Push Stream into null to clear stream for line by line evaluation later
    $SSHStream.Read() >> $null

    #Testing Logic
    $SSHStream.WriteLine('dis int br | i T ')
    sleep 2
    $trunkJunk = $SSHStream.Read()
    
    #Used to pull Trunk interfaces out of interface brief
    $trunkActual = $trunkJunk.Split(' ') | Select-String -Pattern '\w+E\d/\d/\d+' | foreach {$_.Matches.Value}
    
    
    #iterate through trunk interfaces
    foreach ($trunk in $trunkActual)
    {
        if ($trunk -like "XGE*")
        {
            $trunk = "ten" + $trunk.Split('XGE') -replace '\s+',' '
    
        }
        if ($trunk -like "GE*")
        {
            $trunk = "g" + $trunk.Split('GE') -replace '\s+',' '
        }

    
    $SSHStream.WriteLine('int ' + $trunk)
    sleep 1
    $SSHStream.WriteLine('qo t ds')

    }


    #Turn Paging back on, for normal users to still have breaks in output, Save
    $SSHStream.WriteLine('quit')
    $SSHStream.WriteLine('un sc di')
    sleep 1
    $SSHStream.WriteLine('sa sa f')
    
    $SSHStream.WriteLine('quit')
    $SSHStream.WriteLine('un sc di')
    sleep 1
    $SSHStream.WriteLine('sa sa f')
    
   

    #close the session
    Remove-SSHSession -SessionID 0 -Verbose
    #set SSHStream back to null
    Clear-Variable -Name SSHStream
    sleep 2
}


 
