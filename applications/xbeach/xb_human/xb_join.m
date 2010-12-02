function xb = xb_join(varargin)
%XB_JOIN  Joins multiple XBeach structures into a single XBeach structure
%
%   Adding from left to right the data fields of all provided XBeach
%   structures. The meta-information from the first XBeach structure is
%   used.
%
%   Syntax:
%   xb = xb_join(varargin)
%
%   Input:
%   varargin  = Collection of XBeach structures
%
%   Output:
%   xb        = Joined XBeach structure
%
%   Example
%   xb = xb_join(xb1, xb2, xb3, xb4, ... )
%
%   See also xb_split, xb_empty, xb_set, xb_get

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 02 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% join structures

xb = [];

for i = 1:length(varargin)
    if xb_check(varargin{i})
        if isempty(xb)
            xb = varargin{i};
        else
            for j = 1:length(varargin{i}.data)
                if isfield(varargin{i}.data, 'units')
                    xb = xb_set(xb, '-units', ...
                        varargin{i}.data(j).name, {varargin{i}.data(j).value varargin{i}.data(j).units});
                else
                    xb = xb_set(xb, ...
                        varargin{i}.data(j).name, varargin{i}.data(j).value);
                end
            end
        end
    end
end
