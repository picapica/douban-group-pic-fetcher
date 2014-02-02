#!/bin/bash
cd `dirname $0`
mkdir -p newpic

while true
do
    date
    cat .std.out | grep '^http' | sort -r | uniq > .urls; aria2c -i .urls -c -d newpic
    sleep 1
done
