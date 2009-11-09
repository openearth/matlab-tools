function varargout = nc_cf_time(ncfile,varargin)
%NC_CF_TIME   readfs all time variables from a netCDF file into Matlab datenumber
%
%   datenumbers = nc_cf_time(ncfile);
%   datenumbers = nc_cf_time(ncfile,<varname>);
%
% extract all time vectors from netCDF file ncfile as Matlab datenumbers.
% ncfile  = name of local file, OPeNDAP address, or result of ncfile = nc_info()
% time    = defined according to the CF convention as in:
% varname = optional name of specific time vector
%
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/ch04s04.html
%
% When there is only one time variable, an array is returned,
% otherwise a warning is thrown.
%
% Example:
%
%  base      = 'http://opendap.deltares.nl:8080/thredds/dodsC';
%  D.datenum = nc_cf_time([base,'/opendap/knmi/potwind/potwind_343_2001.nc'],'time')
%
%See also: NC_CF_NC_CF_STATIONTIMESERIES, NC_CF_GRID, UDUNITS2DATENUM

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

   %% get info from ncfile
   if isstruct(ncfile)
      fileinfo = ncfile;
   else
      fileinfo = nc_info(ncfile);
   end
   
   %% deal with name change in scntools: DataSet > Dataset
   if     isfield(fileinfo,'Dataset'); % new
     fileinfo.DataSet = fileinfo.Dataset;
   elseif isfield(fileinfo,'DataSet'); % old
     fileinfo.Dataset = fileinfo.DataSet;
     disp(['warning: please use newer version of snctools (e.g. ',which('matlab\io\snctools\nc_info'),') instead of (',which('nc_info'),')'])
   else
      error('neither field ''Dataset'' nor ''DataSet'' returned by nc_info')
   end
   
   %% cycle Dimensions
   % index = [];
   % for idim=1:length(fileinfo.Dimension)
   %    if strcmpi(fileinfo.Dimension(idim).Name,'TIME');
   %    index = [index idim];
   %    end
   % end
   
   if nargin==1
      %% cycle Datasets
      %  all time datasets must have an associated time Dimension
      index = [];
      name  = {};
      nt    = 0;
      for idim=1:length(fileinfo.Dataset)
         if     strcmpi(fileinfo.Dataset(idim).Name     ,'time') & ...
            any(strcmpi(fileinfo.Dataset(idim).Dimension,'time'));
         nt        = nt+1;
         index(nt) =                   idim;
         name {nt} =  fileinfo.Dataset(idim).Name;
         end
      end
      
      %% get data
      for ivar=1:length(index)
         M(ivar).datenum.units = nc_attget(fileinfo.Filename,name{ivar},'units');
         D(ivar).datenum       = nc_varget(fileinfo.Filename,name{ivar});
         D(ivar).datenum       = udunits2datenum(D.datenum,M.datenum.units);
      end
   else
         varname = varargin{1};
         M.datenum.units = nc_attget(fileinfo.Filename,varname,'units');
         D.datenum       = nc_varget(fileinfo.Filename,varname);
         D.datenum       = udunits2datenum(D.datenum,M.datenum.units);
         index           = 1;
   end
   
if nargout<2
   if     length(index)==0
      warning('no time vectors present.')
      varargout = {[]};
   elseif length(index)==1
      varargout = {D(1).datenum};
   else
      warning('multiple time vectors present, please specify furter.')
      varargout = {D};
   end
end

%% EOF