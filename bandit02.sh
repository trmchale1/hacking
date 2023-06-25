#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass

pass_one=`cat pass.txt`

#echo $pass_one

level_two_pass=$(sshpass -p $pass_one ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit1@bandit.labs.overthewire.org 'cat ./-')

echo $level_two_pass >> "pass.txt"