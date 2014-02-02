#!/bin/bash
cd `dirname $0`

while true
do
    date
    ruby douban-group.rb
    sleep 3
done >> .std.out
