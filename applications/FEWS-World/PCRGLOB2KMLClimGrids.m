function PCRGLOB2KMLClimGrids(lat_range, lon_range, model, scenario, var)
%PCRGLOB2KMLClimGrids   climatology grids computed from PCR-GLOBWB climate scenarios
%
%   PCRGLOB2KMLClimGrids(lat_range,lon_range,model,scenario,var)
%
% General description
% ==============================
% This script retrieves climatology grids of a selected variable of
% interest, as computed from PCR-GLOBWB climate scenarios. The computations
% are based on a certain climate model and scenarios (or base-line), which the user can
% specify. This script then provides climatologies of the current climate
% (1971-1990) or of the future climate (2081-2100)
% usage:    PCRGLOB2KMLTimeSeriesClim(lat,lon,model,scenario,variable)
%
% Inputs:
% ==============================
% lat_range:    2-element vector with latitude bounds of interest(range: -90/90)
% lon_range:    2-element vector with longitude bounds of interest (range: -180/180)
% model:        Climate model used for computation: can be the following:
%               'FREDERIEK, KUN JE DIT INVULLEN ZOALS BENEDEN? EERST DE CODERING, DAN
%               DE BESCHRIJVING?
%
% scenario:     Scenario computed: can be the following:
%               'SRESA1B'
%               'SRESA2'
% var:          variable of interest: can be the following:
%               'EACT'    : actual evaporation (m/day)
%               'ETP'     : potential evaporation (m/day)
%               'QC'      : accumulated river discharge (m3/s)
%
% MATLAB will not give any outputs to the screen. The result will be 2 
% KML-files located in a new folder, specified by
% <scenario>_<model>_<period>_<variable>. The 2 files are compilations of
% maps and animated maps respectively.
% Do not change the file structure within
% this folder, it will render the kml unusable! You can however shift the
% whole folder to other locations.
%
% No additional options are available, all inputs are compulsory
%
%See also: KMLanimate, googleplot, PCRGLOB2KMLTimeSeriesClim

%% OpenEarth general information
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Hessel C. Winsemius
%
%       hessel.winsemius@deltares.nl
%       (tel.: +31 88 335 8465)
%       Rotterdamseweg 185
%       Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

% OPT.name          = '';
% [OPT, Set, Default] = setproperty(OPT, varargin{:});

% Fix the location of nc-files. Can be either local or OpenDAP
% note HCW 22-01-2010: ncLocation will soon be changed to OpenDAP!!
% (https://....);
ncLocation = 'f:\python\FEWSWorld';
% Any value > thres is assumed to be wrong! these values are removed
thres = 1e7;
try
    if strcmp(scenario,'SRESA1B') | strcmp(scenario,'SRESA2')
        period = '2081-2100';
    else
        period = '1971-1990';
    end
catch
    disp(['Scenario ''' scenario ''' is not available. Exiting....']);
end
% Build the filename from all provided information
nc_file = [ncLocation filesep scenario '_' model '_' period '.nc'];
kmlFolder = [scenario '_' model '_' period '_' var '_clim'];
% if target directory does not exist, create the directory
if isdir(kmlFolder)==0
    mkdir(kmlFolder)
end
latmin=max(min(lat_range),-90);
latmax=min(max(lat_range),90);
lonmin=max(min(lon_range),-180);
lonmax=min(max(lon_range),180);

lat_range = [latmin latmax];
lon_range = [lonmin lonmax];

%Get data
info = nc_getvarinfo(nc_file,var);
units = info.Attribute(1).Value;
lat = nc_varget(nc_file,'latitude');
lon = nc_varget(nc_file,'longitude');
time = nc_varget(nc_file,'time');
nryears = floor(info.Size(1)/12);

%Get rows for chosen latitudes and longitudes
a=find(abs(lat-latmax)==min(abs(lat-latmax)));
startlat=a(1);
b=find(abs(lat-latmin)==min(abs(lat-latmin)));
endlat=b(end);
nrrows=abs(endlat-startlat)+1;

c=find(abs(lon-lonmin)==min(abs(lon-lonmin)));
startlon=c(1);
d=find(abs(lon-lonmax)==min(abs(lon-lonmax)));
endlon=d(end);
nrcols=abs(endlon-startlon)+1;
lat2 = linspace(lat(startlat),lat(endlat),nrrows);
lon2 = linspace(lon(startlon),lon(endlon),nrcols);

% Calculate axes and create images
[loni,lati] = meshgrid(lon2,lat2);
out_raster = zeros(nrrows,nrcols,12);
% count number of pixels for quality
nrofpix = length(loni(:));
% generate climatology
for t = 1:12 
    rasters = zeros(nrrows,nrcols,nryears);
    for y = 1:20
        rasters(:,:,y) = nc_varget(nc_file,var,[(y-1)*12+t-1 startlat-1 startlon-1],[1 nrrows nrcols]);
    end
    out_raster(:,:,t) = mean(rasters,3);
    %[loni,lati];
end
% remove incorrect values
ii = find(out_raster > thres)
out_raster(ii) = NaN;
% determine minimum value and maximum value to fix plot
maxval = max(max(max(out_raster)));
minval = min(min(min(out_raster)));
% Now plot the climatology in KML
for t = 1:12
    currdir = pwd;
    cd(kmlFolder);
    kmlName{t} = [scenario '_' model '_clim_' datestr([2000 t 1 0 0 0],'mmm') '.kml'];
    mapName{t} = [scenario '_' model '_clim_' datestr([2000 t 1 0 0 0],'mmm')];
    h=pcolorcorcen(loni,lati,out_raster(:,:,t));
    colormap([var 'map']);
    % fix color axis
    caxis([0 round(maxval*10000)/10000]);
    colorbarwithtitle(units);
    KMLfig2png(h,'fileName',kmlName{t},'levels',[0 0],'dim',min(round(nrofpix/20),1024));
    close all
    cd(currdir);
end

descript = ['Climatology of model ' model ' and scenario ' scenario];
outFile = [scenario '_' model '_clim.kml'];
currdir = pwd;
cd(kmlFolder);
% Combine created KML files and give the combination a name
KMLmerge_files('fileName',outFile,'sourceFiles',kmlName,'description',descript,'deleteSourceFiles','True');
% Create animation of kmlFiles
inFile=outFile;
begintime = [0000 01 01 0 0 0];
timestep = 1;
timeunit = 'month';
outFile = [scenario '_' model '_clim_anim.kml'];
KMLanimate(inFile, outFile, mapName, begintime, timestep, timeunit)
cd(currdir);

