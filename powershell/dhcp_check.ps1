### Poll AD for DCs, check dhcp scopes under all DCs for Option 60 and Option 43 for Aruba APs

$ErrorActionPreference = 'SilentlyContinue'

$dhcp_list = Get-DhcpServerInDC
Foreach ($i in $dhcp_list) { 
    $scope_cn = $i.DnsName
    $scope_ip = 'FAILED'
    $scope_ip = (Get-DhcpServerv4Scope -ComputerName $scope_cn | Where-Object {(($_.Name.ToLower() -like '*ap*') -or ($_.Name.ToLower() -like '*access point*')) -and ($_.Name.ToLower() -notlike '*app*')}).ScopeID
    $scope_options = Get-DhcpServerv4OptionValue -ComputerName $scope_cn -ScopeId $scope_ip
    $option_60 = ($scope_options | Where-Object {$_.OptionId -eq 60}).Value
    $option_43 = Resolve-DnsName ([System.Text.Encoding]::ASCII.GetString(($scope_options | Where-Object {$_.OptionId -eq 43}).Value)) | Select-Object NameHost

    if ($scope_ip -ne 'FAILED') {
        if ($option_43 -notlike '*REDACTED*') {Write-Host $scope_cn',43,Wrong'}
        if ($option_60 -ne 'ArubaAP') {Write-Host $scope_cn',60,Wrong'}
        }
    }
