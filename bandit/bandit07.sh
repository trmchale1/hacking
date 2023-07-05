#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass


for LINE in $(cat pass.txt)
do
    pass_six=$LINE
done

SEVEN_SCRIPT='cat $(find / -user bandit7 -group bandit6 -size 33c 2>/dev/null)'

level_seven_pass=$(sshpass -p $pass_six ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit6@bandit.labs.overthewire.org "$SEVEN_SCRIPT")

echo $level_seven_pass >> "pass.txt"