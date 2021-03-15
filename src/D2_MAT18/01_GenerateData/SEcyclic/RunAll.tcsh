#!/bin/bash

cpath=$(pwd)
clear

cp materialcard1.key SR100
cp materialcard1.key SR200
cp materialcard1.key SR500

cd SR100
chmod 777 RunExtract.tcsh
./RunExtract.tcsh
cd "$cpath"
echo SR100 done

cd SR200
chmod 777 RunExtract.tcsh >logfile.txt
./RunExtract.tcsh
cd "$cpath"
echo SR200 done

cd SR500
chmod 777 RunExtract.tcsh >> logfile.txt
./RunExtract.tcsh
cd "$cpath"
echo SR500 done


