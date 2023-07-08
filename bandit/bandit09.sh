#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass


for LINE in $(cat pass.txt)
do
    pass_eight=$LINE
done

NINE_SCRIPT='sort data.txt | uniq -u'

level_nine_pass=$(sshpass -p $pass_eight ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit8@bandit.labs.overthewire.org "$NINE_SCRIPT")

echo $level_nine_pass >> "pass.txt"