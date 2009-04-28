function index = atrname2index(fileinfo,name,varargin)
%ATRNAME2INDEX   get index of attribute name from fileinfo = nc_info(...)
%
%   index = atrname2index(fileinfo,name)
%
% returns empty if no matching variable is found. Works for 
% global attribites and for variable attribites.
%
% Example:
%
%   index = atrname2index(F,'history')
%   F.Attribute(history)
%
%   index = atrname2index(F.Dataset(1),'standard_name')
%   F.Dataset(1).Attribute(index)
%
%See also: NC_INFO, varname2index

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Deltares
%       Gerben J. de Boer
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

   OPT.debug = 0;
   
   OPT       = setProperty(OPT,varargin{:});
   
   index     = [];

   %% find index of coordinates attribute
   natr = length(fileinfo.Attribute);
   for iatr=1:natr
   if OPT.debug
      disp([num2str(iatr,'%0.3d'),': ',fileinfo.Attribute(iatr).Name])
   end
   if strcmpi(fileinfo.Attribute(iatr).Name,name)
      index = iatr;
      if ~OPT.debug
         break
      end
   end
   end  
         
%% EOF         