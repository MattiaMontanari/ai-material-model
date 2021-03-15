%% load stress strain data from csv files
clear; close all;

ncpu= 10;

% update keyfiles
status = copyfile('update_key.sh','JOBS/update_key.sh');
cd JOBS
!./update_key.sh
cd ..
%% get file names for Normal cases
files = dir('JOBS/*.key');

% sort int stress and strain filenames by elements
for i=1:length(files)
    temp = strsplit(files(i).name,'.');
    % create directory
    mkdir(temp{1,1})
    status = copyfile([files(i).folder,'/',files(i).name], temp{1,1});
    if ~status
        error('Could not copy key file');
    end    
end



fid = fopen('runenvelope.sh','w');

fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'clear\n');

fprintf(fid,'cpath=$(pwd)\n');
fprintf(fid,'logname=$cpath"/logfile.txt"\n');
fprintf(fid,'scriptname=$cpath"/extractFromDyna.cfile"\n');
 



fprintf(fid,'declare -a DIRNAMES1=(');
count1=1;
count2=1;
for i=1:length(files)
    temp = strsplit(files(i).name,'.');
    % write name into scriptfile
    fprintf(fid,[' "',temp{1,1},'"']);
    count1=count1+1;
    if count1==ncpu
        count2=count2+1;
        fprintf(fid,')\n');
        fprintf(fid,['declare -a DIRNAMES',num2str(count2),'=(']);
        count1=1;
    end
end
fprintf(fid,')\n');
fprintf(fid,'#==============================================================\n');
fprintf(fid,'# RUN JOBS\n');
fprintf(fid,'#==============================================================\n');

for i=1:count2
    fprintf(fid,'\n');
    fprintf(fid,['for ((i=0; i<${#DIRNAMES',num2str(i),'[*]}; i++));\n']);
    fprintf(fid,'do \n');
    fprintf(fid,['   BASEPATH=$cpath"/"${DIRNAMES',num2str(i),'[i]} \n']);
    fprintf(fid,['   KEYNAME=${DIRNAMES',num2str(i),'[i]}".key" \n']);
    fprintf(fid,'   cp materialcard1.key $BASEPATH \n');
    fprintf(fid,'   cp mppdyna $BASEPATH \n');
    fprintf(fid,'   cd $BASEPATH \n');
    fprintf(fid,'   rm d3* \n');
    fprintf(fid,'   rm bino* \n');
    fprintf(fid,'   mpirun -np 1 ./mppdyna i=$KEYNAME &>/dev/null & \n');
    fprintf(fid,'   cd $cpath \n');
    fprintf(fid,'done \n');
    fprintf(fid,'wait \n');
    fprintf(fid,'\n');
end

fprintf(fid,'#==============================================================\n');
fprintf(fid,'# EXTRACT DATA\n');
fprintf(fid,'#==============================================================\n');


for i=1:count2
    fprintf(fid,'\n');
    fprintf(fid,['for ((i=0; i<${#DIRNAMES',num2str(i),'[*]}; i++));\n']);
    fprintf(fid,'do\n');
    fprintf(fid,['   cp extractFromDyna.cfile ${DIRNAMES',num2str(i),'[i]}\n']);
    fprintf(fid,['   cd ${DIRNAMES',num2str(i),'[i]}\n']);
    fprintf(fid,'if [ -f results.csv ]; then rm results.csv; fi\n');
    fprintf(fid,'   lsprepost -nographics c=extractFromDyna.cfile &>/dev/null & \n');
    fprintf(fid,'   cd $cpath\n');
    fprintf(fid,'done\n');
    fprintf(fid,'wait \n');
    fprintf(fid,'   \n');
end

fprintf(fid,'#==============================================================\n');
fprintf(fid,'# MOVE DATA\n');
fprintf(fid,'#==============================================================\n');

fprintf(fid,'counter=0\n');
fprintf(fid,'if [ -d "RESULTS" ]; then rm -Rf "RESULTS"; fi\n');
fprintf(fid,'mkdir RESULTS\n');
for i=1:count2
    fprintf(fid,'\n');
    fprintf(fid,['for ((i=0; i<${#DIRNAMES',num2str(i),'[*]}; i++));\n']);
    fprintf(fid,'do\n');
    fprintf(fid,['   cd ${DIRNAMES',num2str(i),'[i]}\n']);
    fprintf(fid,'   counter=$((counter+1))\n');
    fprintf(fid,'   SAVENAME1=$cpath"/RESULTS/result_"$counter".csv"\n');
    fprintf(fid,'   cp results.csv $SAVENAME1\n');
    fprintf(fid,'   rm mppdyna\n');
    fprintf(fid,'   rm d3* \n');
    fprintf(fid,'   rm bino* \n');
    fprintf(fid,'   cd $cpath\n');
    fprintf(fid,'done\n');
    fprintf(fid,'   \n');
end

fclose(fid);
