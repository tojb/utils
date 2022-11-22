#!/bin/bash


pdb=$1

avogadro="6.02214179e23"

molesWaterPerLitre="55.55"
tip3pMolesPerLitre="53.4759"

countNa=$(grep -e "K+" -e "Na" $pdb | wc -l | awk '{print $1}')
countCl=$(grep -e "Cl-"   $pdb | wc -l | awk '{print $1}')
countBr=$(grep -e "BR"    $pdb | wc -l | awk '{print $1}')
countW=$(grep  "O   WAT"  $pdb | wc -l | awk '{print $1}')
countEt=$(grep "C1  ET"   $pdb | wc -l | awk '{print $1}')
countArg=$(grep "N   ARG" $pdb | wc -l | awk '{print $1}')
echo Na: $countNa Cl: $countCl Wat: $countW Et: $countEt BR: $countBr Arg: $countArg
echo $countNa  $countW $molesWaterPerLitre $countCl | \
 awk '{molesNaPerMolesWater=$1/$2;molesClPerMolesWater=$4/$2;\
       molesNaPerLitreWater=molesNaPerMolesWater*$3;molesClPerLitreWater=molesClPerMolesWater*$3;\
       print "molesNa", molesNaPerLitreWater, "molesCl", molesClPerLitreWater }'

for c in "$countNa Na" "$countCl Cl" "$countBr BR" "$countEt Et" "$countArg Arg"
do

    echo $c | awk -v Cw=$molesWaterPerLitre -v cw=$countW \
               '{perW=$1/cw;molPerL=perW*Cw;chemPot=log(perW);\
                 printf("%s  %e mol/l  mu= %e kBT\n", $2, molPerL, chemPot)}'

done

