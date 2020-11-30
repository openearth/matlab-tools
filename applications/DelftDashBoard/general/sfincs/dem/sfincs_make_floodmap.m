clear variables;close all;

dr='d:\PhD\sfincs_tests\subgrid\charleston\run01\';
topofile='charleston_ncei_14m.mat';

matfile=[dr 'sfincs.mat'];

s2=load(topofile);

demx=s2.parameters(1).parameter.x(1,:);  % must be an 1xn vector
demy=s2.parameters(1).parameter.y(:,1)'; % must be an 1xn vector
demz=s2.parameters(1).parameter.val;

clear s2

inpfile='sfincs.inp';
outfile='charleston_ncei_14m_indices.dat'; % Name of indices file that will be used
cs_dem.name='WGS 84';
cs_dem.type='geographic';
cs_sfincs.name='WGS 84 / UTM zone 18N';
cs_sfincs.type='projected';

% % Write indices file (this need to be done only once!)
sfincs_write_indices_for_dem(inpfile,outfile,demx,demy,cs_dem,cs_sfincs);

% Read indices file
[indices,ndem,mdem]=sfincs_read_indices_for_dem(outfile);

% Load sfincs output
s=load(matfile);
zs=s.parameters(1).parameter.val(:,1:end-1,1:end-1);
zsmax=squeeze(max(zs,[],1));

zsmax_dem=sfincs_get_values_for_dem(zsmax,indices,ndem,mdem);

[xx,yy]=meshgrid(demx,demy);

inan=find(demz<1.0 | zsmax_dem-demz<0.2); % Don't plot data with bed level below 1 or with water depth below 0.2
hh=zsmax_dem-demz;
hh(inan)=NaN; % Don't plot data with bed level below 1
zsmax_dem(inan)=NaN; % Don't plot data with bed level below 1

figure(1)
pcolor(xx,yy,zsmax_dem);shading flat;axis equal;colorbar;title('max water level');
colormap('jet');caxis([0 6]);

figure(2)
pcolor(xx,yy,hh);shading flat;axis equal;colorbar;title('max water depth');
colormap('jet');caxis([0 6]);


hh=flipud(hh); % y direction should be from north to south for geotiff
hh=round(hh*100); % Convert to cm

x0=min(xx);
x1=max(xx);
y0=min(yy);
y1=max(yy);

bbox=[x0 y0;x1 y1];
bit_depth=8;
tiffile=['h_' name '.tif'];
geotiffwrite(tiffile, bbox, hh, bit_depth);
