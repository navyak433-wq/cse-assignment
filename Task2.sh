#!/bin/bash

num=$1
word=$2

if [ $((num % 15)) -eq 0 ]; then
    echo "tomcat"
elif [ $((num % 3)) -eq 0 ]; then
    echo "tom"
elif [ $((num % 5)) -eq 0 ]; then
    echo "cat"
else
    echo $num
fi

