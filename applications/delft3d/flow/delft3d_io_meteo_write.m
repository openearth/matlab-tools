function fid = delft3d_io_meteo_write(filehandle,time,data,varargin)
%DELFT3D_IO_METEO_WRITE   write meteo data file on curvilinear grid
%
%  <fid> = delft3d_io_meteo_write(file,time,data,x,y,<keyword,value>)
%
% where file can be fid (opened by previous call) or a filename (1st call
% wipes existing file with same name), time is the time in Matlab datenumbers.
% A header block is inserted when newgrid==1 or x and y are supplied.
%
% The following <keyword,value> pairs have been implemented:
%
%    filetype         = 'meteo_on_equidistant_grid','meteo_on_spiderweb_grid',
%                       'meteo_on_curvilinear_grid' (default)
%    header           = default, {[]};
%    nodata_value     = default, nan;
%    grid_file        = default, ['temp.grd']; % if no (relative) path specified, will be written in same path as amx file
%                                              % but with LOCAL reference to grd file inside amx file
%    quantity         = 'air_pressure'     ,'x_wind','y_wind','relative_humidity','air_temperature','cloudiness'
%    unit             = 'Pa','mbar'        ,'m s-1'          ,'%'                ,'Celsius'        ,'%'
%    refdatenum       = default, datenum(1970,1,1);
%    timezone         = default, '+00:00';
%    OS               = end of line type, default, 'unix';
%    newgrid          = whether to write header block, default, 0;
%    writegrd         = whether to write grd, default true; can be set to
%                       false if grd was already written in 1st time step
%                       or for previous quantities
%    CoordinateSystem = to be passed to WLGRID, 'Cartesian' or 'Spherical';
%    fmt              = '%7g';
%
% NOTE 1 that wind directions need to be in the local coordinate
% system of the model, so you need to (i) transform the grid coordinates AND (ii)
% rotate the winds if you want to use zonal/meridional winds for a cartesian model.
%
% NOTE 2 to test the IO of the meteo by Delft3D run a fake simulation
% on the meteo grid itself, with meteo time step identical to the meteo
% interval. Add keywords to mdf file to make them end up in trim file:
% airout and heaout. Use depth of 1e3 m to prevent crash.

%
%See also: DELFT3D_IO_METEO, KNMI, GRIB, NETCDF, DELFT3D_IO_METEO_WRITE_TUTORIAL

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% TO DO check for isempty(fileparts('meteo_on_curvilinear_grid'))

%% Options
%-----------------------------

OPT.header           = '';

OPT.filetype         = 'meteo_on_curvilinear_grid';
OPT.nodata_value     = -999;
OPT.grid_file        = ['temp.grd'];
OPT.writegrd         = true;
OPT.quantity         = 'x_wind';
OPT.unit             = 'm s-1';

OPT.refdatenum       = datenum(1970,1,1);
OPT.hr               = (time - OPT.refdatenum)*24;
OPT.timezone         = '+00:00';

OPT.OS               = 'unix';
OPT.newgrid          = 0;
OPT.CoordinateSystem = [];
OPT.fmt              = '%7g';

nextarg = 1;

if nargin > 3
    if isnumeric(varargin{1})
        x = varargin{1};
        y = varargin{2};
        nextarg = 3;
        OPT.newgrid = 1;
    end
end

OPT = setproperty(OPT,varargin{nextarg:end});

%% Open file
%-----------------------------

if isnumeric  (filehandle)
    fid =       filehandle;
elseif ischar (filehandle)
    fid = fopen(filehandle,'w');
end

%% Header
%-----------------------------

if strcmpi(OPT.filetype,'meteo_on_equidistant_grid')
    error('meteo_on_equidistant_grid not implemented yet, complete the code yourselves?')
    if OPT.newgrid
        n_cols = size(data,3);
        n_rows = size(data,2);
        dx = diff(x(1,:)); dx = dx(1);
        dy = diff(y(:,1)); dy = dy(1);
        fprintf  (fid,'FileVersion      = 1.03')                     ;%# Version of meteo input file, to check if the newest file format is used
        fprinteol(fid,OPT.OS);
        fprintf  (fid,'filetype         = meteo_on_equidistant_grid');%# Type of meteo input file: meteo_on_flow_grid, meteo_on_equidistant_grid, meteo_on_curvilinear_grid or meteo_on_spiderweb_grid
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['n_cols           =',num2str(n_cols)])
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['n_rows           =',num2str(n_rows)])
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['grid_unit        = m']);
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['x_llcorner       = ',num2str(min(min(x)))]);
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['y_llcorner       = ',num2str(min(min(y)))]);
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['dx               = ',num2str(dx)]);
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['dy               = ',num2str(dy)]);
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['n_quantity       = 1']);
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['quantity1        = ',quantity]);
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['unit1            = ',unit]);
        fprinteol(fid,OPT.OS);
        fprintf  (fid,['NODATA_value     = ',nodata_value]);
        fprinteol(fid,OPT.OS);
        
    end
    %    FileVersion   =   1.02
    % filetype      =   meteo_on_equidistant_grid
    % n_cols        =   77
    % n_rows        =   75
    % grid_unit     =   m
    % x_llcorner    =   -85000.000
    % y_llcorner    =   325000.000
    % value_pos     =   centre
    % dx            =   5000
    % dy            =   5000
    % n_quantity    =   1
    % quantity1     =   air_pressure
    % unit1         =   mbar
    % NODATA_value  =   -999.000
    % TIME =   1.00 hours since 2006-10-26 01:00:00 +00:00
    
    fprintf  (fid,'TIME = %f hours since %s %s',OPT.hr,... % write all decimals
        datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM:SS'),...
        OPT.timezone);
    fprinteol(fid,OPT.OS)
    
    data(isnan(data))=OPT.nodata_value;
    
    %  dim1 = rows
    %  dim2 = columns, so loop over dim2 (see data_row = grid_row above)
    % (dim1=0, dim2=0) is lower left corner, so loop dim in reverse, to have LL as first value (see first_data_value = grid_llcorner above)
    
    for m=size(data,2):-1:1
        fprintf  (fid,[OPT.fmt,' '],data(:,m));
        fprinteol(fid,OPT.OS);
    end
    
elseif strcmpi(OPT.filetype,'meteo_on_curvilinear_grid')
    
    if OPT.newgrid
        fprintf  (fid,'### START OF HEADER');
        fprinteol(fid,OPT.OS)
        fprintf  (fid,'# Created with $Id$ $Headurl: $ on %s',datestr(now));
        fprinteol(fid,OPT.OS)
        
        OPT.header = cellstr(OPT.header);
        for ii=1:length(OPT.header)
            fprintf  (fid,'%s',['# ',OPT.header{ii}]);
            fprinteol(fid,OPT.OS);
        end
        
        fprintf  (fid,'FileVersion      = 1.03')                     ;%# Version of meteo input file, to check if the newest file format is used
        fprinteol(fid,OPT.OS)
        fprintf  (fid,'filetype         = meteo_on_curvilinear_grid');%# Type of meteo input file: meteo_on_flow_grid, meteo_on_equidistant_grid, meteo_on_curvilinear_grid or meteo_on_spiderweb_grid
        fprinteol(fid,OPT.OS)
        fprintf  (fid,'NODATA_value     = %f',OPT.nodata_value)      ;%# Value used for undefined or missing data
        fprinteol(fid,OPT.OS)
        fprintf  (fid,'grid_file        = %s',OPT.grid_file)         ;%# Separate (curvi-linear) grid on which the wind can be specified
        
        % grid has to be written inside DELFT3D_IO_METEO_WRITE to ensure same shape as data block
        
        if exist('wlgrid')==0
            error('function wlgrid missing.')
        end
        
        %% if no (relative) path is specified, it will be written in same path as amx file (but with LOCAL reference to grd file inside amx file)
        if isempty(fileparts(OPT.grid_file))
            OPT.grid_file = fullfile(fileparts(filehandle),OPT.grid_file);
        end
        if OPT.writegrd
            wlgrid('write','filename',OPT.grid_file,'X',x,'Y',y,'CoordinateSystem',OPT.CoordinateSystem,'Format','NewRGF')
            disp(['written grid file: ',OPT.grid_file]);
        end
        
        fprinteol(fid,OPT.OS)
        fprintf  (fid,'first_data_value = grid_llcorner')            ;%# Options: grid_llcorner, grid_ul_corner, grid_lrcorner or grid_urcorner
        fprinteol(fid,OPT.OS)
        fprintf  (fid,'data_row         = grid_row')                 ;%# Options: grid_row or grid_col. For switching rows and columns.
        fprinteol(fid,OPT.OS)
        fprintf  (fid,'n_quantity       = 1')                        ;%# Number of quantities prescribed in the file
        fprinteol(fid,OPT.OS)
        fprintf  (fid,'quantity1        = %s',OPT.quantity)          ;%# Name of quantity1 (x_wind, y_wind, air_pressure, relative_humidity, air_temperature or cloudiness)
        fprinteol(fid,OPT.OS)
        fprintf  (fid,'unit1            = %s',OPT.unit)              ;%# Unit of quantity1 (m s-1 for velocities, Pa/ mbar for air_pressure, % for relative_humidity or cloudiness and Celcius for air_temperature)
        fprinteol(fid,OPT.OS)
        fprintf(fid,'### END OF HEADER');
        fprinteol(fid,OPT.OS)
    end
    
    %% Time
    %  # Fixed format: <time> <time unit> "since" <date> <time> <time zone>
    %-----------------------------
    
    fprintf  (fid,'TIME = %f hours since %s %s',OPT.hr,... % write all decimals
        datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM:SS'),...
        OPT.timezone);
    fprinteol(fid,OPT.OS)
    
    %% Data
    %-----------------------------
    
    data(isnan(data))=OPT.nodata_value;
    
    %  dim1 = rows
    %  dim2 = columns, so loop over dim2 (see data_row = grid_row above)
    % (dim1=0, dim2=0) is lower left corner, so loop dim in reverse, to have LL as first value (see first_data_value = grid_llcorner above)
    
%     for m=size(data,2):-1:1 (WRONG???)
    for m=1:size(data,2);        
        fprintf  (fid,[OPT.fmt,' '],data(:,m));
        fprinteol(fid,OPT.OS);
    end
    
elseif strcmpi(OPT.filetype,'meteo_on_spiderweb_grid')
    
    error('meteo_on_spiderweb_grid not implemented yet, give it a try yourselves?')
    
else
    
    error(['Unknown meteo filetype: ''',OPT.filetype,''''])
    
end

%% Close files (only when 1st call AND no reuse requested)
%-----------------------------

if nargout==0 & ischar(filehandle)
    fclose(fid);
end

%% EOF