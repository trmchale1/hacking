
Directory fuzzing:

```shell-session
ffuf -w /opt/useful/SecLists/Discovery/Web-Content/directory-list-2.3-small.txt:FUZZ -u http://SERVER_IP:PORT/FUZZ
```

Page fuzzing:

```shell-session
trmchale@htb[/htb]$ ffuf -w /opt/useful/SecLists/Discovery/Web-Content/directory-list-2.3-small.txt:FUZZ -u http://SERVER_IP:PORT/blog/FUZZ.php
```

Recursive Fuzzing:

```shell-session
trmchale@htb[/htb]$ ffuf -w /opt/useful/SecLists/Discovery/Web-Content/directory-list-2.3-small.txt:FUZZ -u http://SERVER_IP:PORT/FUZZ -recursion -recursion-depth 1 -e .php -v
```

Subdomain fuzzing:

```shell-session
trmchale@htb[/htb]$ ffuf -w /opt/useful/SecLists/Discovery/DNS/subdomains-top1million-5000.txt:FUZZ -u https://FUZZ.inlanefreight.com/
```

Actual very good vhost fuzz:

```
ffuf -u http://siteisup.htb -H "Host: FUZZ.siteisup.htb" -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt
```

vhost fuzz, ignore size 1131:
```
ffuf -u http://siteisup.htb -H "Host: FUZZ.siteisup.htb" -w /usr/share/wordlists/subdomains.txt -fs 1131
```
