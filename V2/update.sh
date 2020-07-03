#!/bin/bash
status=`git pull`
if [[ $status == "Already up to date." ]]; then
    echo "No updates found"
else
    ./install.sh
fi
