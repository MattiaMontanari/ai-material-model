#!/bin/bash

cpath=$(pwd)
clear

declare -a DIRNAMES=("1x1x1_12SNeg_SR500" "1x1x1_12SPos_SR500" "1x1x1_13SNeg_SR500" "1x1x1_13SPos_SR500" "1x1x1_1Comp_SR500" "1x1x1_1Tens_SR500" "1x1x1_23SNeg_SR500" "1x1x1_23SPos_SR500" "1x1x1_2Comp_SR500" "1x1x1_2Tens_SR500" "1x1x1_3Comp_SR500" "1x1x1_3Tens_SR500")

# run Dyna simulation
for ((i=0; i<${#DIRNAMES[*]}; i++));
do
   RUNPATH=$cpath"/"${DIRNAMES[i]}
   KEYFILE=${DIRNAMES[i]}".key"
   cp mppdyna $RUNPATH
   cp materialcard1.key $RUNPATH 
   cd $RUNPATH
   mpirun -np 1 ./mppdyna i=$KEYFILE
   cd $cpath
done

# extract data
for ((i=0; i<${#DIRNAMES[*]}; i++));
do
   BASEPATH=$cpath"/"${DIRNAMES[i]}
   SAVENAME1=$cpath"/"${DIRNAMES[i]}"_stress.csv"
   SAVENAME2=$cpath"/"${DIRNAMES[i]}"_strain.csv"
   SAVENAME3=$cpath"/"${DIRNAMES[i]}"_plasticity.csv"
   cp extractFromDyna.cfile $BASEPATH
   cd $BASEPATH
   lsprepost -nographics c=extractFromDyna.cfile
   cp element_stress.csv $SAVENAME1
   cp element_strain.csv $SAVENAME2
   cp plasticity.csv $SAVENAME3
   cd $cpath
done

# process data
matlab -nodesktop -nodisplay -r "extractStressStrain,exit"


