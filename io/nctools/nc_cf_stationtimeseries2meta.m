function nc_cf_stationtimeseries2meta(varargin)
%NC_CF_STATIONTIMESERIES2META   extract meta inform from all NetCDF files in one directory, plot it, and export to Excel table
%
%     NC_CF_STATIONTIMESERIES2META(<keyword,value>) 
%
%  reads meta info (lon,lat,min(time), max(time), nt) from all 
%  NetCDF files in a directory, make a plan view plot and saves table to excel file.
%  The following <keyword,value> pairs have been implemented:
%
%   * directory_nc   directory where to put the nc data to (default [])
%   * mask           file mask (default '*.nc')
%
%See also: snctools

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

   OPT.directory_nc = [];
   OPT.mask         = '*.nc';
   OPT.basename     = '_inventory';
   
%% Keyword,value
%------------------

   OPT = setProperty(OPT,varargin{:});

%% File loop to get meta-data
%------------------

   OPT.files        = dir([OPT.directory_nc,filesep,OPT.mask]);

   for ifile=1:length(OPT.files)
   
      OPT.filename = [OPT.directory_nc, filesep, OPT.files(ifile).name]; % e.g. 'etmgeg_273.txt'
   
      disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])
      
      OPT.lat        = lookupVarnameInNetCDF('ncfile', OPT.filename, 'attributename', 'standard_name', 'attributevalue','latitude'  );
      OPT.lon        = lookupVarnameInNetCDF('ncfile', OPT.filename, 'attributename', 'standard_name', 'attributevalue','longitude' );
      OPT.time       = lookupVarnameInNetCDF('ncfile', OPT.filename, 'attributename', 'standard_name', 'attributevalue','time'      );
      OPT.station_id = lookupVarnameInNetCDF('ncfile', OPT.filename, 'attributename', 'standard_name', 'attributevalue','station_id');;
   
      files(ifile).lat        = nc_varget(OPT.filename,OPT.lat);
      files(ifile).lon        = nc_varget(OPT.filename,OPT.lon);
      time                    = nc_varget(OPT.filename,OPT.time);
      files(ifile).nt         = length(time);
      files(ifile).datenummin = min(time);
      files(ifile).datenummax = max(time);
      files(ifile).station_id = nc_varget(OPT.filename,OPT.station_id);
      
   end

%% Reorganize meta-data
%------------------

   A.filename    = {OPT.files.name};
   A.lat         = [files.lat];
   A.lon         = [files.lon];
   A.nt          = [files.nt];
   A.datenummin  = [files.datenummin];
   A.datenummax  = [files.datenummax];
   
   A.station_id  = {files.station_id};
   if isnumeric(A.station_id{1})
   A.station_id = num2str(cell2mat(A.station_id)');
   else
   A.station_id = char   (A.station_id); % cell2  char
   end

   units.filename    = 'string';
   units.lat         = nc_attget(OPT.filename,OPT.lat ,'units');
   units.lon         = nc_attget(OPT.filename,OPT.lon ,'units');
   units.nt          = '# of observations';
   units.datenummin  = nc_attget(OPT.filename,OPT.time,'units');
   units.datenummax  = nc_attget(OPT.filename,OPT.time,'units');
   units.station_id  = 'string';

% Plot locations
%--------------------
   plot   (A.lon,A.lat,'ko','linewidth',2)
   hold    on
   plotc  (A.lon,A.lat,A.nt,'o','linewidth',2)
   axislat(52)
   tickmap('ll')
   caxis  ([min(A.nt) max(A.nt)])
   colorbarwithtitle('n [#]')
   grid    on
   hold    on
   title  ({OPT.directory_nc,['# stations: ',num2str(length(OPT.files))]})
   
   print2screensize([OPT.directory_nc,filesep,OPT.basename,'.png'])

% Save all meta-data
%--------------------
   A.filename   = char(A.filename);
   
   struct2xls([OPT.directory_nc,filesep,OPT.basename,'.xls'],A,'units',units)
   
%% EOF   


