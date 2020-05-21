#!/bin/bash
i=0
curl -s http://localhost:5000/test  || ((i=i+1))
curl -s http://localhost/test || ((i=i+1))
if [ $i -ne 0 ]; then
    exit 1
fi
