
`sudo -l` or `sudo su`

This looks like trying to find suid (4000:set userid) sgid (2000:set groupid) file.

that is binary that, when run get a new userid, or a new groupid. those are use mostly for

- system related task
- database (e.g. file belong to oracle or mysql)
- hacking system ...

`find / -type f -perm -4000 2>/dev/null`


Writable files owned by root:

```
find / -writable -user root -type f 2>/dev/null
```

Find the kernel version

```
uname -r
```

Search SUID binaries:

```
find / -perm -u=s -type f 2>/dev/null
```

