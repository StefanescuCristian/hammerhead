#!/bin/bash
prev=$(cat .prev_commit)
git log | head -n1 | grep commit | awk '{print $2}' > .last_commit
last=$(cat .last_commit)
sed -i "s/$prev/$last/g" drivers/misc/build_commit.c
cp -f .last_commit .prev_commit
