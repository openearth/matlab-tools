clear all;close all;

a=dir('mat-files\*.mat');

EPSG=[];
for i=1:length(a)
    fname = a(i).name
    load(['mat-files\' fname]);
    ff    = fname(1:end-4);
    EPSG  = setfield(EPSG,ff,trf);
end

save EPSG.mat EPSG


