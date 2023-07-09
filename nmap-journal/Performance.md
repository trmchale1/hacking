# Peformance

## Timeouts

When Nmap sends a packet, it takes some time (`Round-Trip-Time` - `RTT`) to receive a response from the scanned port. Generally, `Nmap` starts with a high #timeout (`--min-RTT-timeout`) of 100ms. Let us look at an example by scanning the whole network with 256 #hosts, including the top 100 ports.

#### Default Scan

```shell-session
badgersec@htb[/htb]$ sudo nmap 10.129.2.0/24 -F

<SNIP>
Nmap done: 256 IP addresses (10 hosts up) scanned in 39.44 seconds
```

#### Default Scan - Found Open Ports

```shell-session
badgersec@htb[/htb]$ cat tnet.default | grep "/tcp" | wc -l

23
```

#### Optimized Scan - Found Open Ports

```shell-session
badgersec@htb[/htb]$ cat tnet.minrate300 | grep "/tcp" | wc -l

23
```

## Timing

Because such settings cannot always be optimized manually, as in a #black-box penetration test, `Nmap` offers six different timing templates (`-T <0-5>`) for us to use. These values (`0-5`) determine the aggressiveness of our scans. This can also have negative effects if the scan is too aggressive, and security systems may block us due to the produced network traffic. The default timing template used when we have defined nothing else is the normal (`-T 3`).

-   `-T 0` / `-T paranoid`
-   `-T 1` / `-T sneaky`
-   `-T 2` / `-T polite`
-   `-T 3` / `-T normal`
-   `-T 4` / `-T aggressive`
-   `-T 5` / `-T insane`

These templates contain options that we can also set manually, and have seen some of them already. The developers determined the values set for these templates according to their best results, making it easier for us to adapt our scans to the corresponding network environment. The exact used options with their values we can find here: [https://nmap.org/book/performance-timing-templates.html](https://nmap.org/book/performance-timing-templates.html)

#### Default Scan

```shell-session
badgersec@htb[/htb]$ sudo nmap 10.129.2.0/24 -F -oN tnet.default 

<SNIP>
Nmap done: 256 IP addresses (10 hosts up) scanned in 32.44 seconds
```

#### Insane Scan

```shell-session
badgersec@htb[/htb]$ sudo nmap 10.129.2.0/24 -F -oN tnet.T5 -T 5

<SNIP>
Nmap done: 256 IP addresses (10 hosts up) scanned in 18.07 seconds
```

#### Default Scan - Found Open Ports

```shell-session
badgersec@htb[/htb]$ cat tnet.default | grep "/tcp" | wc -l

23
```

#### Insane Scan - Found Open Ports

```shell-session
badgersec@htb[/htb]$ cat tnet.T5 | grep "/tcp" | wc -l

23
```

Next: [[Firewall and IDS IPS Evasion]]

