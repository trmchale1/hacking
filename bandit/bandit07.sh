#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass

pass_seven="morbNTDkSW6jIlUc0ymOdMaLnOlFVAaj"

EIGHT_SCRIPT='grep millionth data.txt | cut -f 2'

level_eight_pass=$(sshpass -p $pass_seven ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit7@bandit.labs.overthewire.org "$EIGHT_SCRIPT")

echo $level_eight_pass