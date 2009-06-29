%%ArcGisRead - read data from Arc Gis Ascii file and convert to mat file
function [data]=ArcGisRead(fname,varargin)
fi=fopen(fname);
%% Read header
s=fgetl(fi)
[tmp rest]=strtok(s);
data.ncols=str2num(rest)
s=fgetl(fi)
[tmp rest]=strtok(s);
data.nrows=str2num(rest)
s=fgetl(fi)
[tmp rest]=strtok(s);
data.xllcorner=str2num(rest)
s=fgetl(fi)
[tmp rest]=strtok(s);
data.yllcorner=str2num(rest)
s=fgetl(fi)
[tmp rest]=strtok(s);
data.cellsize=str2num(rest)
s=fgetl(fi)
[tmp rest]=strtok(s);
data.NODATA_value=str2num(rest)
%% Read data
i=0;
s=1
while ~(s==-1)
    s=fgetl(fi);
    if ~(s==-1)
        i=i+1;
        data.val(i,:)=str2num(s);
        % [tmp rest]=strtok(s,'/');
    end
end
data.val(data.val==data.NODATA_value)=nan;
%% Create grid
for i=1:data.ncols
    for j=1:data.nrows
        data.x(i)=data.xllcorner+(i-.5)*data.cellsize;
        data.y(j)=data.yllcorner+((data.nrows-1)-(j-.5))*data.cellsize;
    end
end
%% Plot data
figure
pcolor(data.x,data.y,data.val);
shading flat;axis equal;colorbar;
%% Write to .mat file
root=strtok(fname,'.');
matname=[root '.mat'];
save(matname,'data') 