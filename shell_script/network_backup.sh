#!/usr/bin/env bash

### Begin Settings ###

#Username and Password for SCP
scp_usr='username'
scp_pw='password'

#IP address for the SCP server
scp_ip=10.10.10.20

#Define the needed tools by using the "which" command to find their full paths.
scp=`which scp`
expect=`which expect`
ssh=`which ssh`

#IP addresses of Network devices to backup
#Campus Stack
campus=10.10.8.2
campus_pw=password
campus_en=enable

#Tower Stack
tower=10.10.8.7
tower_pw=password
tower_en=enable

#7210 Controller
controller=10.10.8.3
controller_pw=password
controller_en=enable

#7210 Backup  Controller
controller2=10.10.8.4 
controller2_pw=password
controller2_en=enable

#Brocade1
brocade1=10.10.8.10
brocade1_pw=password

#Brocade2
brocade2=10.10.8.11
brocade2_pw=password

#Palo Alto Firewall
firewall=10.10.8.1
firewall_pw=password

### End Settings ###



### Start Flash Backup ###

#Campus Flash backup
$expect -c "
set timeout 15
spawn $ssh admin@$campus
expect password:
send $campus_pw\r
expect >
send \"enable\r\"
expect Password:
send $campus_en\r
expect #
send \"backup flash\r\"
expect \"when done.\"
send \"copy flash: flashbackup.tar.gz scp: $scp_ip $scp_usr campus.tar.gz\r\"
expect Password:
send $scp_pw\r
expect successfully
send \"delete filename flashbackup.tar.gz\r\"
send \"exit\r\"
expect >
send \"exit\r\"
"
echo

#Tower Flash backup
$expect -c "
set timeout 15
spawn $ssh admin@$tower
expect password:
send $tower_pw\r
expect >
send \"enable\r\"
expect Password:
send $tower_en\r
expect #
send \"backup flash\r\"
expect \"when done.\"
send \"copy flash: flashbackup.tar.gz scp: $scp_ip $scp_usr tower.tar.gz\r\"
expect Password:
send $scp_pw\r
expect successfully
send \"delete filename flashbackup.tar.gz\r\"
send \"exit\r\"
expect >
send \"exit\r\"
"

echo

#7210 Controller Flash backup
$expect -c "
set timeout 15
spawn $ssh admin@$controller
expect password:
send $controller_pw\r
expect >
send \"enable\r\"
expect Password:
send $controller_en\r
expect #
send \"backup flash\r\"
expect \"when done.\"
send \"copy flash: flashbackup.tar.gz scp: $scp_ip $scp_usr controller7210.tar.gz\r\"
expect Password:
send $scp_pw\r
expect successfully
send \"delete filename flashbackup.tar.gz\r\"
send \"exit\r\"
expect >
send \"exit\r\"
"

echo

#7210 Backup Controller Flash backup
$expect -c "
set timeout 15
spawn $ssh admin@$controller2
expect password:
send $controller2_pw\r
expect >
send \"enable\r\"
expect Password:
send $controller2_en\r
expect #
send \"backup flash\r\"
expect \"when done.\"
send \"copy flash: flashbackup.tar.gz scp: $scp_ip $scp_usr controller7210backup.tar.gz\r\"
expect Password:
send $scp_pw\r
expect successfully
send \"delete filename flashbackup.tar.gz\r\"
send \"exit\r\"
expect >
send \"exit\r\"
"

echo

#Brocade1 Startup-Config Backup
$expect -c "
set timeout 15
spawn $ssh admin@$brocade1
expect password:
send $brocade1_pw\r
expect #
send \"copy startup-config scp://$scp_usr:$scp_pw@$scp_ip/Brocade1.conf\r\"
expect #
send \"exit\r\"
"

echo

#Brocade2 Startup-Config Backup
$expect -c "
set timeout 15
spawn $ssh admin@$brocade2
expect password:
send $brocade2_pw\r
expect #
send \"copy startup-config scp://$scp_usr:$scp_pw@$scp_ip/Brocade2.conf\r\"
expect #
send \"exit\r\"
"

echo

#Palo Alto Firewall Config Backup
$expect -c "
set timeout 15
spawn $ssh ereader@$firewall
expect Password:
send $firewall_pw\r
expect >
send \"scp export configuration from running-config.xml to $scp_usr@$scp_ip:firewall.xml\r\"
expect password:
send $scp_pw\r
expect >
send \"exit\r\"
"

echo
echo "Flash Backup Complete"

### End Flash Backup ###

