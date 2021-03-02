#Tested with Windows 10 Pro version 1909 and WSL2

#get the WSL ip address
$connectIp = wsl ip addr show eth0
$connectIp = $connectIp | Select-String -Pattern '(\.\d+){3}'

#check if there is an IP
$found = $connectIp -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
if( $found ){
  $connectIp = $matches[0];
} else{
  echo "The Script Exited, the ip address of WSL 2 cannot be found";
  exit;
}

#[Ports]
#All the ports you want to forward separated by coma
$ports=@(80,443,8080,9090,2222);

#[LOCAL IP] USE EITHER LINE 22 OR LINES 24 AND 25 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#You can change the addr to your ip config to listen to a specific address
#$listenIp = '0.0.0.0';

# OR if it is not working you can detect it with these two lines
$listenIp = Test-Connection -ComputerName (hostname) -Count 1  | Select -ExpandProperty IPV4Address
$listenIp = $listenIp.IPAddressToString

#create an array of the ports
$ports_a = $ports -join ",";

#Remove Firewall Exception Rules
iex "Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' ";

#adding Exception Rules for inbound and outbound Rules
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP";

#remove and readd the ports to connect them with the wsl
for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  iex "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$listenIp";
  iex "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$listenIp connectport=$port connectaddress=$connectIp";
}
