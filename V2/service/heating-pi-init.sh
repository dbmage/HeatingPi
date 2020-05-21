#!/bin/bash
apachepid=0
while true; do
    newpid=0
    if [ -f /var/run/apache2/apache2.pid ]; then
        newpid=`cat /var/run/apache2/apache2.pid`
    fi
    if [ "$newpid" -eq "$apachepid" ]; then
        continue
    fi
    i=0
    curl -s http://localhost:5000/test  || ((i=i+1))
    curl -s http://localhost/test || ((i=i+1))
    if [ $i -ne 0 ]; then
        break
    fi
    apachepid=$newpid
done
exit 1
