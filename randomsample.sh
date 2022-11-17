#!/bin/bash

execution_pre(){
    cd /tmp/
    touch perms.txt
    chmod 444 perms.txt
    ls -l perms.txt
}

write_pre(){
    cd /tmp/
    touch perms.txt
    chmod 200 perms.txt
    ls -l perms.txt
}
read_pre(){
    cd /tmp/
    touch perms.txt
    chmod 040 perms.txt
    ls -l perms.txt
}

while read -r line
do
choice=$line

case $choice in

  1) execution_pre;;
  2) write_pre;;
  3) read_pre;;
  *) echo "wrong presmission";;
 esac
done

