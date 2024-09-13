# nmap

Network Mapper is an open-source network analysis and security auditing tool written in C and Python. It is designed to scan networks and identify which hosts are available using raw packets. Nmap can identify services, applications, versions, and operating systems. Can determine packet filters, firewalls, or intrusion detection systems.

- Host discovery
- Port Scanning
- Service enumeration and detection
- OS detection
- Scriptable interaction with the target service


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
