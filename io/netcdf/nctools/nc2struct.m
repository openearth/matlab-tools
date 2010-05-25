function varargout = nc2struct(ncfile,varargin)
%NC2STRUCT   load netCDF file with to struct (beta)
%
%   dat      = struct2nc(ncfile,<keyword,value>)
%% [dat,atr] = struct2nc(ncfile,<keyword,value>)
%
%   ncfile - netCDF file name
%   dat    - structure of 1D arrays of numeric/character data
%%  atr    - optional structure of file and variable attributes
%
% Note that this function has limited applicability only
% because it does the naming of dimensions based on size only
% and not on the actual meaning of the dimension.
%
% Implemented <keyword,value> pairs are:
% * ...
%
% NC2STRUCT can be used to facilitate an experimental development: 
% loading a catalog.nc for a THREDDS OPeNDAP server as an 
% alternative to the difficult-to-parse catalog.xml.
%
% Example 2:
%
%  [D,M] = nc2struct('file_created_with struct2nc.nc');
%  [D,M] = nc2struct('catalog.nc');
%
% NOTE: do not use for VERY BIG! files, as your memory will swamped.
%
%See also: STRUCT2XLS, XLS2STRUCT, SDSAVE_CHAR, SDLOAD_CHAR, STRUCT2NC, NC_GETALL

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
% However, why does nc_getall currently not work with opendap libaries??
% And what about globala atts, part of D (NO), or part of M(perhaps), or separate?

%% Load file info

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
     fileinfo.Dataset = fldname.DataSet;
     disp(['warning: please use newer version of snctools (e.g. ',which('matlab\io\snctools\nc_info'),') instead of (',which('nc_info'),')'])
   else
      error('neither field ''Dataset'' nor ''DataSet'' returned by nc_info')
   end
   
%% Load all fields

   ndat = length(fileinfo.Dataset);
   for idat=1:ndat
      fldname     = fileinfo.Dataset(idat).Name;
      D.(fldname) = nc_varget(fileinfo.Filename,fldname);
      if ischar(D.(fldname))
         D.(fldname) = cellstr(D.(fldname));
      end
   end
   
   varargout = {D};

%% EOF