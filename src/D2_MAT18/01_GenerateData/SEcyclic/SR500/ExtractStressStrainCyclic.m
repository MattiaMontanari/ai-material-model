%% load stress strain data from csv files
clear, close all;

ldata = zeros(20,1);

%% get file names for Normal cases
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
        stressfile{count1} = [files(i).name]; 
    elseif strcmp('strain',temp2{1,4})
        count2=count2+1;
        strainfile{count2} = [files(i).name];
    elseif  strcmp('plasticity',temp2{1,4})
        count3=count3+1;
        plastfile{count3} = [files(i).name];
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
     data{i} = zeros(20,size(temp,1));
     tdata = zeros(20,size(temp,1));
     steps = size(temp(:,1),1);
     data{i}(1,:) = temp(:,1); % time
     data{i}(2,:) = temp(:,2); % sigx
     data{i}(3,:) = temp(:,4); % sigy
     data{i}(4,:) = temp(:,7); % sigz
     data{i}(5,:) = temp(:,3); % sigxy
     data{i}(6,:) = temp(:,5); % sigyz
     data{i}(7,:) = temp(:,6); % sigxz
     tdata(1:7,1:size(temp,1)) = data{i}(1:7,:);
     clear temp;
     % read out strain
     temp = csvread(strainfile{i},2);
     data{i}(8,:)  = temp(:,2); % epsx
     data{i}(9,:)  = temp(:,3); % epsy
     data{i}(10,:) = temp(:,4); % epsz
%      data{i}(11,:) = temp(:,3); % epsxy
%      data{i}(12,:) = temp(:,5); % epsyz
%      data{i}(13,:) = temp(:,6); % epsxz
     data{i}(11,:) = temp(:,5).*2; % gammaxy
     data{i}(12,:) = temp(:,6).*2; % gammayz
     data{i}(13,:) = temp(:,7).*2; % gammaxz
     tdata(8:13,1:size(temp,1)) = data{i}(8:13,:);
     clear temp;
     % read out plastic strain and effective stress
     temp = csvread(plastfile{i},2);
     %temp(size(temp,1),:) = [];
     data{i}(14,:) = temp(:,2);  % plastic strain
     data{i}(15,:) = temp(:,3);  % effective stress
     for k=2:size(data{i}(16,:),2)
         data{i}(16,k) = data{i}(14,k-1); % previous plastic strain
         data{i}(17,k) = data{i}(15,k-1); % previous eff stress
         data{i}(18,k) = data{i}(14,k)-data{i}(14,k-1); % plast strain increment
     end
     
     % effective strain increment
     d1 = diff(data{i}(8,:));
     d2 = diff(data{i}(9,:));
     d3 = diff(data{i}(10,:));
     d4 = diff(data{i}(11,:));
     d5 = diff(data{i}(12,:));
     d6 = diff(data{i}(13,:));
     eps = 2/3 *sqrt((1.5*(d1.^2.+d2.^2.+d3.^2) + 0.75*(d4.^2.+d5.^2.+d6.^2 )));
     data{i}(19,2:end) = eps;
     clear d1 d2 d3 d4 d5 d6 eps;
     data{i}(20,:) = sqrt(0.5*( ... 
                        (data{i}(2,:)-data{i}(3,:)).^2 + ...
                        (data{i}(3,:)-data{i}(4,:)).^2 + ...
                        (data{i}(4,:)-data{i}(2,:)).^2 + ...
                      6*(data{i}(5,:).^2+data{i}(6,:).^2+data{i}(7,:).^2 )));
                   
     
     
     tdata(14:20,1:size(temp,1)) = data{i}(14:20,:);
     
     count=count+steps-2;
     
     if 0
     % filter duplications based on effective stress and effective stress increment
     delta1 =( max(tdata(16,:)) - min(tdata(16,:)))/1000;
     delta2 =( max(tdata(17,:)) - min(tdata(17,:)))/1000;
     delta3 =( max(tdata(19,:)) - min(tdata(19,:)))/1000;
     k=0;
     kend = size(tdata,1);
     while (k<kend)
        k=k+1;
        % find similar elements
        t =  find( (tdata(16,:) <(tdata(16,k)+delta1)) &  (tdata(16,:)>(tdata(16,k)-delta1)) & ...
                   (tdata(17,:) <(tdata(17,k)+delta2)) &  (tdata(17,:)>(tdata(17,k)-delta2)) & ...
                   (tdata(19,:) <(tdata(19,k)+delta3)) &  (tdata(19,:)>(tdata(19,k)-delta3)));
        % exclude current k from list
        [lia,loc] = ismember(k,t);
        if lia
            t(loc)=[];
        end
        % rewind k to account for deleted array entries
        bc=find(t<k);
        if ~isempty(bc)
            k=k-length(bc);
        end
        clear lia loc bc;
        tdata(:,t) = [];
        clear t;
        % update loop end definition
        kend = size(tdata,2);
        
    end

    end

    ldata = [ldata tdata];
    clear tdata;
    [stressfile{i},' done']
end

clear data stressfile strainfile plastfile files;


ldata(:,1) = [];


save('singleElementCyclic.mat','ldata','-v7.3');
% h5create('cantilever2.hdf5','cantilever2',[size(ldata,1) size(ldata,2)]);
% h5write('cantilever2.hdf5','cantilever2',ldata);



%figure(3)
%plot3(ldata(16,:),ldata(17,:),ldata(19,:),'o');
