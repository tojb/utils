#!/bin/bash


if [ $# -ne 2 ] 
then
	echo "countatom: require args: atomname, topfile"
	exit
fi

atName=$1
topFile=$2



awk -v a="$atName" 'BEGIN{c=0}/a/{for(i=1;i<=NF;i++){if($i==a){c++}}}/FLAG CHARGE/{print c;exit}' $topFile


