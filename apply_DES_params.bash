#!/bin/bash

inParm=$1
if [ -s "$inParm" ]
then
   echo "reading paramset from $inParm"
else
   echo "require input parm: .${inParm}. is not present"
   exit 1
fi

rm -f setDES.prmed

###define a pattern for charge modifications
chrg_pattern="BASE ATOM FF14 NEW"
declare -a cplist=(
"DC N4  -0.9530 -0.8716"
"DC H41 +0.4234 +0.3827"
"DC H42 +0.4234 +0.3827"
"DT N3  -0.3549 -0.3913"
"DT H3  +0.3154 +0.3518"
"DG N1  -0.4787 -0.5606"
"DG H1  +0.3424 +0.4243"
"DG N2  -0.9672 -1.0158"
"DG H21 +0.4364 +0.4607"
"DG H22 +0.4364 +0.4607"
"DA N1  -0.7615 -0.7969"
"DA H2  +0.0473 +0.0650"
"DA N6  -0.9019 -1.0088"
"DA H61 +0.4115 +0.4738"
"DA H62 +0.4115 +0.4738"
)
n_cp=${#cplist[@]}
for i in `seq 0 $[n_cp - 1]`
do 
   pattern=${cplist[$i]}
   echo "applying charge pattern $i: $pattern"
   echo $pattern |\
       awk '{printf("printDetails  :%s*@%s\n",$1,$2);\
             printf("change CHARGE :%s*@%s %s\n",$1,$2,$4)}' >> setDES.prmed
done

vdw_pattern="at_type sigma_old sigma_new eps_old eps_new master_mask"
declare -a vdwlist=(
"H   1.0691   0.0000  0.0157  0.0000 (:DG=@H1,H21,H22)|(:DA=@H61,H62)|(:DC=@H41,H42)|(:DT=@H3)"
"NA  3.2500   3.2890  0.1700  0.1700 (:DG=@N7,N9)|(:DA=@N1,N3,N7,N9)"
"NN  3.2500   3.3507  0.1700  0.1700 (:DG=@N1,N2,N3)|(:DA=@N6)|(:DT=@N1,N3)|(:DC=@N1,N3,N4)"
"CA  3.3997   3.3004  0.0860  0.0636 (:DA=@C2,C4,C5,C6,C8)"
"CN  3.3997   3.2850  0.0860  0.0538 (:DG=@C2,C4,C6,C6,C8)|(:DC=@C2,C4,C5,C6)|(:DT=@C2,C4,C5,C6)" 
)

##new name _ residue _ list of old names
declare -a atname_matches=(
"NN DG* @N1  @N2  @N3"
"CN DG* @C2  @C4  @C5 @C6 @C8"
"NA DG* @N7  @N9"
"H  DG* @H1  @H21 @H22"
"NA DA* @N1  @N3  @N7 @N9"
"NN DA* @N6" 
"CA DA* @C2  @C4  @C5 @C6 @C8"
"H  DA* @H61 @H62"
"NN DC* @N1  @N3  @N4"
"CN DC* @C2  @C4  @C5 @C6"
"H  DC* @H41 @H42"
"NN DT* @N1  @N3" 
"CN DT* @C2  @C4  @C5 @C6"
"NN DT* @N1  @N3" 
"H  DT* @H3"
)


n_vd=${#vdwlist[@]}
n_atpats=${#atname_matches[@]}
for i in `seq 0 $[n_vd - 1]`
do
   pattern=${vdwlist[$i]}
   echo "applying vdw pattern $i: $pattern"
   newAtName=$(echo $pattern | awk '{print $1}')
   regexp=$(echo $pattern  | awk '{print $NF}')
   ##parmed takes Rmin as input.
   ##the paper gives sigma: not the same.
   radius=$(echo $pattern  | awk '{print 0.5*(2**(1./6.))*$3}')
   epsilon=$(echo $pattern | awk '{print $5}')
   echo "printLJMatrix 1"                                   >> setDES.prmed
   echo "printDetails $regexp"                              >> setDES.prmed

   echo "addLJType $regexp radius $radius epsilon $epsilon" >> setDES.prmed
   echo "printDetails $regexp"                              >> setDES.prmed
   echo "printLJMatrix 1"                                   >> setDES.prmed
done
echo "parmout $1.des" >> setDES.prmed


rm -f $1.des
parmed $1 < setDES.prmed




