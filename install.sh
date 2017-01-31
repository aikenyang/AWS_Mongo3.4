#!/bin/bash
#0.1 preparation, get the config files form github/S3/shared folder
#example:
sudo yum install -y git
#git clone https://github.com/aikenyang/Mongo3.4.git
#for AWS diff parts
git clone https://github.com/aikenyang/AWS_Mongo3.4.git

#0.2 preparation, disk config
sudo mkdir /data;sudo mkfs -t ext4 /dev/xvdb;sudo mount -t ext4 /dev/xvdb /data;
sudo echo "/dev/xvdb /data ext4 defaults,auto,noatime 0 0" >> /etc/fstab

#1. change OS ulimit, /etc/security/limits.conf
#verify, ulimit -a
cd \AWS_Mongo3.4
sudo \cp -f limits.conf /etc/security/limits.conf

#2. change OS 90 nproc, /etc/security/limits.d/90-nproc.conf
sudo \cp -f 90-nproc.conf /etc/security/limits.d/90-nproc.conf

#3. change OS 85 rule, /etc/udev/rules.d/85-ebs.rules
#verify, sudo blockdev --report, sudo blockdev --getra /dev/sdb
#change the rule to meet current setting
sudo \cp -f 85-ebs.rules /etc/udev/rules.d/85-ebs.rules

#4. disable Transparent_Huge_Pages (THP)
#4.1 Create the init.d script.
sudo \cp -f disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
#4.2 Make it executable.
sudo chmod 755 /etc/init.d/disable-transparent-hugepages
#4.3 Configure your operating system to run it on boot.
sudo chkconfig --add disable-transparent-hugepages

#5. Change OS sysctl, /etc/sysctl.confca
#diff -u -B <(grep -vE '^\s*(#|$)' /etc/sysctl.conf)  <(grep -vE '^\s*(#|$)' sysctl.conf)
#\cp -f sysctl.conf /etc/sysctl.conf

#6. Change OS repository, /etc/yum.repos.d/mongodb-org-3.0.repo
sudo \cp -f mongodb-org-3.4.repo /etc/yum.repos.d/mongodb-org-3.4.repo

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
sudo rpm -ivh mongodb-org-server-3.4.1-1.amzn1.x86_64.rpm
sudo rpm -ivh mongodb-org-mongos-3.4.1-1.amzn1.x86_64.rpm
sudo rpm -ivh mongodb-org-shell-3.4.1-1.amzn1.x86_64.rpm
sudo rpm -ivh mongodb-org-tools-3.4.1-1.amzn1.x86_64.rpm
sudo rpm -ivh mongodb-org-3.4.1-1.amzn1.x86_64.rpm

#20. replace/modify /etc/mongod.conf
sudo \cp -f mongod.conf /etc/mongod.conf

#21. keyfile
#/data/keyfile
sudo \cp abctest /data/keyfile
sudo chmod 600 /data/keyfile

#22. folder owner
sudo chown -R mongod:mongod /data

#22. start mongod service
#sudo service mongod start
#or
#sudo mongod /usr/bin/mongod -f /etc/mongod.conf

#23. in mongo shell, config replica set

#24. in mongo shell, create accounts