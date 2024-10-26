To download gobuster, you must download the go programming language first.

```
sudo apt install golang-go
sudo apt install gobuster
```

The flag `-w` precedes the wordlist you are using to bruteforce.

The flag `-u` specifies the IP address

vhost discovery:
```
gobuster vhost -w /opt/useful/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -u http://thetoppers.htb
```
brute-force directories:
```
gobuster dir --url http://ignition.htb/ --wordlist /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt
```

another brute force directories:

```
sudo gobuster dir -w /usr/share/wordlists/common.txt -u {target_ip}
```

A wordlist to use during brute force attacks:

```
git clone https://github.com/danielmiessler/SecLists.git
```

subdomains:

```
$ gobuster dir -u <url> -w <wordlist>
```

brute force directories, looking for php files:

```
gobuster dir -u http://10.129.113.34/ -w sirectory-list-2.3-medium.txt -t 100 -x php
```