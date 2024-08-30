#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass

pass_four="2WmrDFRmJIq3IPxneAaMGhap0pFhF3NJ"

FIVE_SCRIPT="ls -p | grep -roh '^[A-Za-z0-9]*$'"

level_three_pass=$(sshpass -p $pass_four ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit4@bandit.labs.overthewire.org "cd inhere && $FIVE_SCRIPT")

# human-readable
# 1033 bytes in size
# not executable


echo $level_three_pass