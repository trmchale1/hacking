#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass

pass_five="4oQYVPkxZOOEOO5pTW81FB8j8lxXGUQw"

SIX_SCRIPT='cat $(find ./ -type f -readable ! -executable -size 1033c)'

level_six_pass=$(sshpass -p $pass_five ssh -p 2220 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X bandit5@bandit.labs.overthewire.org "cd inhere && $SIX_SCRIPT")

echo $level_six_pass