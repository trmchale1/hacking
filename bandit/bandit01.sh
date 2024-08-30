#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass

pass_one="ZjLjTmM6FvvyRnrb2rfNWOZOTa6ip5If"

level_two_pass=$(sshpass -p $pass_one ssh bandit1@bandit.labs.overthewire.org -p 2220 'cat ./-')

echo $level_two_pass