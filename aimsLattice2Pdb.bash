#!/bin/bash

if [ "$#" -lt "1" ]
then
    echo "$0 requires one arg, accepts two: aims geometry and pdb.  Adds cryst1 records to front of the pdb"
    exit
fi

##replace atom coordinates in a pdb from an xyz file.

inGeom=$1
inPdb=$2

cat $inGeom |\
    awk '/lattice_vector/{printf("%s %s %s ",$2,$3,$4)}' |\
    awk -v pi=3.14159265359 \
	'{a=sqrt($1*$1+$2*$2+$3*$3);\
          b=sqrt($4*$4+$5*$5+$6*$6);\
          c=sqrt($7*$7+$8*$8+$9*$9);\
          ab    =  $1*$4 + $2*$5 + $3*$6;\
          aXb_x =  $2*$6 - $3*$5;\
          aXb_y = -$1*$6 + $3*$4;\
          aXb_z =  $1*$5 - $2*$4;\
          aXb   =  sqrt(aXb_x*aXb_x+aXb_y*aXb_y+aXb_z*aXb_z);\
          gamma =  atan2(aXb, ab);\
          ac    =  $1*$7 + $2*$8 + $3*$9;\
          aXc_x =  $2*$9 - $3*$8;\
          aXc_y = -$1*$9 + $3*$7;\
          aXc_z =  $1*$8 - $2*$7;\
          aXc   =  sqrt(aXc_x*aXc_x+aXc_y*aXc_y+aXc_z*aXc_z);\
          beta  =  atan2(aXc, ac);\
          bc    =  $4*$7 + $5*$8 + $6*$9;\
          bXc_x =  $5*$9 - $6*$8;\
          bXc_y = -$4*$9 + $6*$7;\
          bXc_z =  $4*$8 - $5*$7;\
          bXc   =  sqrt(bXc_x*bXc_x+bXc_y*bXc_y+bXc_z*bXc_z);\
          alpha =  atan2(bXc, bc);\
          printf("CRYST1%9.3f%9.3f%9.3f%7.2f%7.2f%7.2f P 1  1 1      1\n",\
                  a,b,c,alpha*180/pi,beta*180/pi,gamma*180/pi)}'
if [ -s "$inPdb" ]
then
    cat $inPdb
fi
