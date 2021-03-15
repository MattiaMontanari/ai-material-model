%% load stress strain data from csv files
clear, close all;
varnum = 19;
ldata = zeros(varnum,1);

% get file names
files = dir('*.csv');
%count=0;
data=cell(length(files),1);
for i=1:length(files)
    %count=count+1;     
    % read out data
    temp = csvread(files(i).name,2);
    steps = size(temp(:,1),1);
    data{i} = zeros(size(temp,1),varnum);
    
    data{i}(:,1) = temp(:,1); % time
    data{i}(:,2) = temp(:,8); % sigxx
    data{i}(:,3) = temp(:,9); % sigyy
    data{i}(:,4) = temp(:,10); % sigzz
    data{i}(:,5) = temp(:,11); % sigxy
    data{i}(:,6) = temp(:,12); % sigyz
    data{i}(:,7) = temp(:,13); % sigxz
    data{i}(:,8) = temp(:,2); % epsxx
    data{i}(:,9) = temp(:,3); % epsyy
    data{i}(:,10) = temp(:,4); % epszz
%     data{i}(:,11) = temp(:,5); % epsxy
%     data{i}(:,12) = temp(:,6); % epsyz
%     data{i}(:,13) = temp(:,7); % epsxz
    data{i}(:,11) = temp(:,5).*2; % gammaxy
    data{i}(:,12) = temp(:,6).*2; % gammayz
    data{i}(:,13) = temp(:,7).*2; % gammaxz
    
    data{i}(:,14) = temp(:,14); % plastic strain
    data{i}(:,15) = temp(:,15); % effective stress (von Mieses)
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
    data{i}(2:end,19) = eps;
    clear d1 d2 d3 d4 d5 d6 eps;
    
    tdata = data{i}(:,1:end);
    tdata = tdata';
    
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
    
    ldata = [ldata tdata];
    
    clear temp tdata
    %count=count+steps-2;
    i
    
end
ldata(:,1)=[];
save('SEmultiaxial_filterred.mat','ldata','-v7.3');
% h5create('cantilever2.hdf5','cantilever2',[size(ldata,1) size(ldata,2)]);
% h5write('cantilever2.hdf5','cantilever2',ldata);


% some plotting
% figure('units','normalized','outerposition',[0 0 1 1]); % make full screen
% sp(1) = subplot(1,3,1);hold all;
% plot3(ldata(17,:),ldata(19,:),ldata(14,:),'bo');hold on;
% view(45,20);
% sp(2) = subplot(1,3,2);hold all;
% plot3(ldata(17,:),ldata(16,:),ldata(14,:),'bo');hold on;
% view(45,20);
% sp(3) = subplot(1,3,3);hold all;
% plot3(ldata(19,:),ldata(16,:),ldata(14,:),'bo');hold on;
% view(45,20);
% xlabel(sp(1),'17');
% ylabel(sp(1),'19');
% zlabel(sp(1),'14');
% xlabel(sp(2),'17');
% ylabel(sp(2),'16');
% zlabel(sp(2),'14');
% xlabel(sp(3),'19');
% ylabel(sp(3),'16');
% zlabel(sp(3),'14');
