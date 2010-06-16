function nc_multibeam(varargin)
%MULTIBEAM_2_NETCDF  Script to transform the raw data from Delflandse Kust to NetCDF format
%

% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Delft University of Technology
% Version:      Version 1.0, February 2004
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$

%% TODO:
% - check still if fixed maps are overlapping or not (adjust indices if needed)
% - check out the proper CF:featureTupe for grids
% - include option to add data to an already existing netcdf time entry (this enables cutting up of very very large multibeam files)


%% settings
OPT.ncserverpath                 = 'G:\EE\EE-OpenEarth\VOData';
OPT.kmlserverpath                = 'G:\EE\EE-OpenEarth\VOwww';
OPT.webserverpath                = 'http://10.12.184.200/';
OPT.VO_rawdata_path              = fileparts(mfilename('fullpath'));
OPT.deleteLocalFiles             = false;

OPT.rootpath                     = fullfile('projects\151027_maasvlakte_2\elevation_data\multibeam\');
OPT.nc_function                  = @(OPT) nc_multibeam(OPT);
OPT.raw_to_nc_function           = @(OPT) nc_multibeam_from_xyz(OPT);
OPT.nc_make                      = true;
OPT.nc_copy2server               = true;
OPT.nc_delete_existing           = true;
OPT.block_size                   = 2e6;
OPT.kml_make                     = true;
OPT.kml_copy2server              = true;
OPT.kml_detaillevel              = 15;
OPT.kml_function                 = 'fixedmaps_2_png';
OPT.datatype                     = 'multibeam';
OPT.gridFcn                      = @(X,Y,Z,XI,YI) griddata_remap(X,Y,Z,XI,YI,'errorCheck',true);
OPT.gridsize                     = 10;
OPT.mapsizex                     = 5000;
OPT.mapsizey                     = 4000;
OPT.xoffset                      = 5;
OPT.yoffset                      = 5;
OPT.zfactor                      = 1;
OPT.rawdata_ext                  = '*.xyz';
OPT.format                       = '%f%f%f';
OPT.delimiter                    = '\t';
OPT.headerlines                  = 0;
OPT.xid                          = 1;
OPT.yid                          = 2;
OPT.zid                          = 3;
OPT.EPSGcode                     = 28992;
OPT.Conventions                  = 'CF-1.4';
OPT.CF_featureType               = 'grid';
OPT.title                        = 'Maasvlakte 2';
OPT.institution                  = 'Puma';
OPT.source                       = 'Topography measured with multibeam on project survey vessel';
OPT.history                      = 'Created with: $Id$ $HeadURL$';
OPT.references                   = 'No reference material available';
OPT.comment                      = 'Data surveyed by survey department for the project Maasvlakte 2';
OPT.email                        = 'mrv@vanoord.com';
OPT.version                      = 'Trial';
OPT.terms_for_use                = 'These data is for internal use by Puma staff only!';
OPT.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';

% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

OPT.netcdf_path   = fullfile(OPT.rootpath,'nc_files','elevation_data',OPT.datatype);
OPT.kml_path      = fullfile(OPT.rootpath,'kml_files','elevation_data',OPT.datatype);
OPT.netcdf_server = fullfile(OPT.ncserverpath,OPT.netcdf_path);
OPT.kml_server    = fullfile(OPT.kmlserverpath,OPT.kml_path);
OPT.raw_path      = fullfile(OPT.rootpath,'elevation_data',OPT.datatype,'raw');
OPT.cache_path    = fullfile(OPT.rootpath,'cache');

%% *** prepare ***
EPSG        = load('EPSG');

%% make nc file
OPT.raw_to_nc_function(OPT)

%% copy nc files to server
nc_copy_nc_files_to_server(OPT)

%% make kml files
if OPT.kml_make
    switch OPT.kml_function
        case 'fixedmaps_2_png'
            % inputDir, outputDir, serverURL, EPSGcode, lowestLevel, datatype
            try
                fixedmaps_2_png(OPT.netcdf_path,OPT.kml_path,...
                    [fullfile(OPT.webserverpath,'elevation_data') filesep], OPT.EPSGcode, OPT.kml_detaillevel, OPT.datatype)      
            catch
                warning(lasterr)
            end
        otherwise 
            disp(' not able to make KML using the proposed function (yet)');
    end
else
    disp('generation of kml files skipped')
end

%% copy kml files to server
nc_copy_kml_files_to_server(OPT)
