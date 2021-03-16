#!/bin/bash

cpath=$(pwd)
clear

cp mppdyna MAT18
cd MAT18
mpirun -np 4 ./mppdyna i=ballistic.key &
cd $cpath

cp mppdyna UMAT
cd UMAT
mpirun -np 4 ./mppdyna i=ballistic.key &
cd $cpath
wait

lsprepost c=postprocess.cfile





