# 0Zf11ioIjMVN551jX3CmStKLYqjk54Ga

# Screen 1

#bandit23@bandit:~$ mkdir /tmp/code
#bandit23@bandit:~$ cd /tmp/code
#bandit23@bandit:/tmp/code$ vim file.sh
#bandit23@bandit:/tmp/code$ chmod o+x file.sh
#bandit23@bandit:/tmp/code$ ls -l
#total 4
#-rw-rw-r-x 1 bandit23 bandit23 68 Sep  2 00:40 file.sh
#bandit23@bandit:/tmp/code$ chmod o+w .
#bandit23@bandit:/tmp/code$ touch password.txt
#bandit23@bandit:/tmp/code$ chmod o+w password.txt
#bandit23@bandit:/tmp/code$ ls
#file.sh  password.txt
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:44 .
#drwxrwx-wt 892 root     root     11063296 Sep  2 00:46 ..
#-rw-rw-r-x   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#-rw-rw-rw-   1 bandit23 bandit23        0 Sep  2 00:44 password.txt
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:44 .
#drwxrwx-wt 894 root     root     11063296 Sep  2 00:49 ..
#-rw-rw-r-x   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#-rw-rw-rw-   1 bandit23 bandit23        0 Sep  2 00:44 password.txt
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:44 .
#drwxrwx-wt 894 root     root     11063296 Sep  2 00:49 ..
#-rw-rw-r-x   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#-rw-rw-rw-   1 bandit23 bandit23        0 Sep  2 00:44 password.txt
#bandit23@bandit:/tmp/code$ cat file.sh
##!/bin/bash
#
#cat /etc/bandit_pass/bandit24 > /tmp/code/password.txt
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ cat file.sh
##!/bin/bash
#
#cat /etc/bandit_pass/bandit24 > /tmp/code/password.txt
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:44 .
#drwxrwx-wt 894 root     root     11063296 Sep  2 00:50 ..
#-rw-rw-r-x   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#-rw-rw-rw-   1 bandit23 bandit23        0 Sep  2 00:44 password.txt
#bandit23@bandit:/tmp/code$ rm password.txt
#bandit23@bandit:/tmp/code$ ls
#file.sh
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ ls
#file.sh
#bandit23@bandit:/tmp/code$ 
#bandit23@bandit:/tmp/code$ ls
#file.sh
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:51 .
#drwxrwx-wt 895 root     root     11063296 Sep  2 00:52 ..
#-rw-rw-r-x   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#bandit23@bandit:/tmp/code$ chmod +rwx file.sh
#bandit23@bandit:/tmp/code$ chmod 777 file.sh
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:51 .
#drwxrwx-wt 900 root     root     11063296 Sep  2 00:58 ..
#-rwxrwxrwx   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:51 .
#drwxrwx-wt 900 root     root     11063296 Sep  2 00:58 ..
#-rwxrwxrwx   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#bandit23@bandit:/tmp/code$ cat file.sh
##!/bin/bash
#
#cat /etc/bandit_pass/bandit24 > /tmp/code/password.txt
#bandit23@bandit:/tmp/code$ cat file.sh
##!/bin/bash
#
#cat /etc/bandit_pass/bandit24 > /tmp/code/password.txt
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:51 .
#drwxrwx-wt 900 root     root     11063296 Sep  2 00:59 ..
#-rwxrwxrwx   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#bandit23@bandit:/tmp/code$ touch password.txt
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:59 .
#drwxrwx-wt 902 root     root     11063296 Sep  2 01:00 ..
#-rwxrwxrwx   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#-rw-rw-r--   1 bandit23 bandit23        0 Sep  2 00:59 password.txt
#bandit23@bandit:/tmp/code$ cat password.txt
#bandit23@bandit:/tmp/code$ chmod o+w password.txt
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:59 .
#drwxrwx-wt 903 root     root     11063296 Sep  2 01:01 ..
#-rwxrwxrwx   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#-rw-rw-rw-   1 bandit23 bandit23        0 Sep  2 00:59 password.txt
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:59 .
#drwxrwx-wt 903 root     root     11063296 Sep  2 01:01 ..
#-rwxrwxrwx   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#-rw-rw-rw-   1 bandit23 bandit23        0 Sep  2 00:59 password.txt
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 00:59 .
#drwxrwx-wt 903 root     root     11063296 Sep  2 01:01 ..
#-rwxrwxrwx   1 bandit23 bandit23       68 Sep  2 00:40 file.sh
#-rw-rw-rw-   1 bandit23 bandit23        0 Sep  2 00:59 password.txt
#bandit23@bandit:/tmp/code$ cat password.txt
#bandit23@bandit:/tmp/code$ mv file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ cat password.txt
#bandit23@bandit:/tmp/code$ ls -la
#total 10812
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 01:02 .
#drwxrwx-wt 903 root     root     11063296 Sep  2 01:03 ..
#-rw-rw-rw-   1 bandit23 bandit23        0 Sep  2 00:59 password.txt
#bandit23@bandit:/tmp/code$ cat password.txt
#bandit23@bandit:/tmp/code$ chmod 777 password.txt
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#cp: cannot stat 'file.sh': No such file or directory
#bandit23@bandit:/tmp/code$ ls
#password.txt
#bandit23@bandit:/tmp/code$ vim file.sh
#bandit23@bandit:/tmp/code$ vim file.sh
#bandit23@bandit:/tmp/code$ vim file.sh
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ chmod o+w file.sh
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 01:11 .
#drwxrwx-wt 910 root     root     11063296 Sep  2 01:12 ..
#-rw-rw-rw-   1 bandit23 bandit23       69 Sep  2 01:11 file.sh
#-rwxrwxrwx   1 bandit23 bandit23        0 Sep  2 00:59 password.txt
#bandit23@bandit:/tmp/code$ cat password.txt
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ cat password.txt
#bandit23@bandit:/tmp/code$ ls -la
#total 10816
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 01:11 .
#drwxrwx-wt 910 root     root     11063296 Sep  2 01:13 ..
#-rw-rw-rw-   1 bandit23 bandit23       69 Sep  2 01:11 file.sh
#-rwxrwxrwx   1 bandit23 bandit23        0 Sep  2 00:59 password.txt
#bandit23@bandit:/tmp/code$ chmod 777 .
#bandit23@bandit:/tmp/code$ chmod 777 file.sh
#bandit23@bandit:/tmp/code$ chmod 777 password.txt
#bandit23@bandit:/tmp/code$ cp file.sh /var/spool/bandit24/foo
#bandit23@bandit:/tmp/code$ ls -la
#total 10820
#drwxrwxrwx   2 bandit23 bandit23     4096 Sep  2 01:11 .
#drwxrwx-wt 911 root     root     11063296 Sep  2 01:14 ..
#-rwxrwxrwx   1 bandit23 bandit23       69 Sep  2 01:11 file.sh
#-rwxrwxrwx   1 bandit23 bandit23       33 Sep  2 01:14 password.txt
#bandit23@bandit:/tmp/code$ cat password.txt
#gb8KRRCsshuZXI0tUuR6ypOFjiZbf3G8

#Screen 2

#bandit23@bandit:~$ cd /etc/cron.d
#bandit23@bandit:/etc/cron.d$ ls
#cronjob_bandit22  cronjob_bandit23  cronjob_bandit24  e2scrub_all  otw-tmp-dir  sysstat
#bandit23@bandit:/etc/cron.d$ cat cronjob_bandit24
#@reboot bandit24 /usr/bin/cronjob_bandit24.sh &> /dev/null
#* * * * * bandit24 /usr/bin/cronjob_bandit24.sh &> /dev/null
#bandit23@bandit:/etc/cron.d$ cat /usr/bin/cronjob_bandit24.sh
##!/bin/bash
#
#myname=$(whoami)
#
#cd /var/spool/$myname/foo
#echo "Executing and deleting all scripts in /var/spool/$myname/foo:"
#for i in * .*;
#do
#    if [ "$i" != "." -a "$i" != ".." ];
#    then
#        echo "Handling $i"
#        owner="$(stat --format "%U" ./$i)"
#        if [ "${owner}" = "bandit23" ]; then
#            timeout -s 9 60 ./$i
#        fi
#        rm -f ./$i
#    fi
#done
#
#bandit23@bandit:/etc/cron.d$ ls
#cronjob_bandit22  cronjob_bandit23  cronjob_bandit24  e2scrub_all  otw-tmp-dir  sysstat
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rw-rw-r-x 1 bandit23 bandit23 68 Sep  2 00:48 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rw-rw-r-x 1 bandit23 bandit23 68 Sep  2 00:49 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rw-rw-r-x 1 bandit23 bandit23 68 Sep  2 00:49 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rw-rw-r-x 1 bandit23 bandit23 68 Sep  2 00:51 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rw-rw-r-x 1 bandit23 bandit23 68 Sep  2 00:51 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rw-rw-r-x 1 bandit23 bandit23 68 Sep  2 00:51 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:58 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:58 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:58 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:58 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:58 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:58 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:58 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:58 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:58 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:58 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:59 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ 
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:59 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:59 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:59 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 00:59 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 01:01 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 01:01 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 68 Sep  2 01:01 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxrwx 1 bandit23 bandit23 68 Sep  2 00:40 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxrwx 1 bandit23 bandit23 68 Sep  2 00:40 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rw-rw-r-- 1 bandit23 bandit23 69 Sep  2 01:11 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rw-rw-r-- 1 bandit23 bandit23 69 Sep  2 01:11 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rw-rw-r-- 1 bandit23 bandit23 69 Sep  2 01:12 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 69 Sep  2 01:13 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#-rwxrwxr-x 1 bandit23 bandit23 69 Sep  2 01:13 /var/spool/bandit24/foo/file.sh
#bandit23@bandit:/etc/cron.d$ ls -l /var/spool/bandit24/foo/file.sh
#ls: cannot access '/var/spool/bandit24/foo/file.sh': No such file or directory
#bandit23@bandit:/etc/cron.d$ 

# gb8KRRCsshuZXI0tUuR6ypOFjiZbf3G8