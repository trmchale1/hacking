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

