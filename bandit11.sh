#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass


for LINE in $(cat pass.txt)
do
    pass_nine=$LINE
done

ELEVEN_SCRIPT='base64 -d data.txt | cut -d " " -f 4'


level_eleven_pass=$(sshpass -p $pass_nine ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit10@bandit.labs.overthewire.org "$ELEVEN_SCRIPT")


echo $level_eleven_pass >> "pass.txt"