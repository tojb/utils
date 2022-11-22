#!/bin/bash



particles=$(head -2 $1 | tail -1 | awk '{print $2}')

bytes=$(ls -l $1 | awk '{print $5}')

#lines=$(wc -l $1 | awk '{print $1}')
#frames=$(echo $lines $[particles + 2] | awk '{print $1/$2}')

headerBytes=102
frames=$(echo $[bytes - $headerBytes] $[particles * 76 + 2] | awk '{print $1/$2}')


echo counted about $frames frames


