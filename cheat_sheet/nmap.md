Scan all ports for version:

`nmap -p- -sV {target_ip}`

nmap speed:

```
nmap -p- --min-rate=1000 -sV {target_ip}
```

the flag `--min-rate` specifies the min number of packets that nmap should send per second, the higher the number the faster the scan.

Script Scanning and version detection, this is the most intrusive nmap scan, with a high probability of being caught. It also produces pretty and verbose output. 

```
sudo nmap -sC -sV {target_ip}
```





