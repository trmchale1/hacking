#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass

pass_thirteen="FO5dwFsc0cbaIiH0h8J2eUks2vdTDwAn"

# run scp -P 2220 bandit13@bandit.labs.overthewire.org:sshkey.private .