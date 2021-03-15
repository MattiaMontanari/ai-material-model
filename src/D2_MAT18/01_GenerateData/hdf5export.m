clear;close all;
% HDF5 export
hdfname = 'TrainingData.hdf5';
delete(hdfname);

%%-------------------------------------------------------------------------
% Single elment monontonous loading
load(['SEmonotonous' filesep 'SR100' filesep 'SEmonotonous.mat']);
sem=ldata; clear ldata;
% export monotonous data to hdf5
h5create(hdfname,'/SE/monotonous/SR100/input',[3 size(sem,2)]);
h5write(hdfname,'/SE/monotonous/SR100/input',sem([16 17 19],:));
h5create(hdfname,'/SE/monotonous/SR100/output',[1 size(sem,2)]);
h5write(hdfname,'/SE/monotonous/SR100/output',sem(14,:));
clear sem;

load(['SEmonotonous' filesep 'SR200' filesep 'SEmonotonous.mat']);
sem=ldata; clear ldata;
% export monotonous data to hdf5
h5create(hdfname,'/SE/monotonous/SR200/input',[3 size(sem,2)]);
h5write(hdfname,'/SE/monotonous/SR200/input',sem([16 17 19],:));
h5create(hdfname,'/SE/monotonous/SR200/output',[1 size(sem,2)]);
h5write(hdfname,'/SE/monotonous/SR200/output',sem(14,:));
clear sem;

load(['SEmonotonous' filesep 'SR500' filesep 'SEmonotonous.mat']);
sem=ldata; clear ldata;
% export monotonous data to hdf5
h5create(hdfname,'/SE/monotonous/SR500/input',[3 size(sem,2)]);
h5write(hdfname,'/SE/monotonous/SR500/input',sem([16 17 19],:));
h5create(hdfname,'/SE/monotonous/SR500/output',[1 size(sem,2)]);
h5write(hdfname,'/SE/monotonous/SR500/output',sem(14,:));
clear sem;

%%-------------------------------------------------------------------------
% Single element cyclic data
load(['SEcyclic' filesep 'SR100' filesep 'singleElementCyclic.mat']);
sec=ldata; clear ldata;
% export cyclic data to hdf5
h5create(hdfname,'/SE/cyclic/SR100/input',[3 size(sec,2)]);
h5write(hdfname,'/SE/cyclic/SR100/input',sec([16 17 19],:));
h5create(hdfname,'/SE/cyclic/SR100/output',[1 size(sec,2)]);
h5write(hdfname,'/SE/cyclic/SR100/output',sec(14,:));
clear sec;

load(['SEcyclic' filesep 'SR200' filesep 'singleElementCyclic.mat']);
sec=ldata; clear ldata;
% export cyclic data to hdf5
h5create(hdfname,'/SE/cyclic/SR200/input',[3 size(sec,2)]);
h5write(hdfname,'/SE/cyclic/SR200/input',sec([16 17 19],:));
h5create(hdfname,'/SE/cyclic/SR200/output',[1 size(sec,2)]);
h5write(hdfname,'/SE/cyclic/SR200/output',sec(14,:));
clear sec;

load(['SEcyclic' filesep 'SR500' filesep 'singleElementCyclic.mat']);
sec=ldata; clear ldata;
% export cyclic data to hdf5
h5create(hdfname,'/SE/cyclic/SR500/input',[3 size(sec,2)]);
h5write(hdfname,'/SE/cyclic/SR500/input',sec([16 17 19],:));
h5create(hdfname,'/SE/cyclic/SR500/output',[1 size(sec,2)]);
h5write(hdfname,'/SE/cyclic/SR500/output',sec(14,:));
clear sec;

%%-------------------------------------------------------------------------
% Single element multiaxial loading
load(['SEmultiaxial' filesep '1112' filesep 'SEmultiaxial_filterred.mat']);
sema=ldata; clear ldata;
load(['SEmultiaxial' filesep '1113' filesep 'SEmultiaxial_filterred.mat']);
sema= [sema ldata]; clear ldata;
load(['SEmultiaxial' filesep '1122' filesep 'SEmultiaxial_filterred.mat']);
sema= [sema ldata]; clear ldata;
load(['SEmultiaxial' filesep '1133' filesep 'SEmultiaxial_filterred.mat']);
sema= [sema ldata]; clear ldata;
load(['SEmultiaxial' filesep '2212' filesep 'SEmultiaxial_filterred.mat']);
sema= [sema ldata]; clear ldata;
load(['SEmultiaxial' filesep '2223' filesep 'SEmultiaxial_filterred.mat']);
sema= [sema ldata]; clear ldata;
load(['SEmultiaxial' filesep '2233' filesep 'SEmultiaxial_filterred.mat']);
sema= [sema ldata]; clear ldata;
load(['SEmultiaxial' filesep '3313' filesep 'SEmultiaxial_filterred.mat']);
sema= [sema ldata]; clear ldata;
load(['SEmultiaxial' filesep '3323' filesep 'SEmultiaxial_filterred.mat']);
sema= [sema ldata]; clear ldata;

% export multiaxial data to hdf5
h5create(hdfname,'/SE/multiaxial/input',[3 size(sema,2)]);
h5write(hdfname,'/SE/multiaxial/input',sema([16 17 19],:));
h5create(hdfname,'/SE/multiaxial/output',[1 size(sema,2)]);
h5write(hdfname,'/SE/multiaxial/output',sema(14,:));
clear sema;

info = h5info(hdfname);
