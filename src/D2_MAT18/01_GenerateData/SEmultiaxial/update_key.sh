#!/bin/bash

directory=$(pwd)
suffix="key"
sstring='../..'
rstring='..'
browsefolders (){
  for i in "$1"/*; 
  do
    #echo "dir :$directory"
    #echo "filename: $i" e
    #   echo ${i#*.}
    extension=`echo "$i" | cut -d'.' -f2`
    #echo "Extension $extension"
    if     [ -f "$i" ]; then        

        if [ $extension == $suffix ]; then
            echo "$i ends with $extension"
            #dos2unix $i
            sed -i "s:$sstring:$rstring:" $i

        fi
    elif [ -d "$i" ]; then  
    browsefolders "$i"
    fi
  done
}
browsefolders  "$directory"
