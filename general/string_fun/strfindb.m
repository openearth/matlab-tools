function varargout = strfindb(txt,pattern)
%STRFINDB   Find string within cellstr.
%
%   b       = strfindb(cellstr,pattern)
%   [b,ind] = strfindb(cellstr,pattern)
%
% returns boolean matrix b (and indices matrix ind) of 
% cellstr that have a (one or more) matches of pattern.
%
% Note: case sensitive.
%
% Example:
%
%   ind = strfindb({'aa','ab','bb'},'a') % is [1 1 0]
%   ind = strfindb({'aa','ab','bb'},'A') % is [0 0 0]
%
%See also: STRFIND, STRMATCH, STRMATCHB, STRFINDBI

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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

c = strfind(txt,pattern);
b = ~cellfun(@isempty,c);

if     nargout==1
     varargout = {b};
elseif nargout==2
     varargout = {b,find(b)};
end
