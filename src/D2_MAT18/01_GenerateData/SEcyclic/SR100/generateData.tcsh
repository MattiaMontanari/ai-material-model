#!/bin/bash

cpath=$(pwd)
clear

declare -a DIRNAMES=("1x1x1_1Comp_SR100" "1x1x1_1Tens_SR100" "1x1x1_2Comp_SR100" "1x1x1_2Tens_SR100" "1x1x1_3Comp_SR100" "1x1x1_3Tens_SR100" "1x1x1_12SPos_SR100" "1x1x1_13SPos_SR100" "1x1x1_23SPos_SR100")

rm *.csv

for ((i=0; i<${#DIRNAMES[*]}; i++));
do
   BASEPATH=$cpath"/"${DIRNAMES[i]}
   KEYNAME=${DIRNAMES[i]}".key"
   cp materialcard1.key $BASEPATH
   cp mppdyna $BASEPATH
   cd $BASEPATH
   rm d3* bino*
   mpirun -np 1 ./mppdyna i=$KEYNAME &>/dev/null &
   cd $cpath
done

wait

for ((i=0; i<${#DIRNAMES[*]}; i++));
do
   BASEPATH=$cpath"/"${DIRNAMES[i]}
   SAVENAME1=$cpath"/"${DIRNAMES[i]}"_stress.csv"
   SAVENAME2=$cpath"/"${DIRNAMES[i]}"_strain.csv"
   SAVENAME3=$cpath"/"${DIRNAMES[i]}"_plasticity.csv"
   cp extractFromDynaD3plot.cfile $BASEPATH
   cd $BASEPATH
   lsprepost -nographics c=extractFromDynaD3plot.cfile
   #lsprepost -nographics c=process.cfile
   cp element_stress.csv $SAVENAME1
   cp element_strain.csv $SAVENAME2
   cp plasticity.csv $SAVENAME3
   cd $cpath
done

# process data
matlab -nodesktop -nodisplay -r "ExtractStressStrainCyclic,exit"
