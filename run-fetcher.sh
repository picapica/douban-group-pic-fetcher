#!/bin/bash
cd `dirname $0`

while true
do
    date
    ruby douban-group.rb
    sleep 31
done >> .std.out
