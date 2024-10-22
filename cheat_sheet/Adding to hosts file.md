The /etc/hosts file is used to resolve a hostname into an IP address. By default the /etc/hosts file is queried before the DNS server for hostname resolution thus we will need tp add an entry in the file for this domain to enable the browser to resolve the address.

```
echo "10.129.227.248 thetoppers.htb" | sudo tee -a /etc/hosts
```

```
echo "{target_ip} ignition.htb" | sudo tee -a /etc/hosts
```

