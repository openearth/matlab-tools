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
%    grid_file        = default, ['temp.grd'];
%    quantity         = 'air_pressure'     ,'x_wind','y_wind','relative_humidity','air_temperature','cloudiness'
%    unit             = 'millibar','pascal','m s-1'          ,'%'                ,'Celsius'        ,'%'
%    refdatenum       = default, datenum(1970,1,1);
%    timezone         = default, '+00:00';
%    OS               = end of line type, default, 'unix';
%    newgrid          = whetehr to write header block, default, 0;
%    CoordinateSystem = to be passed to WLGRID, 'Cartesian' or 'Spherical';
%    fmt              = '%7g';
%
%See also: DELFT3D_IO_METEO, KNMI, GRIB

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

   OPT.header           = {[]};

   OPT.filetype         = 'meteo_on_curvilinear_grid';
   OPT.nodata_value     = nan;
   OPT.grid_file        = ['temp.grd'];
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
   
   OPT = setProperty(OPT,varargin{nextarg:end});
   
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

   error('meteo_on_equidistant_grid not implemented yet, give it a try yourselves?')
   
elseif strcmpi(OPT.filetype,'meteo_on_curvilinear_grid')

   if OPT.newgrid
      fprintf  (fid,'### START OF HEADER');
      fprinteol(fid,OPT.OS)
      fprintf  (fid,'# Created with $Id$ $Headurl:$ on %s',datestr(now));
      fprinteol(fid,OPT.OS)
   
      OPT.header = cellstr(OPT.header);
      for ii=1:length(OPT.header)
      fprintf  (fid,['# ',OPT.header{ii}]);
      fprinteol(fid,OPT.OS);
      end
   
      fprintf  (fid,'FileVersion      = 1.02')                     ;%# Version of meteo input file, to check if the newest file format is used
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
      wlgrid('write','filename',OPT.grid_file,'X',x,'Y',y,'CoordinateSystem',OPT.CoordinateSystem,'Format','NewRGF')
      
      disp(['written grid file: ',OPT.grid_file]);
      
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
      
      for m=size(data,2):-1:1
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