function ygr = xb_generate_ygrid(yin, varargin)
%XB_GENERATE_YGRID  Creates a model grid in y-direction based on minimum and maximum cell size and area of interest
%
%   Generates a model grid in y-direction using two grid cellsizes. The
%   minimum grid cellsize is used for the area of interest. The maximum is
%   used near the lateral borders. A gradual transition between the grid
%   cellsizes over a specified distance is automatically generated. The
%   area of interest can be defined in several manners. By default, this is
%   a distance of 100m in the center of the model.
%
%   Syntax:
%   ygr = xb_generate_ygrid(yin, varargin)
%
%   Input:
%   yin       = range of y-coordinates to be included in the grid
%   varargin  = dymin:                  minimum grid cellsize
%               dymax:                  maximum grid cellsize
%               area_type:              type of definition of the area of
%                                       interest (center/range)
%               area_size:              size of the area of interest
%                                       (length in case of area_type
%                                       center, from/to range in case of
%                                       area_type range)
%               transition_distance:    distance over which the grid
%                                       cellsize is gradually changed from
%                                       mimumum to maximum
%
%   Output:
%   ygr       = generated grid in y_direction
%
%   Example
%   ygr = xb_generate_ygrid(yin)
%
%   See also xb_generate_grid, xb_generate_xgrid

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
% Created: 01 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'dymin', 5, ...
    'dymax', 20, ...
    'area_type', 'center', ...
    'area_size', 100, ...
    'transition_distance', 100 ...
);

OPT = setproperty(OPT, varargin{:});

%% make grid

if length(yin) <= 1
    % one-dimensional model
    ygr = [0:2]*OPT.dymin;
else
    if OPT.dymin == OPT.dymax
        % equidistant grid
        ygr = min(yin):OPT.dymin:max(yin);
    else
        % variable, two-dimensional grid
        switch OPT.area_type
            case 'center'
                ygr = mean(yin)-OPT.area_size/2:OPT.dymin:mean(yin)+OPT.area_size/2;
            case 'range'
                ygr = OPT.area_size(1):OPT.dymin:OPT.area_size(2);
            otherwise
                % default center with length one
                ygr = mean(yin)+[-1 1]*OPT.dymin/2;
        end
        
        % grid transition
        [ff nf gridf] = grid_transition(OPT.dymin, OPT.dymax, OPT.transition_distance);
        ygr = [ygr(1)-fliplr(gridf) ygr ygr(end)+gridf];
        
        % extend till borders
        ygr = [fliplr(ygr(1)-OPT.dymax:-OPT.dymax:min(yin)) ygr ygr(end)+OPT.dymax:OPT.dymax:max(yin)];
    end
end
