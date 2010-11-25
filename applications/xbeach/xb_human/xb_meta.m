function xbSettings = xb_meta(xbSettings, func, type, file)
%XB_META  Sets meta data of XBeach structure
%
%   Sets meta data of XBeach structure.
%
%   Syntax:
%   xbSettings = xb_meta(xbSettings, func, type)
%
%   Input:
%   xbSettings  = XBeach structure array
%   func        = Name of function that sets the meta data (mfilename)
%   type        = Type of data in structure (params, waves, etc)
%
%   Output:
%   xbSettings  = Updated XBeach structure array
%
%   Example
%   xbSettings = xb_meta(xbSettings, 'xb_set', 'waves')
%
%   See also xb_set, xb_show

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

%% set meta data

if ~xb_check(xbSettings); error('Invalid XBeach structure'); end;

xbSettings.date = datestr(now);

if exist('func', 'var')
    xbSettings.function = func;
end

if exist('type', 'var')
    xbSettings.type = type;
end

if exist('file', 'var')
    if iscell(file)
        for i = 1:length(file)
            file{i} = abspath(file{i});
        end
        file = sprintf('%s\n', file{:});
        file = file(1:end-1);
    else
        file = abspath(file);
    end
    
    xbSettings.file = file;
end