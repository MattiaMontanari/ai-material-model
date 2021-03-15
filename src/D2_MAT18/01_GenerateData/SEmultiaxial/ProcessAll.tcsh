#!/bin/bash

cpath=$(pwd)
clear


declare -a DIRNAMES=("1112" "1113" "1122" "1133" "2212" "2223" "2233" "3313" "3323")

for ((i=0; i<${#DIRNAMES[*]}; i++));
do
   # Copy all scripting and processing files
   cp update_key.sh ${DIRNAMES[i]}
   cp extractFromDyna.cfile ${DIRNAMES[i]}
   cp materialcard1.key ${DIRNAMES[i]}
   cp extractStressStrainMultiaxial.m ${DIRNAMES[i]} 
   cp mppdyna ${DIRNAMES[i]} 
   cd ${DIRNAMES[i]}
   chmod 777 update_key.sh
   # run script (this will run the jobs and extract the data from DYNA
   rm -r JOBS
   chmod 777 runenvelope.sh
   ./runenvelope.sh
   # process data
   matlab -nodesktop -nodisplay -r "extractStressStrainMultiaxial,exit"
   cd "$cpath"
done
