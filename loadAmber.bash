#!/bin/bash

###script to load vnd top + crd box

if [ $# -lt 2 ]
then
	echo "loadAmber.bash: require 2 args minium, top file and amber crdbox"
	exit
fi



top=$1
crds=""
for var in "$@"
do
    if [ "$var" != "$top" ]
    then
	crds=$(echo $crds $var) 
    fi
done

vmd -parm7 $top -e ~/utils/loadAmber.vmd -args $crds  


