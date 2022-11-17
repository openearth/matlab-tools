%% SFINCS models to pre-determined extends for SF Bay
% v1.0  Nederhoff       07-2022  - clean version for release
clear variables; close all;

%% 0. Settings
% Add path of where SFINCS scripts are located
% Add also the path where Delft Dashboard is located (is used for bathy)
addpath(genpath('p:\11202255-sfincs\organise_scripts\'))
initialize_bathymetry_database('c:\software\DelftDashboard\data\bathymetry\')

% Define folders and polygons
destout                     = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\example01_SFBay\mymodel_subgrid25m\'; %with working opendap
xml_file                    = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\example01_SFBay\sf_bay.xml';
include_shapefile           = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\example01_SFBay\shapefiles\include_polygon';
exclude_shapefile           = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\example01_SFBay\shapefiles\exclude_polygon';
closed_boundary             = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\example01_SFBay\shapefiles\closed_boundary';
friction                    = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\example01_SFBay\friction_UTM10_100m.tif';

% Other settings
tstart                      = datenum(2000,1,1);
tend                        = datenum(2000,2,1);

% Numerical settings
alpha                       = 0.5;          % CFL condition
dx                          = 200;          % in meter
dy                          = 200;          % ''
subgrid_dx                  = 25;           % '' 

%% Main part
% Get name and folder
disp(['Started with SF Bay'])
folder          = [destout]; 
mkdir(folder); cd(folder);

% Read shapefile
% Include
cd(folder)
S                   = m_shaperead(include_shapefile);
S                   = round(S.ncst{1,1});
INFO.Field(1).Name  = 'include_polygon';
INFO.Field(1).Data  = S;
OUT                 = tekal('write','include_polygon.pol',INFO);
clear S INFO

% Exclude
cd(folder)
S                   = m_shaperead(exclude_shapefile);
for ss = 1:length(S.ncst)
    SS                   = round(S.ncst{ss,1});
    INFO.Field(ss).Name  = ['exclude_polygon', num2str(ss)];
    INFO.Field(ss).Data  = SS;
end
OUT                 = tekal('write','exclude_polygon.pol',INFO);
clear S INFO

% closed boundary
cd(folder)
S                   = m_shaperead(closed_boundary);
for ss = 1:length(S.ncst)
    SS                   = round(S.ncst{ss,1});
    INFO.Field(ss).Name  = ['closed_boundary', num2str(ss)];
    INFO.Field(ss).Data  = SS;
end
OUT                 = tekal('write','closed_boundary.pol',INFO);
clear S INFO

% Read manning n
[A,x,y,I]               = ddb_geoimread(friction);
manning.val             = A;
[manning.x,manning.y]   = meshgrid(x,y);

%% Make bathmetry
xml             = xml2struct(xml_file);
mmax            = round(str2double(xml.lenx)/dx);
nmax            = round(str2double(xml.leny)/dy);
inp             = sfincs_initialize_input;
inp.depfile     = 'sfincs.dep';
inp.mskfile     = 'sfincs.msk';
inp.indexfile   = 'sfincs.ind';
inp.bndfile     = 'sfincs.bnd';
inp.bzsfile     = 'sfincs.bzs';
inp.sbgfile     = 'sfincs.sbg';
inp.x0          = str2double(xml.x0);
inp.y0          = str2double(xml.y0);
inp.mmax        = mmax;
inp.nmax        = nmax;
inp.dx          = dx;
inp.dy          = dy;
inp.tspinup     = 6*3600;
inp.rotation    = str2double(xml.rotation);
inp.alpha       = alpha;
inp.theta       = 0.95;
inp.dtout       = 24*3600;
inp.dthisout    = 600;
inp.dtmapout    = 3600;
inp.outputformat = 'net';
inp.tref        = tstart;
inp.tstart      = tstart;
inp.tstop       = tend;
inp.dtmaxout    = (tend-tstart)*86400;
inp.dtmaxout    = (tend-tstart)*86400;
inp.obsfile     = 'noaa_only.obs';
inp.btfilter    = 600;

% Find bathymetry sources
cs.name=xml.csname;
cs.type=xml.cstype;
for ib=1:length(xml.bathymetry)
    b=xml.bathymetry(ib).bathymetry;
    bathy(ib).name=b.name;
    bathy(ib).zmin=str2double(b.zmin);
    bathy(ib).zmax=str2double(b.zmax);
    bathy(ib).vertical_offset=str2double(b.vertical_offset);
end

% Get ready to call the script
sfincs_build_model(inp,folder,bathy,cs,'subgrid_dx',subgrid_dx, 'zmin', -100, 'zmax', 8, ...
    'includepolygon','include_polygon.pol', 'excludepolygon', 'exclude_polygon.pol' , ...
    'closedboundarypolygon', 'closed_boundary.pol', 'manning_input', manning);

%% Make boundaries
% Read mask
[xg,yg,xz,yz]   = sfincs_make_grid(inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation);
[z,msk]         = sfincs_read_binary_inputs(inp.mmax,inp.nmax,inp.indexfile,inp.depfile,inp.mskfile);

% Make boundary points
x_wanted        = xg(msk(:,1) ==2);
y_wanted        = yg(msk(:,1) ==2);

% Convert to WGS84
p.x             = x_wanted(1:10:end);
p.y             = y_wanted(1:10:end);
p.length        = length(p.x);
sfincs_write_boundary_points([destout,'sfincs.bnd'],p)
[x_wgs84, y_wgs84] = convertCoordinates(p.x, p.y, 'CS2.name','WGS 84','CS2.type','geo','CS1.name',cs.name,'CS1.type',cs.type);

% Get tidal data for all the points
name            ='tpxo80'; %handles.tideModels.model(ii).name;
URL             = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/delftdashboard/tidemodels/tpxo80';
if strcmpi(URL(1:4),'http')
    tidefile    =[URL '/' name '.nc'];
else
    tidefile    =[URL filesep name '.nc'];
end
[gt,conList]    =  read_tide_model(tidefile,'type','h','x',x_wgs84','y',y_wgs84','constituent','all');

% Loop over points
for jj = 1:p.length
    
    % Get time
    t0      = inp.tstart;
    t1      = inp.tstop; datenum(2018,09,31);
    dt      = 10/1440;
    tim     = t0:dt:t1;
    
    % Tidal prediction
    latitude=y_wgs84(jj);
    wl=makeTidePrediction(tim,conList,gt.amp(:,jj),gt.phi(:,jj),latitude);
    
    % Save information
    tide(jj).x      = p.x(jj);
    tide(jj).y      = p.y(jj);
    tide(jj).time   = tim;
    tide(jj).bzs    = wl;
    bzsall(:,jj)    = wl;
end
t   = (tim - tim(1)) * 24*3600;
sfincs_write_boundary_conditions([destout,'sfincs.bzs'],t,bzsall)

% Copy obs file
cd(destout); cd ..
copyfile('noaa_only.obs', [destout, filesep, 'noaa_only.obs']);

% Other things?
% ...

% Done
disp('done')
