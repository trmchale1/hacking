The SMB protocol can access remote resources like files or printers.

SMB storage is called a share.

To list SMB shares:

```
smbclient -L {target ip}
```

To login to an SMB share WorkShare:

```
smbclient \\\\{target_ip}\\WorkShare
```

You can use `cd` to change directories, and use `get` to get a file and download it to your host machine.

To return a list of shares w/o logging in:

```
smbmap -d active.htb -u SVC_TGS -p GPPstillStandingStrong2k18 -H 10.10.10.100
```

Logging in with a user and password:

```
smbclient -U SVC_TGS%GPPstillStandingStrong2k18 //10.10.10.100/Users
```

