function ph = jarkus_plot_locations_on_map(varargin)
%JARKUS_PLOT_LOCATIONS_ON_MAP  shows locations of selected jarkus transects on map
%
%   More detailed description goes here.
%
%   Syntax:
%   ph = jarkus_plot_locations_on_map(varargin)
%
%   Input:
%   varargin  = either propertyname-propertyvalue pairs as expected by
%               jarkus_transects or a structure obtained from jarkus_transects
%
%   Output:
%   ph = plot handles
%
%   Example
%   jarkus_plot_locations_on_map
%
%   See also jarkus_transects

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 13 Sep 2011
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% defaults and input check
% check number of input arguments
error(nargchk(1, Inf, nargin))

OPT = struct(...
    'projection', 'lonlat');

if isscalar(varargin) && isstruct(varargin{1})
    % structure input argument is assumed to be created by jarkus_transects
    tr = varargin{1};
else
    % transect structure is obtained by jarkus_transects
    try
        tr = jarkus_transects(varargin{:}, 'output', {'id' 'rsp_x' 'rsp_y'});
    catch E
        if strcmp(E.identifier, 'MATLAB:Java:GenericException')
            error('Memory problems occured, confine your selection by specifying "id" and "year".')
        end
    end
end

% url of map
url = 'http://opendap.tudelft.nl/thredds/dodsC/data2/deltares/deltares/landboundaries/holland.nc';

%% obtain data
xid = 1:length(OPT.projection)/2;
yid = max(xid)+1:length(OPT.projection);
x = nc_varget(url, OPT.projection(xid));
y = nc_varget(url, OPT.projection(yid));

xytr = [mat2cell(tr.(['rsp_' OPT.projection(xid)]), 1, ones(1,13));
    mat2cell(tr.(['rsp_' OPT.projection(yid)]), 1, ones(1,13))];

%% plot
ph = plot(x, y, xytr{:});

%% set displaynames
lh = findobj(ph, 'XData', x, 'YData', y);
set(lh, 'DisplayName', 'Coastline')
th = ph(ph~=lh);
set(th, 'marker', 'o',...
    'linestyle', 'none');
for ith = 1:length(th)
    xt = get(th(ith), 'XData');
    yt = get(th(ith), 'YData');
    id = tr.id(xt == tr.(['rsp_' OPT.projection(xid)]) &...
        yt == tr.(['rsp_' OPT.projection(yid)]));
    set(th(ith), 'DisplayName', sprintf('%i', id))
end

%% set x and y labels
if strcmp(OPT.projection(xid), 'lon')
    xlabel('Longitude [degrees east]')
elseif strcmp(OPT.projection(xid), 'x')
    xlabel('x coordinate [m]')
end

if strcmp(OPT.projection(yid), 'lat')
    ylabel('Latitude [degrees north]')
elseif strcmp(OPT.projection(yid), 'y')
    ylabel('y coordinate [m]')
end