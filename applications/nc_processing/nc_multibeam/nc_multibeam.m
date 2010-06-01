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
OPT = struct(...
    'rootpath',            fullfile('projects\151027_maasvlakte_2\elevation_data\multibeam\'), ...
    'ncserverpath',        'G:\EE\EE-OpenEarth\VOData', ...
    'kmlserverpath',       'G:\EE\EE-OpenEarth\VOwww', ...
    'webserverpath',       'http://10.12.184.200/', ...
    'deleteLocalFiles',    false, ...
    'VO_rawdata_path',     [], ...
    'nc_function',         @(OPT) multibeam_2_netcdf_thijs2(OPT), ...
    'nc_make',             true, ...
    'nc_copy2server',      true, ...
    'nc_delete_existing',  true, ...
    'block_size',          4e5, ...
    'kml_make',            true, ...
    'kml_copy2server',     true, ...
    'kml_detaillevel',     16, ...
    'kml_function',        'fixedmaps_2_png', ...
    'datatype',            'multibeam', ...
    'gridFcn',             @(X,Y,Z,XI,YI) griddata_remap(X,Y,Z,XI,YI,'errorCheck',true), ...
    'gridsize',            5, ...
    'mapsizex',            5000, ...
    'mapsizey',            5000, ...
    'xoffset',             0, ...
    'yoffset',             0, ...
    'zfactor',             1, ...
    'rawdata_ext',         '*.xyz', ...
    'format',              '%f%f%f',...
    'delimiter',           '\t', ...
    'MultipleDelimsAsOne', false, ...
    'headerlines',         0, ...
    'xid',                 1, ...
    'yid',                 2, ...
    'zid',                 3, ...
    'EPSGcode',            28992, ...
    'Conventions',         'CF-1.4', ...
    'CF_featureType',      'grid', ...
    'title',               'Maasvlakte 2', ...
    'institution',         'Puma', ...
    'source',              'Topography measured with multibeam on project survey vessel', ...
    'history',             'Created with: $Id$ $HeadURL$', ...
    'references',          'No reference material available', ...
    'comment',             'Data surveyed by survey department for the project Maasvlakte 2', ...
    'email',               'mrv@vanoord.com', ...
    'version',             'Trial', ...
    'terms_for_use',       'These data is for internal use by Puma staff only!', ...
    'disclaimer',          'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.'...
    ); 

% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

OPT.netcdf_path   = fullfile(OPT.rootpath,'nc_files','elevation_data',OPT.datatype);
OPT.kml_path      = fullfile(OPT.rootpath,'kml_files','elevation_data',OPT.datatype);
OPT.netcdf_server = fullfile(OPT.ncserverpath,OPT.netcdf_path);
OPT.kml_server    = fullfile(OPT.kmlserverpath,OPT.kml_path);
OPT.raw_path      = fullfile(OPT.rootpath,'elevation_data',OPT.datatype,'raw');

%% *** prepare ***
EPSG        = load('EPSG');

if OPT.nc_make
    disp('generating nc files...')
    if OPT.nc_delete_existing
        % delete existing nc_files
        delete(fullfile(OPT.netcdf_path, '*.nc'))
    end
    
    % set the extent of the fixed maps (decide according to desired nc filesize)
    xsize       = OPT.mapsizex; % size of fixed map in x-direction
    xstepsize   = OPT.gridsize; % x grid resolution
    ysize       = OPT.mapsizey; % size of fixed map in y-direction
    ystepsize   = OPT.gridsize; % y grid resolution
    
    fns         = dir(fullfile(OPT.raw_path,OPT.rawdata_ext));
    
    %% first: determine the outline of the dataset getting all the timestamps
    time = nan(1,length(fns));
    
    OPT.WBbytesToDo = 0;
    for kk = 1:size(fns,1)
        time(kk) = datenum(str2double(fns(kk).name(1:4)), str2double(fns(kk).name(5:6)), str2double(fns(kk).name(7:8))) ...
            - datenum(1970,01,01);
        OPT.WBbytesToDo = OPT.WBbytesToDo+fns(kk).bytes;
    end
    
    OPT.wb                   = waitbar(0, 'initializing file...');
    OPT.WBbytesDoneClosedFiles = 0;
    for kk = 1:size(fns,1)
        fid             = fopen(fullfile(OPT.raw_path, fns(kk).name));
        headerlines     = OPT.headerlines;
        while ~feof(fid)
            %% read data
            OPT.WBbytesDoneOfCurrentFile = ftell(fid);
            OPT.WBdone = (OPT.WBbytesDoneClosedFiles+OPT.WBbytesDoneOfCurrentFile)/OPT.WBbytesToDo;
            OPT.WBmsg       = {sprintf('processing %s:',mktex(fns(kk).name(1:8))),'Reading data'};
            waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);
            % read the data with 'OPT.block_size' lines at a time
            data            = textscan(fid,OPT.format,OPT.block_size,'delimiter',OPT.delimiter,...
                            'headerlines',headerlines,'MultipleDelimsAsOne',OPT.MultipleDelimsAsOne);
            headerlines     = 0; % only skip headerlines on first read
            OPT.WBbytesRead = ftell(fid) - OPT.WBbytesDoneOfCurrentFile;
            %% find min and max
            
            minx    = min(data{OPT.xid});
            miny    = min(data{OPT.yid});
            maxx    = max(data{OPT.xid});
            maxy    = max(data{OPT.yid});
            minx    = floor(minx/xsize)*xsize - OPT.xoffset;
            miny    = floor(miny/ysize)*ysize - OPT.yoffset;
            
            
            %% loop through data
            OPT.WBnumel = length(data{OPT.xid});
            for ii      = minx : xsize : maxx
                for jj  = miny : ysize : maxy
                    OPT.WBmsg{2}  = 'Gridding Z data';
                    waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);
                    try
                    ids =  inpolygon(data{OPT.xid},data{OPT.yid},[ii ii+xsize ii+xsize ii ii],[jj jj jj+ysize jj+ysize jj]);
                    catch
                        1
                    end
                    x   =  data{OPT.xid}(ids);
                    y   =  data{OPT.yid}(ids);
                    z   =  data{OPT.zid}(ids);
                    
                    %  waitbar stuff
                    OPT.WBnumelDone              = length(x);
                    OPT.WBbytesDoneOfCurrentFile = OPT.WBbytesDoneOfCurrentFile+OPT.WBnumelDone/OPT.WBnumel*OPT.WBbytesRead;
                    OPT.WBdone                   = (OPT.WBbytesDoneClosedFiles+OPT.WBbytesDoneOfCurrentFile)/OPT.WBbytesToDo;
                    
                    % generate X,Y,Z
                    x_vector = ii:xstepsize:ii+xsize;
                    y_vector = jj:ystepsize:jj+ysize;
                    [X,Y]    = meshgrid(x_vector,y_vector);
                    
                    % place xyz data on XY matrices
                    Z = OPT.gridFcn(x,y,z,X,Y);
                    
                    if sum(~isnan(Z(:)))>=3
                        Z = flipud(Z);
                        Y = flipud(Y);
                        % if a non trivial Z matrix is returned write the data
                        % to a nc file
                        ncfile = fullfile(OPT.netcdf_path,sprintf('%8.2f_%8.2f_%s_data.nc',ii,jj,OPT.datatype));
                        if ~exist(ncfile, 'file')
                            nc_multibeam_createNCfile(OPT,ncfile,X,Y,EPSG)
                        end
                        nc_multibeam_putDataInNCfile(OPT,ncfile,kk,time,Z')
                    end
                end
            end
        end
        OPT.WBbytesDoneClosedFiles = OPT.WBbytesDoneClosedFiles + fns(kk).bytes;
    end
    close(OPT.wb)
    disp('generation of nc files completed')
else
    disp('generation of nc files skipped')
end

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
