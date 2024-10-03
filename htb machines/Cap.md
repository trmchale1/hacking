After running LinPEAS on the attacking box we get

```
Files with capabilities (limited to 50):
/usr/bin/python3.8 = cap_setuid,cap_net_bind_service+eip
```

The report contains an interesting entry for files with capabilities. The is found to have and , which isn't the default setting. According to the documentation, allows the process to gain setuid privileges without the SUID bit set. This effectively lets us switch to UID 0 i.e. root. The developer of Cap must have given Python this capability to enable the site to capture traffic, which a non-root user can't do.

The following Python commands will result in a root shell:

```
import os  
os.setuid(0) 
os.system("/bin/bash")
```

It calls os.setuid() which is used to modify the process user identifier (UID).