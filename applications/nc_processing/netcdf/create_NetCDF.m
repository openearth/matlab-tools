function varargout = create_NetCDF(varargin)
%CREATE_NETCDF  One line description goes here.
% This function can be used to create NetCDF files. The input options with
% description are listed in nc_SetOptions. The properties in nc_SetOptions
% are set as input but can be overruled with input varargin.
%
% Within this function the following functions are used;
% convertCoordinates() to convert coordinates from x,y to lon, lat
% nc_cf_standard_names to set standard names for NetCDF variables
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = create_NetCDF(varargin)
%
%   Input:
%   varargin  = nc_SetOptions
%
%   Output:
%   varargout = OPT
%
%   Example
%   nc_create        = @(varargin) (create_NetCDF(varargin{:}));
%   nc_create ('nc.nr_fname',4);
%
%   Transform rawfile number 4 from raw directory list into a NetCDF file
%   with the properties selected in nc_SetOptions()
%
%   See also nc_SetOptions() and convertCoordinates()

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Royal Boskalis Westminster
%       Kees Willem Pruis
%
%       k.w.pruis@boskalis.nl
%
%       Rosmolenweg 20
%       3356 LK Papendrecht
%       The Netherlands
%       T: +31 78 6969 704

%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 14 Nov 2011
% Created with Matlab version: 7.13.0.564 (R2011b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Waitbar stuff
WB.bytesToDo  = 0;
WB.bytesWritten  = 0;
WB.bytesDoneOfCurrentFile = 0;


get_ncOptions = @(varargin) (nc_SetOptions(varargin{:})); % gather the options from nc_SetOptions
OPT           = get_ncOptions();                          % Options are stored
OPT = setproperty(OPT,varargin{:});                       % overrule properties with input properties

if nargin==0;
    varargout = {OPT};
    return;
end

mkpath(fullfile(OPT.nc.basepath_local,OPT.nc.netcdf_path));

%% collect data

% list all the raw data files in the raw path directory
fnames = dir(fullfile(OPT.nc.raw_path,OPT.nc.raw_extension));

% if OPT.nc.nr_fname is given only this file is transformed into netcdf, the
% other files in the directory are not transformed
if ~isempty(OPT.nc.nr_fname)
    fnames = fnames(OPT.nc.nr_fname);
end

%% check if files are found
if isempty(fnames)
    error('no raw files')
end

% total number of bytes to be transformed for waitbar
for ii = 1:length(fnames)
    WB.bytesToDo = WB.bytesToDo+fnames(ii).bytes;
end

%% transform the in fnames listed raw files to NetCDF
if OPT.nc.make
    for i = 1:length(fnames)
        fid = fopen(fullfile(OPT.nc.raw_path,fnames(i).name),'r');
            data = textscan(fid,'%f %f %f', 'delimiter',',');
        
            WB.bytesDoneOfCurrentFile = ftell(fid);
            WB.bytesWritten           = WB.bytesWritten+WB.bytesDoneOfCurrentFile;
            multiWaitbar('Raw data to NetCDF',(WB.bytesWritten)/WB.bytesToDo)
        
        fclose(fid);

        x = data{1,OPT.nc.xid};
        y = data{1,OPT.nc.yid};
        z = data{1,OPT.nc.zid};
            
%         %% find min and max
%         minx    = min(data{OPT.nc.xid});
%         miny    = min(data{OPT.nc.yid});
%         maxx    = max(data{OPT.nc.xid});
%         maxy    = max(data{OPT.nc.yid});
%         minx    = floor(minx/OPT.nc.mapsizex)*OPT.nc.mapsizex + OPT.nc.xoffset;
%         miny    = floor(miny/OPT.nc.mapsizey)*OPT.nc.mapsizey + OPT.nc.yoffset;
%         
        if ~exist(OPT.nc.netcdf_path,'dir') && ~isempty(OPT.nc.netcdf_path)
            mkdir(OPT.nc.netcdf_path);
        end
        
         %% Vector 2 Grid
        F = TriScatteredInterp(x,y,z);
        try
            [X,Y] = meshgrid(x,y);
        catch ME
            ME = MException(ME.identifier,'out of Memory warning is prevented by reducing the resolution of the grid');
            xt = min(x):1:max(x);
            yt = min(y):1:max(y);
            [X,Y] = meshgrid(xt,yt);
        end
        Z = F(X,Y);
        OPT.ME = ME;
        %% Define Dimensions for NetCDF
        dimSizeX = size(X,2);
        dimSizeY = size(Y,1);
        
        %% Create NetCDF
        ncfile = fullfile(OPT.nc.basepath_local,OPT.nc.netcdf_path,['SandEngine_',fnames(i).name(1:6),'.nc']);
        ncid = netcdf.create(ncfile,'NC_CLOBBER');
        globalID = netcdf.getConstant('NC_GLOBAL');
        netcdf.defDim(ncid, 'lat', dimSizeY);
        netcdf.defDim(ncid, 'lon', dimSizeX);
        
        %% add attributes global to the dataset
        netcdf.putAtt(ncid,globalID, 'Conventions',     OPT.nc.Conventions);
        netcdf.putAtt(ncid,globalID, 'CF:featureType',  OPT.nc.CF_featureType); % http://www.unidata.ucar.edu/software/netcdf-java/v4.1/javadoc/ucar/nc2/constants/CF.FeatureType.html
        netcdf.putAtt(ncid,globalID, 'title',           OPT.nc.title);
        netcdf.putAtt(ncid,globalID, 'institution',     OPT.nc.institution);
        netcdf.putAtt(ncid,globalID, 'source',          OPT.nc.source);
        netcdf.putAtt(ncid,globalID, 'history',         OPT.nc.history);
        netcdf.putAtt(ncid,globalID, 'references',      OPT.nc.references);
        netcdf.putAtt(ncid,globalID, 'comment',         OPT.nc.comment);
        netcdf.putAtt(ncid,globalID, 'email',           OPT.nc.email);
        netcdf.putAtt(ncid,globalID, 'version',         OPT.nc.version);
        netcdf.putAtt(ncid,globalID, 'terms_for_use',   OPT.nc.terms_for_use);
        netcdf.putAtt(ncid,globalID, 'disclaimer',      OPT.nc.disclaimer);
        
        %% define coordinate variables
        ZZ  = unique(z);
        dZ = abs(unique(diff(ZZ)));
        if length(dZ) == 1
            actual_range.z = [min(ZZ)-.5*dZ max(ZZ)+.5*dZ]; % outer coordinates of corners, x/y are at centers
        else
            actual_range.z = [];
        end
        
        % Transform x, y to lon lat with convertCoordinates
        [lon,lat] = convertCoordinates(X,Y,'CS1.code',OPT.nc.EPSGcode,'CS2.code',4326);
        % longitude
        lonlon  = unique(lon);
        dlon = abs(unique(diff(lonlon)));
        if length(dlon) == 1
            actual_range.lon = [min(lonlon)-.5*dlon max(lonlon)+.5*dlon]; % outer coordinates of corners, x/y are at centers
        else
            actual_range.lon = [];
        end
        % latitude
        latlat  = unique(lat);
        dlat = abs(unique(diff(latlat)));
        if length(dlat) == 1
            actual_range.lat = [min(latlat)-.5*dlat max(latlat)+.5*dlat]; % outer coordinates of corners, x/y are at centers
        else
            actual_range.lat = [];
        end
        
        % adding variables that are part of standard-name glossaries
        nc_cf_standard_names('ncid', ncid, 'nc_library', 'matlab', 'varname', {'lon'},  'cf_standard_name', {'longitude'},               'dimension', {'lon'}       ,'additionalAtts',{'grid_mapping'                             ;'WGS84'});
        nc_cf_standard_names('ncid', ncid, 'nc_library', 'matlab', 'varname', {'lat'},  'cf_standard_name', {'latitude'},                'dimension', {'lat'}        ,'additionalAtts',{'grid_mapping'                             ;'WGS84'});
        nc_cf_standard_names('ncid', ncid, 'nc_library', 'matlab', 'varname', {'z'},    'cf_standard_name', {'altitude'}, 'dimension', {'lat','lon'} ,'additionalAtts',{'grid_mapping','coordinates','actual_range';'WGS84','Norting Easting',actual_range.z});
        
        % expand, bring in data mode
        netcdf.endDef(ncid);
        
        %% add data
        varid = netcdf.inqVarID(ncid,'lon');netcdf.putVar(ncid,varid,lon(1,:));
        varid = netcdf.inqVarID(ncid,'lat');netcdf.putVar(ncid,varid,lat(:,1));
        varid = netcdf.inqVarID(ncid,'z'  );netcdf.putVar(ncid,varid,Z);
        
        %% close NC file
        netcdf.close(ncid);
        clear data x y z
    end
end
varargout = {OPT};
end
