function xb = xb_get_transect(xb, varargin)
%XB_GET_TRANSECT  Squeezes an XBeach output structure to a single transect
%
%   Squeezes an XBeach output structure to a single transect
%
%   Syntax:
%   xb = xb_get_transect(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = transect:   transect number
%               dim:        dimension that should be squeezed
%
%   Output:
%   xb        = squeezed XBeach output structure
%
%   Example
%   xb = xb_get_transect(xb)
%   xb = xb_get_transect(xb, 'transect', 10)

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
% Created: 20 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_get_transect.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/applications/xbeach/xb_analysis/xb_get_transect.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'transect',     [], ...
    'dim',          2   ...
);

OPT = setproperty(OPT, varargin{:});

%% determine transect

if isempty(OPT.transect)
    if xs_exist(xb, 'DIMS.globaly')
        t = ceil(xs_get(xb, 'DIMS.globaly')/2);
    else
        t = 1;
    end
else
    t = OPT.transect;
end

%% squeeze structure

data = {xb.data.name};
for i = 1:length(data)
    if isnumeric(xb.data(i).value)
        if size(xb.data(i).value, 2) >= t
            idx             = num2cell(repmat(':',1,ndims(xb.data(i).value)));
            idx{OPT.dim}    = t;
            xb.data(i).value = xb.data(i).value(idx{:});
        end
    end
end
