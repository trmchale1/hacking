# tRae0UfB9v0UzbCdn9cY0gQnds9GF58Q

#bandit22@bandit:~$ tRae0UfB9v0UzbCdn9cY0gQnds9GF58Q^C
#bandit22@bandit:~$ ls -la /etc/cron.d
#total 44
#drwxr-xr-x   2 root root  4096 Jul 17 15:59 .
#drwxr-xr-x 121 root root 12288 Aug  1 14:49 ..
#-rw-r--r--   1 root root   120 Jul 17 15:57 cronjob_bandit22
#-rw-r--r--   1 root root   122 Jul 17 15:57 cronjob_bandit23
#-rw-r--r--   1 root root   120 Jul 17 15:57 cronjob_bandit24
#-rw-r--r--   1 root root   201 Apr  8 14:38 e2scrub_all
#-rwx------   1 root root    52 Jul 17 15:59 otw-tmp-dir
#-rw-r--r--   1 root root   102 Mar 31 00:06 .placeholder
#-rw-r--r--   1 root root   396 Jan  9  2024 sysstat
#bandit22@bandit:~$ cat /etc/cron.d/cronjob_bandit23
#@reboot bandit23 /usr/bin/cronjob_bandit23.sh  &> /dev/null
#* * * * * bandit23 /usr/bin/cronjob_bandit23.sh  &> /dev/null
#bandit22@bandit:~$ cat /usr/bin/cronjob_bandit23.sh
##!/bin/bash
#
#myname=$(whoami)
#mytarget=$(echo I am user $myname | md5sum | cut -d ' ' -f 1)
#
#echo "Copying passwordfile /etc/bandit_pass/$myname to /tmp/$mytarget"
#
#cat /etc/bandit_pass/$myname > /tmp/$mytarget
#bandit22@bandit:~$ echo I am user $myname | md5sum | cut -d ' ' -f 1
#7db97df393f40ad1691b6e1fb03d53eb
#bandit22@bandit:~$ cat /tmp/7db97df393f40ad1691b6e1fb03d53eb
#cat: /tmp/7db97df393f40ad1691b6e1fb03d53eb: No such file or directory
#bandit22@bandit:~$ cd /tmp
#bandit22@bandit:/tmp$ ls
#ls: cannot open directory '.': Permission denied
#bandit22@bandit:/tmp$ cd
#bandit22@bandit:~$ echo I am user bandit23 | md5sum | cut -d ' ' -f 1
#8ca319486bfbbc3663ea0fbe81326349
#bandit22@bandit:~$ cat /tmp/8ca319486bfbbc3663ea0fbe81326349
#0Zf11ioIjMVN551jX3CmStKLYqjk54Ga

# 0Zf11ioIjMVN551jX3CmStKLYqjk54Ga