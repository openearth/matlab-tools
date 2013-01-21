function S = datestrnan(varargin)
%DATESTRNAN   datestr-version that does not crash on NaNs
%
%    S = DATESTRNAN(...,FillSymbol) where FillSymbol 
%    is the symbol returned in case of NaNs,
%
%    S = DATESTRNAN(V) uses default FillSymbol =''
%
%    Example
%    S = datestrnan([nan now],'yyyy','*')
%
% See also: DATESTR

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for NMDC.eu
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   V          = varargin{1};
   if nargin ==1
   FillValue  = ' ';
   else
   FillValue  = varargin{end};
   end
   mask       = ~isnan(V);
   S2         = datestr(V(mask),varargin{2:end-1});
   sz         = size(S2); sz(1) = length(V);
   S          = repmat(FillValue,sz);
   index      = find(mask);
   S(index,:) = S2;
   
   
   