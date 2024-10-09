
Running nmap, I see port 53 running `dnsmasq 2.76`, which is a DNS server.

Running gobuster, I see on the admin directory is hosting PI-hole dashboard which gives us some data on the number of times a rasberry pi is accessed.

Using the default credentials for rasberry pi, `pi:rasberry` we connect via ssh:

```
ssh pi@10.10.10.48
```

After getting access, the flag is found `/home/pi/Desktop/user.txt`

To escalate our priviledges to root I first ran `df -h`, which reports on free disk usage and a list of machine partitions, at the bottom we see the `media/usbstick` mount.

There is a single file on that mount, `damnit.txt`, which lets us know the user James deleted the files on the USB stick.

If I run `sudo strings /dev/sdb` it will reveal the root flag.

