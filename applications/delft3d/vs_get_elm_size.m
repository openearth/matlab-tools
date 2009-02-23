function Sz = vs_get_elm_size(NFSstruct,ElmName,varargin)
%VS_GET_ELM_SIZE   Extract size of NEFIS Element data
%
% Sz = vs_get_elm_size(NFSstruct,ElmName) returns
% size of Element ElmName in NEFIS struct
% as returned by NFSstruct = vs_use(...).
%
% Sz = vs_get_elm_size(NFSstruct,ElmName,dim) returns
% only size of dimension dim.
%
% Not case sensitive, neither for ElmName, not
% for strings in NFSstruct.
%
% � G.J. de Boer, TU Delft, Environmental Fluid Mechanics, Nov 2006
%
% See also: vs_get_elm_def, vs_get_grp_size

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

   Sz = [];
   for i=1:length(NFSstruct.ElmDef)
      if strcmp(upper(NFSstruct.ElmDef(i).Name),...
                                 upper(ElmName))
      Sz = NFSstruct.ElmDef(i).Size;
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
