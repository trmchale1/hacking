#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass


for LINE in $(cat pass.txt)
do
    pass_nine=$LINE
done

TEN_SCRIPT='strings data.txt | grep ========= | tail -1 | cut -d " " -f 2'


level_ten_pass=$(sshpass -p $pass_nine ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit9@bandit.labs.overthewire.org "$TEN_SCRIPT")


echo $level_ten_pass >> "pass.txt"