#!/bin/sh

check=$(pidof nginx)

if [ -z $check ]; then
    exit 1

else :
    exit 0
    
fi