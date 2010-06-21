function varargout = nc_multibeam_from_asc(varargin)
%NC_MULTIBEAM_FROM_ASC  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nc_multibeam_from_asc(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nc_multibeam_from_asc
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Jun 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT.block_size         = 3e6;
OPT.make               = true;
OPT.delete_existing    = true;

OPT.raw_path           = [];
OPT.raw_extension      = '*.asc';
OPT.netcdf_path        = [];
OPT.cache_path         = fullfile(tempdir,'nc_asc');
OPT.zip                = true;          % are the files zipped?
OPT.zip_extension      = '*.zip';       % are the files zipped?

OPT.datatype           = 'multibeam';
OPT.EPSGcode           = 28992;

OPT.mapsizex           = 5000;          % size of fixed map in x-direction
OPT.mapsizey           = 5000;          % size of fixed map in y-direction
OPT.gridsizex          = 5;             % x grid resolution
OPT.gridsizey          = 5;             % y grid resolution
OPT.xoffset            = 0;             % zero point of x grid
OPT.yoffset            = 0;             % zero point of y grid
OPT.zfactor            = 1;             % scale z by this facto

OPT.Conventions        = 'CF-1.4';
OPT.CF_featureType     = 'grid';
OPT.title              = 'Multibeam';
OPT.institution        = ' ';
OPT.source             = 'Topography measured with multibeam on project survey vessel';
OPT.history            = 'Created with: $Id$ $HeadURL$';
OPT.references         = 'No reference material available';
OPT.comment            = 'Data surveyed by survey department for ...';
OPT.email              = 'e@mail.com';
OPT.version            = 'Trial';
OPT.terms_for_use      = 'These data is for internal use by ... staff only!';
OPT.disclaimer         = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';

if nargin==0
    varargout = {OPT};
    return
end

[OPT, Set, Default] = setproperty(OPT, varargin{:});

if ~OPT.make
    disp('generation of nc files skipped')
    varargout = {OPT};
    return
end

multiWaitbar( 'Raw data to NetCDF',0,'Color',[0.2 0.6 0.2])


disp('generating nc files... ')
%% limited input check
if isempty(OPT.raw_path)
    error
end
if isempty(OPT.netcdf_path)
    error
end

if OPT.delete_existing
    % delete existing nc_files
    delete(fullfile(OPT.netcdf_path, '*.nc'))
end

EPSG             = load('EPSG');
mkpath(OPT.netcdf_path)

fns = dir( fullfile(OPT.netcdf_path,'*.nc'));
for ii = 1:length(fns)
    delete(fullfile(OPT.netcdf_path,fns(ii).name));
end

if OPT.zip
    mkpath(OPT.cache_path);
    fns = dir(fullfile(OPT.raw_path,OPT.zip_extension));
else
    fns = dir(fullfile(OPT.raw_path,OPT.raw_extension));
end

%% check if files are found
if isempty(fns)
    error('no raw files')
end

%% initialize waitbar
WB.done       = 0;
WB.bytesToDo  = 0;
if OPT.zip
    multiWaitbar('raw_unzipping'  ,0,'Color',[0.2 0.7 0.9])
end
multiWaitbar('nc_reading'         ,0,'Color',[0.1 0.5 0.8],'label','Reading')
multiWaitbar('nc_writing'         ,0,'Color',[0.1 0.3 0.6],'label','Writing')
for ii = 1:length(fns)
    WB.bytesToDo = WB.bytesToDo + fns(ii).bytes;
end
WB.bytesToDo =  WB.bytesToDo*2;
WB.bytesDoneClosedFiles = 0;
WB.zipratio = 1;
for jj = 1:length(fns)
    if OPT.zip
        multiWaitbar('raw_unzipping', 0,'label',sprintf('Unzipping %s',fns(jj).name));
        %delete files in cache
        delete(fullfile(OPT.cache_path, '*'));
        
        % uncompress files with a gui for progres indication
        uncompress(fullfile(OPT.raw_path,fns(jj).name),'outpath',OPT.cache_path,'gui',true,'quiet',true);
        
        % read the output of unpacked files
        fns_unzipped = dir(fullfile(OPT.cache_path,OPT.raw_extension));
        
        % get the size of the unpacked files that will be processed
        unpacked_size = 0;
        for kk = 1:length(fns_unzipped)
            unpacked_size = unpacked_size + fns_unzipped(kk).bytes;
        end
        WB.bytesToDo = WB.bytesToDo/WB.zipratio;
        
        % calculate a zip ratio to estimate the compression level (used
        % to estimate the total work for the progress bar)
        WB.zipratio = (WB.zipratio*(jj-1)+unpacked_size/fns(jj).bytes)/jj;
        WB.bytesToDo = WB.bytesToDo*WB.zipratio;
        multiWaitbar('raw_unzipping', 1);
    else
        fns_unzipped = fns(jj);
    end
    
    for ii = 1:length(fns_unzipped)
        %% set waitbars to 0 and update label
        multiWaitbar('nc_writing',0,'label','Writing: *.nc')
        multiWaitbar('nc_reading',0,'label',sprintf('Reading: %s...', (fns_unzipped(ii).name)))
        %% read data
        
        % process time
        timestr = fns_unzipped(ii).name(1:8);
        timestr = strrep(timestr,'mei','may');
        time    = datenum(timestr,'yyyy mmm') - datenum(1970,1,1);
        
        if OPT.zip
            fid      = fopen(fullfile(OPT.cache_path,fns_unzipped(ii).name));
        else
            fid      = fopen(fullfile(OPT.raw_path,fns_unzipped(ii).name));
        end
        s = fgetl(fid); ncols        = strread(s,       'ncols %d');
        s = fgetl(fid); nrows        = strread(s,       'nrows %d');
        s = fgetl(fid); xllcorner    = strread(s,   'xllcorner %f');
        s = fgetl(fid); yllcorner    = strread(s,   'yllcorner %f');
        s = fgetl(fid); cellsize     = strread(s,    'cellsize %f');
        s = fgetl(fid);
        
        try             nodata_value = strread(s,'nodata_value %f');
        catch;          nodata_value = strread(s,'NODATA_value %f'); %#ok<CTCH>
        end
        
        kk = 0;
        while ~feof(fid)
            multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+ftell(fid))/WB.bytesToDo)
            multiWaitbar('nc_reading',ftell(fid)/fns_unzipped(ii).bytes,'label',sprintf('Reading: %s...', (fns_unzipped(ii).name))) ;
            kk = kk+1;
            D{kk}     = textscan(fid,repmat('%f32',1,ncols),floor(OPT.block_size/ncols),'CollectOutput',true);
            if all(D{kk}{1}(:)==nodata_value)
                D{kk}{1} = nan;
            else
                D{kk}{1}(D{kk}{1}==nodata_value) = nan;
            end
        end
        multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+ftell(fid))/WB.bytesToDo)
        multiWaitbar('nc_reading'        ,ftell(fid)/fns_unzipped(ii).bytes,...
            'label',sprintf('Reading: %s', (fns_unzipped(ii).name))) ;
        fclose(fid);
        
        
        %------------------------------------------------------------------------------------------------------------------------------------------
        
        %% write data to nc files
        multiWaitbar('nc_writing',0,'label',sprintf('Writing: %s...', (fns_unzipped(ii).name)))
        % set the extent of the fixed maps (decide according to desired nc filesize)
        
        minx    = xllcorner;
        miny    = yllcorner;
        maxx    = xllcorner + cellsize.*(ncols-1);
        maxy    = yllcorner + cellsize.*(nrows-1);
        minx    = floor(minx/OPT.mapsizex)*OPT.mapsizex - OPT.xoffset;
        miny    = floor(miny/OPT.mapsizey)*OPT.mapsizey - OPT.yoffset;
        
        x      =         xllcorner:xllcorner + cellsize*(ncols-1);
        y      = flipud((yllcorner:yllcorner + cellsize*(nrows-1))');
        y(:,2) = ceil((1:length(y))'./floor(OPT.block_size/ncols));
        y(:,3) = mod((0:length(y)-1)',floor(OPT.block_size/ncols))+1;
        
        % loop through data
        for x0      = minx : OPT.mapsizex : maxx
            for y0  = miny : OPT.mapsizey : maxy
                ix = find(x     >=x0      ,1,'first'):find(x     <x0+OPT.mapsizex,1,'last');
                iy = find(y(:,1)<=y0+OPT.mapsizey,1,'first'):find(y(:,1)>y0      ,1,'last');
                
                z = nan(length(iy),length(ix));
                for iD = unique(y(iy,2))'
                    if~(numel(D{iD}{1})==1&&isnan(D{iD}{1}(1)))
                        z(y(iy,2)==iD,:) = D{iD}{1}(y(iy(y(iy,2)==iD),3),ix)*OPT.zfactor;
                    end
                end
                
                % generate X,Y,Z
                x_vector = x0:OPT.gridsizex:x0+OPT.mapsizex;
                y_vector = y0:OPT.gridsizey:y0+OPT.mapsizey;
                [X,Y]    = meshgrid(x_vector,fliplr(y_vector));
                Z = nan(size(X));
                Z(...
                    find(y_vector  >=y(iy(end)),1,'first'):find(y_vector  <=y(iy(1)),1,'last'),...
                    find(x_vector  >=x(ix(1)),1,'first'):find(x_vector  <=x(ix(end)),1,'last')) = z;
                
                if any(~isnan(Z(:)))
                    ncfile = fullfile(OPT.netcdf_path,sprintf('%8.2f_%8.2f_%s_data.nc',x0,y0,OPT.datatype));
                    if ~exist(ncfile, 'file')
                        nc_multibeam_createNCfile(OPT,EPSG,ncfile,X,Y)
                    end
                    nc_multibeam_putDataInNCfile(OPT,ncfile,time,Z')
                end
                
                WB.writtenDone =  (find(x0==minx : OPT.mapsizex : maxx,1,'first')-1)/...
                    length(minx : OPT.mapsizex : maxx)+ find(y0==miny : OPT.mapsizey : maxy,1,'first')/...
                    length(miny : OPT.mapsizey : maxy)/...
                    length(minx : OPT.mapsizex : maxx);
                multiWaitbar('nc_writing',WB.writtenDone,'label',sprintf('%8.2f_%8.2f_%s_data.nc',x0,y0,OPT.datatype))
                multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+(1+WB.writtenDone)*fns_unzipped(ii).bytes)/WB.bytesToDo)
            end
        end
        WB.writtenDone = 1;
        multiWaitbar('nc_writing',WB.writtenDone,'label',sprintf('%8.2f_%8.2f_%s_data.nc',x0,y0,OPT.datatype))
        WB.bytesDoneClosedFiles = WB.bytesDoneClosedFiles+fns_unzipped(ii).bytes;
    end
end


if OPT.zip
    try %#ok<TRYNC>
        rmdir(OPT.cache_path,'s')
    end
    multiWaitbar('raw_unzipping','close')
end

multiWaitbar('Raw data to NetCDF',1)
multiWaitbar('nc_reading','close')
multiWaitbar('nc_writing','close')
disp('generation of nc files completed')

multiWaitbar('Raw data to NetCDF',1)
varargout = {OPT};