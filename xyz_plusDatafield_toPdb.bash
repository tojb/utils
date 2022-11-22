#!/bin/bash

if [ "$#" -lt 1 ]
then
    echo "got $# args: 1 arg == xyz to pdb"
    echo "             2 args == xyz + datafile to pdb with data in charge field"
    exit 1
fi


file=$1
if [ "$#" -eq 2 ]
then
    data=$2
else
    data=""
fi


##centre, and save the first frame of $file as a pdb

cat $file $data |\
    awk          'BEGIN{c=0;cc=0}\
                    END{pdbOut();exit}\
             NF==1&&c>0{getData=1}\
      getData==1&&NF==1{d[cc]=$1;cc+=1}\
 function pdbOut(){print "REMARK read",cc,"data fields";for(i=0;i<c;i++){\
     strx=sprintf("%8.3f",x[i]);while(length(strx)<8){strx=" "+strx};if(length(strx)>8){strx=substr(strx,1,8)}\
     stry=sprintf("%8.3f",y[i]);while(length(stry)<8){stry=" "+stry};if(length(stry)>8){stry=substr(stry,1,8)}\
     strz=sprintf("%8.3f",z[i]);while(length(strz)<8){strz=" "+strz};if(length(strz)>8){strz=substr(strz,1,8)}\
     if(cc>=1){ii=int(i/2);\
          if(ii>=cc){ii=2*cc-ii-1}strchg=sprintf("%6.2f",100*d[int(ii)])}\
     else{print cc; strchg="+1.00"}\
     printf("HETATM %4i  %c   LIG     1    %s%s%s %s  0.00           %c\n", i+1,a[i],strx,stry,strz,strchg,a[i])}
     printf("END\nENDMDL\n");c=0;}\
      NR==1{print "AUTHOR    AHT:",$0}\
      $1=="C"||$1=="P"{a[c]=$1;x[c]=$2;y[c]=$3;z[c]=$4;c++}' 
   
 
