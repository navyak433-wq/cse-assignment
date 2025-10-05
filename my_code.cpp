=#!/bin/bash

echo "Create branch:"
read b1
git branch $b1
echo "Branches now:"
git branch

echo "Enter branch to merge from:"
read b2
echo "Enter branch to merge into:"
read b3
git checkout $b3
git merge $b2

echo "Enter branch to rebase onto another:"
read r1
echo "Enter branch to rebase onto:"
read r2
git checkout $r1
git rebase $r2

echo "Enter branch to delete:"
read d
git branch -d $d 2>/dev/null || git branch -D $d

echo "Final branches:"
git branch
