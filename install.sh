#!/bin/bash
#running as root

#0 preparation: git, swap, disk
#0.1 preparation, get the config files form github/S3/shared folder

yum install -y git
#git clone https://github.com/aikenyang/Mongo3.4.git
git clone https://github.com/aikenyang/AWS_Mongo3.4.git

#0.2 preparation, create swap
dd if=/dev/zero of=/mnt/swapfile bs=2048 count=1048576
chmod 600 /mnt/swapfile
/sbin/mkswap /mnt/swapfile
/sbin/swapon /mnt/swapfile
echo "/mnt/swapfile swap swap defaults 0 0" >> /etc/fstab

#0.3 preparation, disk config
yum install -y xfsprogs
mkdir /data
mkfs.xfs -f /dev/xvdb
mount -t xfs /dev/xvdb /data
echo "/dev/xvdb /data xfs defaults,auto,noatime 0 0" >> /etc/fstab

#1. change OS ulimit, /etc/security/limits.conf
#verify, ulimit -a
cd \AWS_Mongo3.4
\cp -f limits.conf /etc/security/limits.conf

#2. change OS 90 nproc, /etc/security/limits.d/90-nproc.conf
\cp -f 90-nproc.conf /etc/security/limits.d/90-nproc.conf

#3. change OS 85 rule, /etc/udev/rules.d/85-ebs.rules
#verify, blockdev --report, blockdev --getra /dev/sdb
#change the rule to meet current setting
\cp -f 85-ebs.rules /etc/udev/rules.d/85-ebs.rules

#4. disable Transparent_Huge_Pages (THP)
#4.1 Create the init.d script.
\cp -f disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
#4.2 Make it executable.
chmod 755 /etc/init.d/disable-transparent-hugepages
#4.3 Configure your operating system to run it on boot.
chkconfig --add disable-transparent-hugepages

#5. Change OS sysctl, /etc/sysctl.confca
#diff -u -B <(grep -vE '^\s*(#|$)' /etc/sysctl.conf)  <(grep -vE '^\s*(#|$)' sysctl.conf)
#\cp -f sysctl.conf /etc/sysctl.conf

#6. Change OS repository, /etc/yum.repos.d/mongodb-org-3.0.repo
\cp -f mongodb-org-3.4.repo /etc/yum.repos.d/mongodb-org-3.4.repo

#10. download Mongo3.4 RPM
#https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/
#----------------------for AWS
#https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/RPMS/

wget https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/RPMS/mongodb-org-3.4.1-1.amzn1.x86_64.rpm
wget https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/RPMS/mongodb-org-mongos-3.4.1-1.amzn1.x86_64.rpm
wget https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/RPMS/mongodb-org-server-3.4.1-1.amzn1.x86_64.rpm
wget https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/RPMS/mongodb-org-shell-3.4.1-1.amzn1.x86_64.rpm
wget https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/RPMS/mongodb-org-tools-3.4.1-1.amzn1.x86_64.rpm

#11. install Mongo3.4 RPM
rpm -ivh mongodb-org-server-3.4.1-1.amzn1.x86_64.rpm
rpm -ivh mongodb-org-mongos-3.4.1-1.amzn1.x86_64.rpm
rpm -ivh mongodb-org-shell-3.4.1-1.amzn1.x86_64.rpm
rpm -ivh mongodb-org-tools-3.4.1-1.amzn1.x86_64.rpm
rpm -ivh mongodb-org-3.4.1-1.amzn1.x86_64.rpm

#20. replace/modify /etc/mongod.conf
\cp -f mongod.conf /etc/mongod.conf

#21. keyfile
#/data/keyfile
\cp abctest /data/keyfile
chmod 600 /data/keyfile

#22. folder owner
chown -R mongod:mongod /data

#23. start mongod service
service mongod start
#or
#mongod /usr/bin/mongod -f /etc/mongod.conf

#24. in mongo shell, config replica set

#25. in mongo shell, create accounts