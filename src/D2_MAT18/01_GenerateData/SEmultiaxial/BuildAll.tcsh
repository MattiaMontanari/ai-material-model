#!/bin/bash

cpath=$(pwd)
clear


declare -a DIRNAMES=("1112" "1113" "1122" "1133" "2212" "2223" "2233" "3313" "3323")

for ((i=0; i<${#DIRNAMES[*]}; i++));
do
   # Copy all scripting and processing files
   cp update_key.sh ${DIRNAMES[i]}
   cp extractFromDyna.cfile ${DIRNAMES[i]}
   cp scriptgenerate.m ${DIRNAMES[i]}
   cp materialcard1.key ${DIRNAMES[i]}
   cp extractStressStrainMultiaxial.m ${DIRNAMES[i]} 
   cd ${DIRNAMES[i]}
   # remove all directories in this folder
   rm -R -- */ 
   # generate test cases
   VTLbuild.tcsh
   # prepare runs and print script
   chmod 777 update_key.sh
   matlab -nodesktop -nodisplay -r "scriptgenerate,exit"
   # run script (this will run the jobs and extract the data from DYNA
   rm -r JOBS
   cd "$cpath"
done
