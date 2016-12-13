#!/bin/bash
# resets the Mains ethernet adapter to ensure connectivity
gpio -g write 24 0
sleep 10
gpio -g write 24 1
