# Saving nmap Results


`Nmap` can save the results in 3 different formats.

-   Normal output (`-oN`) with the `.nmap` file extension
-   Grepable output (`-oG`) with the `.gnmap` file extension
-   XML output (`-oX`) with the `.xml` file extension

While `-oA` will save results in all formats.

```shell-session
badgersec@htb[/htb]$ sudo nmap 10.129.2.28 -p- -oA target

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-16 12:14 CEST
Nmap scan report for 10.129.2.28
Host is up (0.0091s latency).
Not shown: 65525 closed ports
PORT      STATE SERVICE
22/tcp    open  ssh
25/tcp    open  smtp
80/tcp    open  http
MAC Address: DE:AD:00:00:BE:EF (Intel Corporate)

Nmap done: 1 IP address (1 host up) scanned in 10.22 seconds
```

## Style sheets

With the XML output, we can easily create HTML reports that are easy to read, even for non-technical people. This is later very useful for documentation, as it presents our results in a detailed and clear way. To convert the stored results from XML format to HTML, we can use the tool `xsltproc`.

  XML Output

```shell-session
badgersec@htb[/htb]$ xsltproc target.xml -o target.html
```

