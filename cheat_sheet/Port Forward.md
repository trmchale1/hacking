
- -L specifies port forwarding

- user@victim_ip specifies where the ssh will connect to

- port 8080 is the victim port
- port 8081 is the local ip that will be port forwarded to, for example if I curl http://victim_ip:8080, it would be the same as a curl to http://localhost:8081 

`ssh -L 8081:localhost:8080 user@victim_ip`