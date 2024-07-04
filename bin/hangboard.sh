#!/bin/bash


for i in $(seq 1 10);
do
  say $i
  sleep 3
  afplay /System/Library/Sounds/Tink.aiff
  afplay /System/Library/Sounds/Tink.aiff
  afplay /System/Library/Sounds/Tink.aiff
  afplay /System/Library/Sounds/Ping.aiff
  sleep 10
  afplay /System/Library/Sounds/Ping.aiff
  sleep 35
done
