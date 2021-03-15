close all;clear;

% load cantilever data
load('SEmonotonous.mat');
alldata = ldata; clear ldata;

% find bounds
delta1 =( max(alldata(16,:)) - min(alldata(16,:)))/1000;
delta2 =( max(alldata(17,:)) - min(alldata(17,:)))/1000;
delta3 =( max(alldata(19,:)) - min(alldata(19,:)))/1000;

% i=10000;
orgdata = alldata;
tic
for i=1:size(alldata,2)
    
    t =  find( (alldata(16,:) <(alldata(16,i)+delta1)) &  (alldata(16,:)>(alldata(16,i)-delta1)) & ...
               (alldata(17,:) <(alldata(17,i)+delta2)) &  (alldata(17,:)>(alldata(17,i)-delta2)) & ...
               (alldata(19,:) <(alldata(19,i)+delta3)) &  (alldata(19,:)>(alldata(19,i)-delta3)) );
    
    [lia,loc] = ismember(i,t);
    if lia
        t(loc)=[];
    end
    % rewind i to account for deleted array entries
    bc=find(t<i);
    if ~isempty(bc)
        i=i-length(bc);
    end
    clear lia loc bc;
    alldata(:,t) = [];
    clear t;
    
    % check if array size has been reached
    if i>=size(alldata,2) 
        break
    end
    i
    size(alldata,2) 
end
toc
ldata=alldata;
save('SEmonotonous_filtered.mat','ldata','-v7.3');


