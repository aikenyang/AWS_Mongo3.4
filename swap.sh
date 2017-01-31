#!/bin/bash
# Program:
#	MongoDB create swap space.
# History:
# 2014/04/29	First release
# run as root
dd if=/dev/zero of=/mnt/swapfile bs=2048 count=1048576
chmod 600 /mnt/swapfile
/sbin/mkswap /mnt/swapfile
/sbin/swapon /mnt/swapfile
echo "/mnt/swapfile swap swap defaults 0 0" >> /etc/fstab
free -m
