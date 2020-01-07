%% SFINCS input options, formats and examples in Matlab
% v1.0  Leijnse    Dec-19
%%%%%
% Contents:
% - Create general SFINCS structure
% - Creating data for a mask-file
% - Index/Mask/Depth file
% - Make flow boundaries 
% - Make discharge points
% - Add wind & precipitation 
% - Thin dam file
% - Weir file
% - Specify roughness
% - Specify infiltration (note unit change 2020 onwards)
% - Add observation points
%%%%%

%% Create SFINCS struct
% Create input
inp     = sfincs_initialize_input;

% grid
inp.dx              = 10; 
inp.dy              = 10;
inp.mmax            = 20;  
inp.nmax            = 5;
inp.x0              = 0; 
inp.y0              = 0;

% numerical parameters
inp.advection       = 0;
inp.alpha           = 0.75;
inp.huthresh        = 0.005; 
inp.theta           = 0.9;  

% output parameters
inp.inputformat     = 'asc';
inp.outputformat    = 'net';
inp.dtout           = 3600*2;
inp.dthisout        = 600;
inp.dtmaxout        = 3600*24;
inp.tref            = datenum('20190225', 'yyyymmdd'); 
inp.tstart          = datenum('20190225', 'yyyymmdd');
inp.tstop           = datenum('20190226', 'yyyymmdd'); 

% Boundary conditions
inp.zsini           = 0; %m Initial water level

sfincs_write_input('sfincs.inp',inp); 

%% Create data for mask-file
% When matrices with x/y-coordinates and bed levels are known (xg,yg,zg)

% Get sizes
inp.nmax= size(xg,1);
inp.mmax= size(xg,2);
inp.dx  = nanmedian(diff(xg(1,:)));
inp.dy  = nanmedian(diff(yg(:,1)));
inp.x0  = min(min(xg));
inp.y0  = min(min(yg));

zlev = [-2 100]; % wanted lower and upper limits
xy=landboundary('read','jack_include.pli'); % polygon of cells to include
xy2=landboundary('read','jack_exclude.pli'); % polygon of cells to exclude

msk=sfincs_make_mask(xg,yg,zg,zlev,'includepolygon',xy,'excludepolygon',xy2);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Index file
%%%%%
%.ind
% ind1
% ind2
% ind3
%%%%%
% Example: (only needed for inputformat = bin)
inp.indexfile = 'sfincs.ind';

indices=find(msk>0);
mskv=msk(msk>0);

fid=fopen(inp.indexfile,'w');
fwrite(fid,length(indices),'integer*4');
fwrite(fid,indices,'integer*4');
fclose(fid);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Mask file 
%%%%%
%.msk
% mskx0y0 mskx1y0 
% mskx0y1 mskx1y1 
%%%%%
% 0/1/2 = nonactive/active/boundary point
%%%%%
% Example: 
inp.mskfile = 'sfincs.msk';

% inputformat = bin:
fid=fopen(inp.mskfile,'w');
fwrite(fid,mskv,'integer*1');
fclose(fid);

% inputformat = asc:
msk = ones(size(dep));
save(inp.mskfile,'-ascii','msk');

% Geomask file (not necessary to run SFINCS)
dlon=0.00100;
cs.name='WGS 84 / UTM zone 17N';
cs.type='projected';
sfincs_make_geomask_file(inp.geomskfile,inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation,inp.indexfile,inp.mskfile,dlon,cs);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Depth file
%%%%%
%.dep
% zbx0y0 zbx1y0 
% zbx0y1 zbx1y1 
%%%%%
% Topography is positive, bathymetry is negative (positive up)!
%%%%%
% Example:
inp.depfile = 'sfincs.dep';

% inputformat = bin:
zv = zg(indices); 
zv = zv * 1; 
fid=fopen(inp.depfile,'w');
fwrite(fid,zv,'real*4');
fclose(fid);

% inputformat = asc:
dep = 0 * ones(inp.nmax,inp.mmax);
save(inp.mskfile,'-ascii','dep');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Make flow boundaries (bnd, bzs, bzi, netbndbzs, netbndbzsbzi)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input locations
%%%%%
%.bnd file
% xloc1 yloc1
% xloc2 yloc2  
%%%%%
% Example:
inp.bndfile = 'sfincs.bnd';

points.x = [0 50]; 
points.y = [50 50]; 
points.length = length(points.x); 

sfincs_write_boundary_points(inp.bndfile,points);

%%%%%
% Time series - slowly varying component
%%%%%
%.bzs
% t0 zsloc1 zsloc2
% t1 zsloc1 zsloc2
%%%%%
% Example:
inp.bzsfile = 'sfincs.bzs';

time       = [0 3600 7200];
bzs        = [0 2 1];  

sfincs_write_boundary_conditions(inp.bzsfile,time,bzs)

%%%%%
% Time series - fast varying component (waves)
%%%%%
%.bzi
% t0 ziloc1 ziloc2
% t1 ziloc1 ziloc2
%%%%%
% Example:
inp.bzifile = 'sfincs.bzi';

time       = [0 2 4];
bzi        = [0.2 0.5 0.3];  

sfincs_write_boundary_conditions(inp.bzifile,time,bzi)

%%%%%
% Netcdf bnd - bzs input file (FEWS-compatible)
%%%%%
% Input specification:
% - x and y expected as arrays with values per station in same projected coordinate system as in SFINCS.
% - refdate is expected as string like '1970-01-01 00:00:00' 
% - time is expected as minutes since refdate
% - bzs input matrix dimensions assumed to be (t,stations)
% - EPSGcode as a value like: 32631
% - UTMname as a string like: 'UTM31N'
%%%%%
% Example:
filename = 'sfincs_netbndbzsfile.nc';

x = [0, 100, 200];
y = [50, 150, 250];

EPSGcode = 32631;
UTMname = 'UTM31N';
 
refdate  = '1970-01-01 00:00:00';
time = [0, 60];
 
rng('default');
bzs = -1 * randi([0 10],length(time),length(x));

sfincs_write_netcdf_bndbzsfile(filename, x, y, EPSGcode, UTMname, refdate, time, bzs)

%%%%%
% Netcdf bnd - bzs - bzi input file
%%%%%
% Input specification:
% - x and y expected as arrays with values per station in same projected coordinate system as in SFINCS.
% - refdate is expected as string like '1970-01-01 00:00:00' 
% - time is expected as minutes since refdate
% - bzs input matrix dimensions assumed to be (t,stations)
% - EPSGcode as a value like: 32631
% - UTMname as a string like: 'UTM31N'
%%%%%
% Example:
filename = 'sfincs_netbndbzsbzifile.nc';

x = [0, 100, 200];
y = [50, 150, 250];

EPSGcode = 32631;
UTMname = 'UTM31N';

refdate  = '1970-01-01 00:00:00';
time = [0, 60];

rng('default');
bzs = -1 * randi([0 10],length(time),length(x));
bzi = -1 * randi([0 10],length(time),length(x));

sfincs_write_netcdf_bndbzsbzifile(filename, x, y, EPSGcode, UTMname, refdate, time, bzs, bzi)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Make discharge points (src, dis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Location Discharge Points
%%%%%
%.src 
% xloc1 yloc1
% xloc2 yloc2  
%%%%%
% Example:
inp.srcfile = 'sfincs.src';

points_src.x = [0 50]; 
points_src.y = [50 50]; 
points_src.length = length(points.x); 

sfincs_write_boundary_points(inp.srcfile, points_src);

%%%%%
% Discharge values in m3/s
%%%%%
%.dis
% t0 disloc1 disloc2
% t1 disloc1 disloc2 
%%%%%
% Example:
inp.disfile = 'sfincs.dis';

t = [0 3600 7200];
dis = [0 0; 100 100; 150 150];

sfincs_write_boundary_conditions(inp.disfile, t, dis);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Add wind & precipitation (spw, amu, amv, ampr, wnd, prcp, netamuamvfile, netamprfile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - rain is specified in mm/hr
% - wind is m/s at 10m height
% - note, not all input options for wind and rain can be combined
%%%%%
% Spiderweb input
%%%%%
%.spw
%%%%%
% Example:
inp.spwfile = 'cyclone.spw';

% Without rain (in spw-file):
% % n_quantity     = 3
% % quantity1      = wind_speed
% % quantity2      = wind_from_direction
% % quantity3      = p_drop
% % unit1          = m s-1
% % unit2          = degree
% % unit3          = Pa

% Without rain (in spw-file):
% % n_quantity     = 4
% % quantity1      = wind_speed
% % quantity2      = wind_from_direction
% % quantity3      = p_drop
% % quantity4      = precipitation
% % unit1          = m s-1
% % unit2          = degree
% % unit3          = Pa
% % unit4          = mm/h

%%%%%
% Delft3D meteo input
%%%%%
% .amu .amv .ampr
%%%%%
% Example:
%wind:
inp.amufile = 'sfincs.amu'; %NOTE, some of the first lines have to commented out, see an example run
inp.amvfile = 'sfincs.amv'; %NOTE, some of the first lines have to commented out, see an example run
%rain:
inp.amprfile = 'sfincs.ampr'; %NOTE, some of the first lines have to commented out, see an example run

% first 13 lines (in amu-/amv-/ampr-file), then actual data starts (starting with TIME XXXX)
% % FileVersion      = 1.03
% % filetype         = meteo_on_equidistant_grid
% % n_cols           = 250
% % n_rows           = 250
% % grid_unit        = m
% % x_llcorner       = -1645540.349
% % y_llcorner       = 552664.407
% % dx               = 28608.7697
% % dy               = 16853.8168
% % n_quantity       = 1
% % quantity1        = precipitation
% % unit1            = mm/h
% % NODATA_value     = -9
% % TIME = 417819.000000 hours since 1970-01-01 00:00:00 +00:00  # 2017-08-31 03:00:00

%%%%% 
% Spatially uniform wind
%%%%%
%.wnd
% t0 vmag0 vdir0 
% t1 vmag1 vdir1
%%%%%
% Input specification:
% - vmag is the wind speed in m/s
% - vdir is the wind direction in nautical convection from where the wind is coming from
%%%%%
% Example:
inp.wndfile = 'sfincs.wnd';

vt = [0, 3600, 7200];
vmag = [0, 10, 20];
vdir = [350, 220, 45];

sfincs_write_uniform_wind(filename,vt,vmag,vdir)

%%%%% 
% Spatially uniform rain
%%%%%
%.prcp
% t0 prcp0 
% t1 prcp1
%%%%%
% Example:
inp.precipfile = 'sfincs.prcp';

%%%%%
% Netcdf FEWS compatible wind input
%%%%%
% netamuamvfile
%%%%%
% Input specification:
% - x and y expected as arrays with values along axis, no matrix. Grid is assumed rectilinear and projected in SFINCS.
% - refdate is expected as string like '1970-01-01 00:00:00' 
% - time is expected as minutes since refdate
% - amu/amv input matrix dimensions assumed to be (t,y,x)
% - EPSGcode as a value like: 32631
% - UTMname as a string like: 'UTM31N'
% 
% Example:
filename = 'sfincs_netamuamvfile.nc';

x = [0, 100, 200];
y = [50, 150, 250, 350];

EPSGcode = 32631;
UTMname = 'UTM31N';

refdate  = '1970-01-01 00:00:00';
time = [0, 60];

rng('default');
amu = -1 * randi([0 10],length(time),length(y),length(x));
amv = 1 * randi([0 10],length(time),length(y),length(x));

sfincs_write_netcdf_amuamvfile(filename, x, y, EPSGcode, UTMname, refdate, time, amu, amv)

%%%%%
% Netcdf FEWS compatible precipitation input
%%%%%
% netamprfile
%%%%%
% Input specification:
% - x and y expected as arrays with values along axis, no matrix. Grid is assumed rectilinear and projected in SFINCS.
% - refdate is expected as string like '1970-01-01 00:00:00' 
% - time is expected as minutes since refdate
% - ampr input matrix dimensions assumed to be (t,y,x)
% - EPSGcode as a value like: 32631
% - UTMname as a string like: 'UTM31N'
% 
% Example:
filename = 'sfincs_netamuamvfile.nc';

x = [0, 100, 200];
y = [50, 150, 250, 350];

EPSGcode = 32631;
UTMname = 'UTM31N';

refdate  = '1970-01-01 00:00:00';
time = [0, 60];

rng('default');
ampr = 1 * randi([0 10],length(time),length(y),length(x));

sfincs_write_netcdf_amuamvfile(filename, x, y, EPSGcode, UTMname, refdate, time, ampr)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Specify roughness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spatially uniform
%%%%%
% Example: (Specify directly in sfincs.inp)
inp.manning = 0.04; %default

%%%%%
% Vary based on elevation (water vs land)
%%%%%
%%%%%
% Example: (Specify directly in sfincs.inp)
inp.rgh_lev_land = 0.0;  % elevation that determines land or sea
inp.manning_land = 0.08; % manning value for cell >= rgh_lev_land
inp.manning_sea = 0.024; % manning value for cell < rgh_lev_land 

%%%%%
% Spatially varying
%%%%%
% .rgh
% rghx0y0 rghx1y0 
% rgh0y1 rghx1y1 
%%%%%
% Example: (Data in binary with size data dep-file)
inp.manningfile = 'sfincs.rgh';  % elevation that determines land or sea

polygon  = landboundary('read','change_roughness.pol');
id = inpolygon(xg,yg,polygon(:,1),polygon(:,2));
mn(1:size(xg,1),1:size(xg,2)) = 0.04; % set general roughness
mn(id) = 0.01; % set polygon roughness

mann = mn(indices);
fid = fopen(inp.manningfile,'w');
fwrite(fid,mann,'real*4');
fclose(fid);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Specify infiltration
%%%%%
% NOTE; from 2020 onwards infiltration in SFINCS is specified in [+mm/hr] instead of the old [-m/s]
%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spatially uniform
%%%%%
% Example: (Specify directly in sfincs.inp)
inp.qinf = 0.04; %default

%%%%%
% Spatially varying
%%%%%
% .rgh
% qinfx0y0 qinfx1y0 
% qinfx0y1 qinfx1y1 
%%%%%
% Example: (Data in binary with size data dep-file)
inp.qinffile = 'sfincs.qinf';  

polygon  = landboundary('read','change_infiltration.pol');
id = inpolygon(xg,yg,polygon(:,1),polygon(:,2));

inf(1:size(xg,1),1:size(xg,2)) = 2.0; % [+mm/hr] set general infiltration
inf(id) = 0.0; %[+mm/hr] set polygon infiltration

inf_q = inf(indices);
fid = fopen(inp.qinffile,'w');
fwrite(fid,inf_q,'real*4');
fclose(fid);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Thin dam file (from 2020 onwards)
%%%%%
%.thd
% NAME
% 2 2  % size data
% xloc1a yloc1a  % start polyline
% xloc1b yloc1b  % end polyline
%%%%%
% Example:
inp.thdfile = 'sfincs.thd';

thindams.x1 = [50 50]; 
thindams.y1 = [0 0]; 
thindams.x2 = [50 50]; 
thindams.y2 = [100 100]; 
thindams.name = {'THD01','THD02'};
thindams.length = length(thindams.x1);

sfincs_write_thin_dams(inp.thdfile,thindams);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Weir file (from 2020 onwards)
%%%%%
%.weir
% NAME
% 2 4  % size data
% xloc1a yloc1a zloc1a Cdloc1a % start polyline
% xloc1b yloc1b zloc1b Cdloc1b % end polyline
%%%%%
% zloc =  Weir level (w.r.t. ref datum)
% Cdloc = Cd coefficient
% Example:

inp.weirfile = 'sfincs.weir';

weirs.x1 = [50 50]; 
weirs.y1 = [0 0]; 
weirs.x2 = [50 50]; 
weirs.y2 = [100 0]; 
weirs.h1 = [1.5 1.5]; 
weirs.h2 = [1 1]; 
weirs.Cd1 = [50 50]; 
weirs.Cd2 = [0 0]; 
weirs.name = {'WEIR01','WEIR02'};
weirs.length = length(weirs.x1);

sfincs_write_weirs(inp.weirfile,weirs);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% Add observation points
%%%%%
%.obs 
% xloc1 yloc1
% xloc2 yloc2  
%%%%%
inp.obsfile = 'sfincs.obs';

points_obs.x = [];
points_obs.y = [];
points_obs.length = length(points_obs.x); 

sfincs_write_boundary_points(inp.obsfile,points_obs);
