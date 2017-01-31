#!/bin/bash
# Program:
#	mongod.log log rotation and delete old logs before 60 days 
# 2014/05/15	first release
# 2014/05/26	remove log files before 90 days

datebf=$(date --date='90 days ago' +%Y%m%d)

date
/usr/bin/mongo -u padmin -p inIt1234 admin << 'EOF'
db.runCommand({logRotate:1});
EOF

find /mongodb/log -not -newermt $datebf -delete