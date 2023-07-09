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

For example, the TCP-SYN scan (`-sS`) is one of the default settings unless we have defined otherwise and is also one of the most popular scan methods.

- If our target sends an `SYN-ACK` flagged packet back to the scanned port, Nmap detects that the port is `open`.
-   If the packet receives an `RST` flag, it is an indicator that the port is `closed`.
-   If Nmap does not receive a packet back, it will display it as `filtered`. Depending on the firewall configuration, certain packets may be dropped or ignored by the firewall.

An example of nmap using the -sS flag:

```shell-session
badgersec@htb[/htb]$ sudo nmap -sS localhost

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-11 22:50 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000010s latency).
Not shown: 996 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
5432/tcp open  postgresql
5901/tcp open  vnc-1

Nmap done: 1 IP address (1 host up) scanned in 0.18 seconds
```

Next: [[TCP-SYN scan (-sS)]]
