function xb_testbed_storeskill(var, r2, sci, relbias, bss)
%XB_TESTBED_STORESKILL  Updates testbed skill history for specific variable
%
%   Updates testbed skill history for specific variable
%
%   Syntax:
%   xb_testbed_storeskill(var, r2, sci, relbias, bss)
%
%   Input:
%   var       = Variable name
%   r2        = R^2 score
%   sci       = Sci score
%   relbias   = Relative bias
%   bss       = Brier Skill score
%
%   Output:
%   none
%
%   Example
%   xb_testbed_storeskill('zb', r2, sci, relbias, bss)
%
%   See also xb_testbed_loadskill

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

%% update testbed skill history

if xb_testbed_check
    
    p = xb_testbed_getpref;
    
    s = xb_testbed_loadskills(var);
    
    % make dirs
    if ~exist(s.file, 'file')
        dirs = {p.storage, p.binary, p.type, p.test, p.run};
        for i = 1:length(dirs)
            if ~exist(fullfile(dirs{1:i}), 'dir'); mkdir(fullfile(dirs{1:i})); end;
        end
    end
        
    if ~ismember(p.revision, skills.revision)
        s.revision  = [s.revision revision];
        s.r2        = [s.r2 r2];
        s.sci       = [s.sci sci];
        s.relbias   = [s.relbias relbias];
        s.bss       = [s.bss bss];
        
        save(s.file, '-struct', 's');
    end
end