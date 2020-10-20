function varargout = nc2struct(ncfile,varargin)
%NC2STRUCT   load netCDF file with to struct (beta)
%
%   dat      = nc2struct(ncfile,<keyword,value>)
%  [dat,atr] = nc2struct(ncfile,<keyword,value>)
%
%   ncfile - netCDF file name
%   dat    - structure of 1D arrays of numeric/character data
%   atr    - optional structure of file and variable attributes
%
% For NC2STUCT <keyword,value> options and defaults call
% without arguments: nc2struct() . 
% * exclude: cell array with subset of variables NOT to load, e.g.: {'a','b'}
% * include: cell array with subset of variables ONLY to load, e.g.: {'lon','lat'}
% * rename : cell array describing how to rename variables in netCDF
%            file to variables in struct, e.g.: {{'x','y'},{'x1','x2'}}
%
% NC2STRUCT can be used to facilitate an experimental development: 
% loading a catalog.nc for a THREDDS OPeNDAP server as an 
% alternative to the difficult-to-parse catalog.xml.
%
% Example:
%
%  [dat,atr] = nc2struct('file_created_with struct2nc.nc');
%  [dat,atr] = nc2struct('catalog.nc');
%  [dat,atr] = nc2struct('catalog.nc','exclude',{'x','y'});
%  [dat,atr] = nc2struct('catalog.nc','include',{'lon','lat'});
%
% NOTE: do not use for VERY BIG! files, as your memory will be swamped.
%
%See also: STRUCT2NC, XLS2STRUCT, CSV2STRUCT, SDLOAD_CHAR, LOAD & SAVE('-struct',...)
%          NC_DUMP,   STRUCT2XLS, CSV2STRUCT, SDSAVE_CHAR, NC_GETALL, 

% TO DO: pass global attributes as <keyword,value> or as part of M.

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

% Behaviour should be as of nc_getall, but without the data being part of M, but in a separate struct D.
% And what about global atts, part of D (NOOOOOOOOO!), or part of M(perhaps), or part of M.nc_global.?

OPT.global2att   = 2; % 0=not at all, 1=as fields, 2=as subfields of nc_global
OPT.time2datenum = 1; % time > datenum in extra variable datenum
OPT.exclude      = {};
OPT.rename       = {{},{}};
OPT.include      = {};

if nargin==0
   varargout = {OPT};
   return
end

OPT = setproperty(OPT,varargin);

%% Load file info

   % get info from ncfile
   if isstruct(ncfile)
      fileinfo = ncfile;
   else
      fileinfo = nc_info(ncfile);
   end
   
%% get all variable names

if isempty(OPT.include)
   OPT.include = {fileinfo.Dataset.Name};
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
   
%% Load all fields

  D = [];

   ndat = length(fileinfo.Dataset);
   for idat=1:ndat
      fldname     = fileinfo.Dataset(idat).Name;
      if ~any(strmatch(fldname,OPT.exclude, 'exact')) & ...
          any(strmatch(fldname,OPT.include, 'exact'))
         fldname_nc = fldname;
         if any(strmatch(fldname,OPT.rename{1}, 'exact'))
            j = strmatch(fldname,OPT.rename{1}, 'exact');
            fldname = OPT.rename{2}{j};
         end
         D.(fldname) = nc_varget(fileinfo.Filename,fldname_nc);
         if OPT.time2datenum
            if strcmp(fldname_nc,'time')
               if nc_isatt(fileinfo.Filename,'time','units')
                  D.datenum = nc_cf_time(fileinfo.Filename,fldname);
                 disp([mfilename,': added extra variable with Matlab datenum=f(',fldname,')'])
               end
            else
             if ~isempty(fileinfo.Dataset(idat).Attribute);
             j = strmatch('standard_name',{fileinfo.Dataset(idat).Attribute.Name}, 'exact');
              if ~isempty(j)
               if strcmpi(fileinfo.Dataset(idat).Attribute(j).Value,'time')
               D.datenum = nc_cf_time(fileinfo.Filename,fldname);
               disp([mfilename,': added extra variable with Matlab datenum=f(',fldname,')'])
               end
              end
             end
            end
         end
         if ischar(D.(fldname))
            if isvector(D.(fldname))
               D.(fldname) = D.(fldname)(:)';
            end
            D.(fldname) = cellstr(D.(fldname));
         end
      end % exclude/include
   end
   
if nargout==1

   varargout = {D};
   
else

   ndat = length(fileinfo.Dataset);
   if OPT.global2att>0
   
%% attributes
   
   for iatt=1:length(fileinfo.Attribute);
      attname  = fileinfo.Attribute(iatt).Name;
      attname  = mkvar(attname); % ??? Invalid field name: 'CF:featureType'.
      if     OPT.global2att==1;
         M.(attname) = fileinfo.Attribute(iatt).Value;
      elseif OPT.global2att==2
         M.nc_global.(attname) = fileinfo.Attribute(iatt).Value;
      end
   end
   end
   
%% data
   
   for idat=1:ndat
      fldname     = fileinfo.Dataset(idat).Name;
      if ~any(strmatch(fldname,OPT.exclude, 'exact')) & ...
          any(strmatch(fldname,OPT.include, 'exact'))
         if any(strmatch(fldname,OPT.rename{1}, 'exact'))
            j = strmatch(fldname,OPT.rename{1}, 'exact');
            fldname = OPT.rename{2}{j};
         end
         for iatt=1:length(fileinfo.Dataset(idat).Attribute);
                      attname  = fileinfo.Dataset(idat).Attribute(iatt).Name;
                      attname  = mkvar(attname); % ??? Invalid field name: '_FillValue'.
         M.(fldname).(attname) = fileinfo.Dataset(idat).Attribute(iatt).Value;
         end
      end % exclude/include
   end
   
   if nargout<2
   varargout = {D};
   else
   varargout = {D,M};
   end

end

%% EOF