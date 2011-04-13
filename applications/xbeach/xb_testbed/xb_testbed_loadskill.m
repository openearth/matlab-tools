function s = xb_testbed_loadskill(var)
%XB_TESTBED_LOADSKILL  Loads testbed skill history of specific variable
%
%   Loads testbed skill history of specific variable
%
%   Syntax:
%   s = xb_testbed_loadskill(var)
%
%   Input:
%   var       = Variable name
%
%   Output:
%   s         = Struct with skill history
%
%   Example
%   s = xb_testbed_loadskill('zb')
%
%   See also xb_testbed_storeskill

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 13 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% load testbed skill history

s = struct( ...
    'file',     '', ...
    'revision', [], ...
    'r2',       [], ...
    'sci',      [], ...
    'relbias',  [], ...
    'bss',      []      );
    
if xb_testbed_check
    
    p = xb_testbed_getpref;
    
    s.fname = fullfile(p.storage, p.binary, p.type, p.test, p.run, [var '.mat']);
    
    if exist(s.fname, 'file')
        s = load(s.fname);
    end
end
