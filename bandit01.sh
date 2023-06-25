#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass

level_one_pass=$(sshpass -p "bandit0" ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit0@bandit.labs.overthewire.org 'cat readme')

echo $level_one_pass > "pass.txt"
