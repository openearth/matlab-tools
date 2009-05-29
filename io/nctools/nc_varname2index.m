function index = varname2index(fileinfo,name,varargin)
%NC_VARNAME2INDEX   get index of variable name from fileinfo = nc_info(...)
%
%   index = varname2index(fileinfo,name)
%
% returns empty if no matching variable is found.
%
% Example:
%
%   index = varname2index(F,'latitude')
%
%   F.Dataset(index)
%
%See also: NC_INFO, ATRNAME2INDEX

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
   nvar = length(fileinfo.Dataset);
   for ivar=1:nvar
   if OPT.debug
      disp([num2str(ivar,'%0.3d'),': ',fileinfo.Dataset(ivar).Name])
   end
   if strcmpi(fileinfo.Dataset(ivar).Name,name)
      index = ivar;
      if ~OPT.debug
         break
      end
   end
   end  
         
%% EOF         