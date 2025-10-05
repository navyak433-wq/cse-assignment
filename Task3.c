#!/bin/bash

fruits=("apple" "banana" "cherry" "mango" "orange")

for f in "${fruits[@]}"
do
    echo "Scanning inventory... Found: $f"
    echo "$f is fresh and ready!"
done
