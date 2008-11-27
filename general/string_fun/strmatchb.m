function booleans = strmatcb(varargin)
%STRMATCHB Find possible matches for string.
%
%   Same as STRMATCH, but returns boolean matrix instead if indices.
%
%   I = STRMATCH(STR, STRARRAY) looks through the rows of the character
%   array or cell array of strings STRARRAY to find strings that begin
%   with the string contained in STR, and returns the matching row indices. 
%   Any trailing space characters in STR or STRARRAY are ignored when 
%   matching. STRMATCH is fastest when STRARRAY is a character array. 
%
%   I = STRMATCH(STR, STRARRAY, 'exact') compares STR with each row of
%   STRARRAY, looking for an exact match of the entire strings. Any 
%   trailing space characters in STR or STRARRAY are ignored when matching.
%
%   Examples
%     i = strmatch('max',strvcat('max','minimax','maximum'))
%   returns i = [1; 3] since rows 1 and 3 begin with 'max', and
%     i = strmatch('max',strvcat('max','minimax','maximum'),'exact')
%   returns i = 1, since only row 1 matches 'max' exactly.
%   
%   See also STRMATCH, STRFIND, STRVCAT, STRCMP, STRNCMP, REGEXP.

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

indices = STRMATCH(varargin{:});

booleans = repmat(false,size(varargin{2},1),1);

booleans(indices) = true;

%% EOF