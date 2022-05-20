function varargout = strfindbi(txt,pattern)
%STRFINDBI   Find string within cellstr.
%
%   b       = strfindbi(cellstr,pattern)
%   [b,ind] = strfindbi(cellstr,pattern)
%
% returns boolean matrix b (and indices matrix ind) of 
% cellstr that have a (one or more) matches of pattern.
%
% Note: case insensitive.
%
% Example:
%
%   ind = strfindb({'aa','ab','bb'},'a') % is [1 1 0]
%   ind = strfindb({'aa','ab','bb'},'A') % is [1 1 0] too
%
%See also: STRFIND, STRMATCH, STRMATCHB, STRFINDB

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Aug 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

c = strfind(lower(txt),lower(pattern));
b = ~cellfun(@isempty,c);

if     nargout==1
     varargout = {b};
elseif nargout==2
     varargout = {b,find(b)};
end
