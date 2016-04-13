function Sz = vs_get_grp_size(NFSstruct,GrpName,varargin)
%VS_GET_GRP_SIZE      Read size of NEFIS Element data
%
% Sz = vs_get_grp_size(NFSstruct,GrpName) returns 
% size of Group GrpName in NEFIS struct
% as returned by NFSstruct = vs_use(...).
%
% Sz = vs_get_elm_size(NFSstruct,ElmName,dim) returns
% only size of dimension dim.
%
% Not case sensitive, neither for GrpName, not
% for strings in NFSstruct.
%
% Example: vs_get_grp_size(NFSstruct,'map-avg-series')
%
% See also: VS_GET_ELM_SIZE, VS_*

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

   if ischar(NFSstruct)
      NFSstruct = vs_use(NFSstruct);
   end

   Sz = 0;
   for i=1:length(NFSstruct.GrpDat)
      if strcmpi(NFSstruct.GrpDat(i).Name,GrpName)
      Sz = NFSstruct.GrpDat(i).SizeDim;
      end
   end

   if nargin==3
      dim = varargin{1};
      if length(Sz) < dim
         Sz  = 1;      
      else
         Sz  = Sz(dim);      
      end
   end