#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass


pass_three="MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx"

level_four_pass=$(sshpass -p $pass_three ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit3@bandit.labs.overthewire.org 'cd inhere && cat .hidden')

echo $level_four_pass