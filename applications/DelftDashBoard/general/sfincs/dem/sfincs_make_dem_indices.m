clear variables;close all;

dr='d:\temp\vanGundula\sfincs_charleston_large_v01\';
topofile='d:\projects\cfrss\database2\charleston\charleston_ncei_14m.mat';

s2=load(topofile);

demx=s2.parameters(1).parameter.x(1,:);  % must be an 1xn vector
demy=s2.parameters(1).parameter.y(:,1)'; % must be an 1xn vector
demz=s2.parameters(1).parameter.val;

clear s2

inpfile=[dr 'sfincs.inp'];
outfile='d:\charleston_large_ncei_14m_indices.dat'; % Name of indices file that will be used
cs_dem.name='WGS 84';
cs_dem.type='geographic';
cs_sfincs.name='WGS 84 / UTM zone 17N';
cs_sfincs.type='projected';

% Write indices file
sfincs_write_indices_for_dem(inpfile,outfile,demx,demy,cs_dem,cs_sfincs);
