
ldapsearch can now be used to query the Domain Controller for Active Directory

```
ldapsearch -x -H 'ldap://10.10.10.100' -D 'SVC_TGS' -w 'GPPstillStandingStrong2k18' -b
"dc=active,dc=htb" -s sub "(&(objectCategory=person)(objectClass=user)(!
(useraccountcontrol:1.2.840.113556.1.4.803:=2)))" samaccountname | grep sAMAccountName

sAMAccountName: Administrator
sAMAccountName: SVC_TGS
```



