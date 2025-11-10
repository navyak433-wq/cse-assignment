#!/bin/bash

# Check if parameters are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <param1> <param2>"
  exit 1
fi

PARAM1=$1
PARAM2=$2

echo "-------------------------------"
echo "Running shell script via Jenkins"
echo "-------------------------------"
echo "Parameter 1: $PARAM1"
echo "Parameter 2: $PARAM2"
echo

# Example work — tu yahan kuch bhi likh sakta hai
echo "Listing current directory:"
ls -l

echo "Creating a new file with both params..."
echo "Values: $PARAM1 and $PARAM2" > output.txt

echo "File created successfully!"
cat output.txt

echo "✅ Script executed successfully!"
