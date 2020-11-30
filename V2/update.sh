#!/bin/bash
status=`git pull --recurse-submodules`
if [[ $status == "Already up to date." ]]; then
    echo "No updates found"
else
    ./install.sh
fi
