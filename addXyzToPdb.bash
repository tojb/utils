#!/bin/bash

if [ "$#" -lt "2" ]
then
    echo "$0 requires two args: inPdb and inXyz.  Replaces coords in pdb with xyz."
    exit
fi

##replace atom coordinates in a pdb from an xyz file.

inPdb=$1
inXyz=$2

##open file descriptors "5" and "6"
exec 3<$inPdb
exec 4<$inXyz

while [ 1 ] 
do
    read -u 3 pdbLine
    sstatus=$?
    isAtom=$(echo $pdbLine |\
	   awk 'BEGIN{is=0}\
               /ATOM/{is=1}END{print(is)}')
    if [ "$isAtom" -eq "1" ]
    then
        while [ 1 ] 
        do
	    read -u 4 xyzLine
	    status=$?
            if [ "$status" -ne "0" ]
	    then
		break
	    fi
	    
	    NF=$(echo $xyzLine | awk '{print NF}')
	    if [ "$NF" -eq "4" ]
	    then
		echo | awk -v l="$pdbLine" -v L="$xyzLine" \
		   '{split(L,xyz);x=xyz[2];y=xyz[3];z=xyz[4];\
                     printf("%s%8.3f%8.3f%8.3f%s\n",\
                         substr(l,1,30),x,y,z,substr(l,55))}'
		break
	    fi
        done 
    else
	echo "$pdbLine"
    fi
    
    if [ "$sstatus" -ne "0" ]
    then
	break
    fi
done 
