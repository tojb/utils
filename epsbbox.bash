#!/bin/bash
# bbget
# Get a bounding box and put it on the second line of the file.
if [ $# -lt 2 ] ; then
    echo Usage: $0 filein fileout [extrafiles]
    echo Put a bounding box on the second line of the file fileout.
else
#Remove previous bounding boxes.
 echo Removing the following BoundingBox lines:
 sed -n -e "/BoundingBox/!w temp.ps" -e "/BoundingBox/ p" $1 
 if [ $# -gt 2 ] ; then cat $3 $4 $5 >> temp.ps; fi
 if [ `fgrep -c showpage temp.ps` != "0" ] ; then
    echo "File has a showpage. No additions."
    showpage=""
 else
    echo "File has no showpage. I'll add one temporarily."
    showpage=' -c "showpage"'
 fi
#Get the BBox info to bb.out
 gs -sDEVICE=bbox -sNOPAUSE -q temp.ps $showpage -c quit 2> bb.out
#Read it in to the second line of the output ps file.
 sed -e"1 r bb.out" temp.ps > $2
 echo "Bounding Box Information:"
 cat bb.out
#Clean up.
 rm -f bb.out
 rm -f temp.ps
fi


