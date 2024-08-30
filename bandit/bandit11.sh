#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass


pass_twelve="dtR173fZKb0RRsDFSGsg2RWnpNVj3qRr"

TWELVE_SCRIPT='cat data.txt | tr "A-Za-z" "N-ZA-Mn-za-m" | cut -d " " -f 4'

level_twelve_pass=$(sshpass -p $pass_twelve ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit11@bandit.labs.overthewire.org "$TWELVE_SCRIPT")

echo $level_twelve_pass
