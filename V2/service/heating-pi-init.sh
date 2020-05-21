#!/bin/bash
i=0
curl http://localhost/test || ((i=i+1))
curl http://localhost:5000/test || ((i=i+1))
if [ $i -eq 0 ]; then
    exit 0
fi
exit 1
