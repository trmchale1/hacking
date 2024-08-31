#! /bin/sh

apt-get update
apt-get install -y ssh
apt-get install -y sshpass

pass_twelve="7x16WNeHIi5YkIhWsfFIqoognUTyj9Q4"

## Too complex, used xxd, tar -xf, gzip, bzip2 to decompress the file

# For GZIP compressed files the header is \x1F\x8B\x08
# For BZIP the header is 425a, in the next byte 68 is the version

#bandit12@bandit:~$ cd /tmp
#bandit12@bandit:/tmp$ mktemp -d
#/tmp/tmp.W5t1vua6G9
#bandit12@bandit:/tmp$ cd /tmp/tmp.W5t1vua6G9
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ cp ~/data.txt .
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ ls
#data.txt
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ mv data.txt hexdump_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ ls
#hexdump_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ xxd -r hexdump_data compressed_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ ls
#compressed_data  hexdump_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ cat hexdump_data 
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ mv compressed_data compressed_data.gz
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ ls
#compressed_data.gz  hexdump_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ gzip -d compressed_data.gz 
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ ls
#compressed_data  hexdump_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ xxd compressed_data 
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ mv compressed_data compressed_data.bz2
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ ls
#compressed_data.bz2  hexdump_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ bzip2 -d compressed_data.bz2
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ mv compressed_data compressed_data.gz
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ gzip -d compressed_data.gz
#andit12@bandit:/tmp/tmp.W5t1vua6G9$ mv compressed_data compressed_data.tar
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ tar -xf compressed_data.tar 
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ ls
#compressed_data.tar  data5.bin  hexdump_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ tar -xf data5.bin
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ xxd data6.bin 
#00000000: 425a 6839 3141 5926 5359 080c 2b0b 0000  BZh91AY&SY..+...
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ bzip2 -d data6.bin
#bzip2: Can't guess original name for data6.bin -- using data6.bin.out
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ ls
#compressed_data.tar  data5.bin  data6.bin.out  hexdump_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ tar -xf data6.bin.out
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ ls
#compressed_data.tar  data5.bin  data6.bin.out  data8.bin  hexdump_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ xxd data8.bin
#00000000: 1f8b 0808 0650 b45e 0203 6461 7461 392e  .....P.^..data9.
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ mv data8.bin data8.gz
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ gzip -d data8.gz
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ ls
#compressed_data.tar  data5.bin  data6.bin.out  data8  hexdump_data
#bandit12@bandit:/tmp/tmp.W5t1vua6G9$ cat data8
#The password is 8ZjyCRiBWFYkneahHwxCv3wb2a1ORpYL