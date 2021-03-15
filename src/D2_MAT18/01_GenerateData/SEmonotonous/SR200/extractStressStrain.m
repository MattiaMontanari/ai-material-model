%% load stress strain data from csv files
clear, close all;
varnum = 19;
ldata = zeros(1,varnum);
% get file names
files = dir('*.csv');
% sort int stress and strain filenames by elements
count1=0;
count2=0;
count3=0;
for i=1:length(files)
    temp = strsplit(files(i).name,'.');
    temp2 = strsplit(temp{1,1},'_');
    if strcmp('stress',temp2{1,4})
        count1=count1+1;
        stressfile{count1} = files(i).name; 
    elseif strcmp('strain',temp2{1,4})
        count2=count2+1;
        strainfile{count2} = files(i).name;
    elseif  strcmp('plasticity',temp2{1,4})
        count3=count3+1;
        plastfile{count3} = files(i).name;
    end
end
if length(stressfile)~=length(strainfile)
    error('Data not read correctly. There seem to be a different number of stress and strain files');
end
clear temp temp2;
% run through files and extract data into array sorted by element number
data = cell(length(stressfile),1);

count=0;
for i=1:length(stressfile)
     count=count+1; 
     % read out stress
     temp = csvread(stressfile{i},2);
     steps = size(temp(:,1),1);
     data{i} = zeros(size(temp,1),varnum);
     data{i}(:,1) = temp(:,1);
     data{i}(:,2) = temp(:,2);
     data{i}(:,3) = temp(:,4);
     data{i}(:,4) = temp(:,7);
     data{i}(:,5) = temp(:,3);
     data{i}(:,6) = temp(:,5);
     data{i}(:,7) = temp(:,6);
     %ldata(count:count+steps-2,1:7) = data{i}(2:end,1:7);
     clear temp
     % read out strain
     temp = csvread(strainfile{i},2);
     data{i}(:,8)  = temp(:,2);
     data{i}(:,9)  = temp(:,4);
     data{i}(:,10) = temp(:,7);
     data{i}(:,11) = temp(:,3).*2;
     data{i}(:,12) = temp(:,5).*2;
     data{i}(:,13) = temp(:,6).*2;
     %ldata(count:count+steps-2,8:13) = data{i}(2:end,8:13);
     clear temp;
     % read out plastic strain and effective stress
     temp = csvread(plastfile{i},2);
     temp(size(temp,1),:) = [];
     data{i}(:,14) = temp(:,2);  % plastic strain
     data{i}(:,15) = temp(:,3);  % effective stress
     % calculate deltas
%      data{i}(:,16) = 0;
%      data{i}(:,17) = 0;
     for k=2:size(data{i}(:,16),1)
         data{i}(k,16) = data{i}(k-1,14); % previous plastic strain
         data{i}(k,17) = data{i}(k-1,15); % previous eff stress
         data{i}(k,18) = data{i}(k,14)-data{i}(k-1,14); % plast strain increment
     end
     % effective strain increment
     d1 = diff(data{i}(:,8));
     d2 = diff(data{i}(:,9));
     d3 = diff(data{i}(:,10));
     d4 = diff(data{i}(:,11));
     d5 = diff(data{i}(:,12));
     d6 = diff(data{i}(:,13));
     eps = 2/3 *sqrt((1.5*(d1.^2.+d2.^2.+d3.^2) + 0.75*(d4.^2.+d5.^2.+d6.^2 )));  
     data{i}(2:end,19) = eps;                                                      % effective strain increment
     clear d1 d2 d3 d4 d5 d6 eps;
     % yield stress
     % current
     %data{i}(1,20) = 270;  % initial yield stress
     % previous
     %for k=2:size(data{i}(:,20),1)
     %   data{i}(k,20) = max(data{i}(k-1,20),data{i}(k,15)); % current yield stress
     %   data{i}(k,21) = data{i}(k-1,20); % previous yield stress
     %end
     ldata(count:count+steps-2,1:varnum) = data{i}(2:end,1:varnum);
     count=count+steps-2;
     i
end
ldata = ldata';
save('SEmonotonous.mat','ldata','-v7.3');


