#!/bin/bash

if [ $# -eq 0 ] 
then
    echo 'extract last or arbitrary frame of etj trajectory'
    echo 'usage: etjFrameExt filename <framenumber, default 0==last>'
fi

if [ $# -eq 2 ] 
then
    frameNumber=$2
else
    frameNumber=0
fi



headerLines=8
tailLines=2
separatorNewlines=2

particles=$(head -2 $1 | tail -1 | awk '{print $2}')

head -$headerLines $1

if [ $frameNumber -eq 0 ]
then
    tail -$[particles + $tailLines + $separatorNewlines] $1
else
    frameSkip=$(echo $particles $tailLines $separatorNewlines $frameNumber $headerLines |  awk '{print ($1+$2+$3)*$4+$5}')
    head -$frameSkip $1 | tail -$[particles + $tailLines + $separatorNewlines]
fi


