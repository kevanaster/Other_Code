<#

This script is used to check port usage on HP Unified Controller.
Created by Eugene Reader 2016


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
$saveFile = "C:\Powershell\"
$NetworkDevices = Import-Csv C:\Powershell\IP.csv #put IPs of Network Devices to be used in CSV formate with header "IPAdress"

#Password for $AdminName

if  ($FileExists -eq $false) {
    New-Item $saveFile -ItemType directory
    Write-Host 'Credential file not found. Enter password:' -ForegroundColor Red
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $CredsFile
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName,$password}

sleep 2

# Run through the devices listd in the NetworkDevices variable 1 at a time

Foreach ($i in $NetworkDevices)
{
    #Create Variable during each iteration, it is disposed once used
    Write-Host 'Using the stored credential file' -ForegroundColor Green
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName,$password

    #start Session for device
    New-SSHSession -ComputerName $i.IPAddress -Credential($Cred) -AcceptKey

    #create Session Stream
    $SSHStream = New-SSHShellStream -SessionId 0
    
    <#Create variable for save file
    This uses a regular expression search and replace. It breaks the IP address into 4 parts 
    (the 4 integer values, discovered by \d+, which means one or more digits, separated by \., which means '.' 
    but needs to be escaped by backslash because '.' has special meaning in regular expressions), and captures the first, 
    second and last parts that it discovers (capture is done by enclosure in round brackets). 
    Once it has captured those values, it replaces the entire string with a new string, using the 1st and 2nd captured values separated by periods #>
    <#if ($i.IPAddress -notlike $filter) {
        $filter = $i.IPAddress
        $saveName = $filter -replace '^(\d+)\.(\d+)\.\d+\.(\d+)$','$1.$2.'
        $filter = $saveName + "*"
        }#>

    <#Adding switch IP to file
    Add-Content -Encoding Ascii ($saveFile + $saveName + ".txt") "`n`r`n#########################"
    Add-Content -Encoding Ascii ($saveFile + $saveName + ".txt") "Switch $i"
    Add-Content -Encoding Ascii ($saveFile + $saveName + ".txt") "#########################"#>

    #Open Command Line for 1910 and 2928
    $SSHStream.WriteLine('_cmdline-mode on')
    $SSHStream.WriteLine('y')
    $SSHStream.WriteLine('512900')
    sleep 1

    #Open Command Line for 1920
    $SSHStream.WriteLine('_cmdline-mode on')
    $SSHStream.WriteLine('y')
    $SSHStream.WriteLine('512900')
    sleep 1

    #Turn off Screen-Length, Paging, Terminal Length (whatever you want to call it)
    $SSHStream.WriteLine('sc di')

    #After log in, run Sys
    $SSHStream.WriteLine('sys')
    #Disable paging (or terminal length) to allow full output to show without breaks
    $SSHStream.WriteLine('no paging')
    sleep 1
    #Push Stream into null to clear stream for line by line evaluation later
    $SSHStream.Read() >> null

    #Testing Logicquit
    $SSHStream.WriteLine('dis int | include Peak value of output: 0 bytes/sec')
    sleep 2
    $down = $SSHStream.Read()
    $downCount = ($down | Select-String "," -AllMatches)
    $downCount = $downCount.Matches.Count
    
    #Write count to file
    Add-Content -Encoding Ascii ($saveFile + "Output\Unused.txt") $downCount
    Add-Content -Encoding Ascii ($saveFile + "Output\IPAddress.txt") $i.ipaddress

    #Turn Paging back on, for normal users to still have breaks in output
    $SSHStream.WriteLine('un sc di')
   
    #close the session
    Remove-SSHSession -SessionID 0 -Verbose
    #set SSHStream back to null
    Clear-Variable -Name SSHStream
    sleep 1
}

