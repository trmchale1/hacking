#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass


pass_two="263JGJPfgU6LtdEvgfWU1XP5yac29mFx"

level_three_pass=$(sshpass -p $pass_two ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit2@bandit.labs.overthewire.org 'cat /home/bandit2/spaces\ in\ this\ filename')

echo $level_three_pass