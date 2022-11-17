%% Downscale SF Bay maximum water level
% v1.0  Nederhoff       07-2022  - clean version for release
clear variables; close all;

% Add path of where SFINCS scripts are located
% Add also the path where Delft Dashboard is located (is used for bathy)
% You need the OpenEarthTools for this script
addpath(genpath('p:\11202255-sfincs\organise_scripts\'))
initialize_bathymetry_database('c:\software\DelftDashboard\data\bathymetry\')

% Settings
destin      = 'c:\TMP\mymodel_subgrid10m\';         % location of model run
inpfile     = 'sfincs.inp';                         % inp file of SFINCS
xml_file    = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\exampleXX_SFBay\sf_bay.xml';   % xml to describe bathy sources
xwanted     = [545 555]*10^3;                       % coordinates you want high resolution output for
ywanted     = [4175 4190]*10^3;                     % '' <- using same coordinate system as SFINCS model
dx          = 5;                                    % in meter
hh_criteria = 0.10;                                 % only when SFINCS computed 10 cm or more water

% Get bathy sources ready
xml         = xml2struct(xml_file);
for ib=1:length(xml.bathymetry)
    b=xml.bathymetry(ib).bathymetry;
    bathy(ib).name=b.name;
    bathy(ib).zmin=str2double(b.zmin);
    bathy(ib).zmax=str2double(b.zmax);
    bathy(ib).vertical_offset=str2double(b.vertical_offset);
end

% Get bed level values
cs.name         = xml.csname;
cs.type         = xml.cstype;
X               = [xwanted(1):dx:xwanted(2)];
Y               = [ywanted(1):dx:ywanted(2)];
[XX,YY]         = meshgrid(X,Y);
Z               = interpolate_bathymetry_to_grid(XX,YY,[],bathy,cs,'quiet');

% Get model results for the area
cd(destin)
model_X         = squeeze(nc_varget('sfincs_map.nc', 'x'))';
model_Y         = squeeze(nc_varget('sfincs_map.nc', 'y'))';
model_zsmax     = squeeze(nc_varget('sfincs_map.nc', 'zsmax'))';
subgrd          = sfincs_read_binary_subgrid_tables(destin);
model_z_zmin    = subgrd.z_zmin;

% Downscaling of water levels onto high resolution grid
% takes a while the first time since indices are being saved in 'downscaled.ind'
% after that this is really fast
[high_zs]       = downscale_zs(model_X, model_Y, model_zsmax, model_z_zmin, X, Y, hh_criteria, 'downscaled.ind');

% Compute water depth; rmove dry points; smooth it a bit 
high_hh         = high_zs - Z;
high_hh(high_hh<hh_criteria) = NaN;
high_hh         = smooth2(high_hh, 'box', [5 5]);

% Write it out as netcdf
write_netcdf_file('waterdepth.nc', X', Y', 0, 'WGS 84 / UTM 10 N', high_hh, 'waterdepth')