function fpath = abspath(fpath)
%ABSPATH  Converts relative path from current working directory to an absolute path
%
%   Converts a relative path from the current working directory to an
%   absolute path by glueing the pwd and the relative path together and
%   eliminating relative references like . and ..
%
%   Syntax:
%   fpath = abspath(fpath)
%
%   Input:
%   fpath   = relative path to be converted
%
%   Output:
%   fpath   = absolute path
%
%   Example
%   fpath = abspath(fpath)
%
%   See also 

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
% Created: 24 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% convert to absolute path

% make sure fileseperators are right
fpath = fullfile(fpath);

% check if path is indeed relative
if (ispc() && fpath(2) ~= ':') || (isunix() && fpath(1) ~= filesep)
    
    % it is a relative path, explode by filesep
    p = regexp(fullfile(pwd, fpath), filesep, 'split');
    
    % replace relative references
    idx = true(size(p));
    for i = 1:length(p)
        switch p{i}
            case '.'
                idx(i) = false;
            case '..'
                idx(i-1:i) = false;
        end
    end
    
    % glue path together
    fpath = sprintf(['\' filesep '%s'], p{idx});
    
    % help windows users
    if ispc(); fpath = fpath(2:end); end;
end
