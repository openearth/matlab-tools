function transects = jarkus_interpolatenans(transects, varargin)
%JARKUS_INTERPOLATENANS  Interpolates the missing altitude values in jarkus transects
%
%   Removes the NaN's from the altitude property of a JARKUS transect
%   struct resulting from the jarkus_transects function by interpolation.
%
%   Syntax:
%   transects = jarkus_interpolatenans(transects, varargin)
%
%   Input:
%   varargin    = key/value pairs of optional parameters
%                 prop      = property to be interpolated (default:
%                               altitude)
%                 interp    = property to be used for interpolation
%                               (default: cross_shore)
%                 dim       = dimension to be used for interpolation
%                               (default: 3)
%
%   Output:
%   transects   = interpolated version of transects struct
%
%   Example
%   transects = jarkus_interpolatenans(transects)
%
%   See also jarkus_transects

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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 21 Jan 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

%% settings

OPT = struct( ...
    'prop', 'altitude', ...
    'interp', 'cross_shore', ...
    'dim', 3 ...
);

OPT = setProperty(OPT, varargin{:});

%% check

if ~jarkus_check(transects, {OPT.prop OPT.dim}, OPT.interp)
    error('Invalid jarkus transect structure');
end

%% interpolate

dims = size(transects.(OPT.prop));
dims(OPT.dim) = 1;

n = prod(dims);
for i = 1:n
    coords = num2cell(numel2coord(dims, i));
    coords{OPT.dim} = ':';
    
    property = squeeze(transects.(OPT.prop)(coords{:}));
    interpolate = squeeze(transects.(OPT.interp));
    
    notnan = ~isnan(property);
    
    if any(notnan)
        transects.(OPT.prop)(coords{:}) = interp1(interpolate(notnan), ...
            property(notnan), interpolate);
    end
end