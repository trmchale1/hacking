# nmap --help

Syntax for #nmap: 
```shell-session
badgersec@htb[/htb]$ nmap <scan types> <options> <target>
```

```shell-session
badgersec@htb[/htb]$ nmap --help

SCAN TECHNIQUES:
  -sS/sT/sA/sW/sM: TCP SYN/Connect()/ACK/Window/Maimon scans
  -sU: UDP Scan
  -sN/sF/sX: TCP Null, FIN, and Xmas scans
  --scanflags <flags>: Customize TCP scan flags
  -sI <zombie host[:probeport]>: Idle scan
  -sY/sZ: SCTP INIT/COOKIE-ECHO scans
  -sO: IP protocol scan
  -b <FTP relay host>: FTP bounce scan

```

Next: [[TCP-SYN scan (-sS)]]
