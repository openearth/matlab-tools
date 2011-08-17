function actual_range = nc_actual_range(ncfile,varname)
%NC_ACTUAL_RANGE   reads or retrives actual range from contiguous netCDF variable
%
%  [range] = nc_actual_range(ncfile,varname);
%
% gets the min and max value of a contiguous/coordinate variable by
% * first try to get value of attribute 'actual_range'
% * second get min and max of the 'hull' of the variable in matrix space:
%  for 1D variables: of all endpoints 
%  for 2D variables: of all ribs
%  for 3D variables: of all faces
%  for 4D variables: etc
%
% Make sure that the netCDF variable is contiguous, as no check is
% performed on this, only a warning if varname is not a 
% coordinate variable (lon,lat,x,y,time,z).
%
%See also: snctools

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

%% get actual_range

   info = nc_getvarinfo(ncfile, varname);
   ind  = ismember({info.Attribute.Name}, 'standard_name');
   
   if ~strcmpi({'latitude',...
                'longitude',...
                'projection_x_coordinate',...
                'projection_y_coordinate',...
                'time',...
                'z'},info.Attribute(ind).Value)
      warning('variable is not a CF coordinate variable and might not be contiguous')
   end

%% read attribute if present
   
   ind  = ismember({info.Attribute.Name}, 'actual_range');

   if sum(ind)==1

      actual_range = (info.Attribute(ind).Value);
      if ischar(actual_range); % not everyone knows you can insert matrices inside attributes, so some some put space separates strings in
         actual_range = str2num(actual_range);
      end
      actual_range = actual_range(:)';
   
%% read data
   
   else
       
      sz     = info.Size;
      varmin =  Inf;
      varmax = -Inf;
   
      %  for 1D read all endpoints 
      %  for 2D read all ribs
      %  for 3D read all faces

      for idim=1:length(sz)
         start        =   0.*sz;
         count        =      sz;
         count(idim)  =      min(2,sz(idim));   % mind vectors with dimensions (1 x n)
         stride       = 1+0.*sz; 
         stride(idim) =      max(1,sz(idim)-1); % mind vectors with dimensions (1 x n)
         varval       = nc_varget(ncfile,varname,start,count,stride);
         varmin       = min(min(varval(:)),varmin(:));
         varmax       = max(max(varval(:)),varmax(:));
      end
   
      actual_range = [varmin varmax];
  
   end
 
%% EOF