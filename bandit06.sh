#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass


for LINE in $(cat pass.txt)
do
    pass_five=$LINE
done

level_three_pass=$(sshpass -p $pass_five ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit5@bandit.labs.overthewire.org 'cat ./inhere/maybehere07/.file2')


echo $level_three_pass >> "pass.txt"