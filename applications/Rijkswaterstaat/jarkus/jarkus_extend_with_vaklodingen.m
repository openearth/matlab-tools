function transect = jarkus_extend_with_vaklodingen(jarkus_id, jarkus_year, varargin)
%JARKUS_EXTEND_WITH_VAKLODINGEN  extend jarkus transect seaward using vaklodingen.
%
%   More detailed description goes here.
%
%   Syntax:
%   transect = jarkus_extend_with_vaklodingen(id, year)
%
%   Input:
%   jarkus_id       = identifier of jarkus transect
%   jarkus_year     = year of jarkus measurement
%   varargin        = propertyname-propertyvalue pairs:
%                   'jarkus_extend' - boolean to indicating whether the
%                   transect should first be extended as much as possible
%                   based on jarkus data of other years.
%                   'debug' - boolean giving the opportunity to plot some
%                   intermediate steps in order to check the process
%
%   Output:
%   transect = jarkus transect structure, with a few additional fields
%
%   Example
%   transects = jarkus_extend_with_vaklodingen(7001503, 2010)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Delft University of Technology
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
% Created: 02 Mar 2012
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT = struct(...
    'jarkus_extend', false,...
    'debug', false);
OPT = setproperty(OPT, varargin);

%%
if ~isscalar(jarkus_id) && ~isinteger(jarkus_id)
    error('"id" must be a scalar and integer')
end

if ~isscalar(jarkus_year) && ~isinteger(jarkus_year)
    error('"year" must be a scalar and integer')
end

%%
if ~OPT.jarkus_extend
    tr = jarkus_transects('id', jarkus_id, 'year', jarkus_year);
    tr = jarkus_interpolatenans(tr);
else
    % retreive transect for all available years
    tr = jarkus_transects('id', jarkus_id);
    % interpolate nans in cross-shore direction (default)
    tr = jarkus_interpolatenans(tr);
    % interpolate nans in time
    tr = jarkus_interpolatenans(tr,...
        'interp', 'time', ...
        'dim', 1);
    % extrapolate nans in time with nearest neighbour method
    tr = jarkus_interpolatenans(tr,...
        'interp', 'time', ...
        'dim', 1,...
        'method', 'nearest', ...
        'extrap', true);
    % delete data of other years
    skipid = year(tr.time + datenum(1970,1,1)) ~= jarkus_year;
    tr.time(skipid) = [];
    tr.altitude(skipid,:,:) = [];
end

nnid = ~isnan(squeeze(tr.altitude));

x = tr.x(nnid)';
dx = mean(diff(x));
y = tr.y(nnid)';
dy = mean(diff(y));
z = squeeze(tr.altitude(:,:,nnid));

% x and y direction when going offshore
x_direction = sign(dx);
y_direction = sign(dy);

px2y = polyfit(x,y,1);

%% retreive extent of vaklodingen
url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/vaklodingen/vaklodingen.nc';
ids = nc_varget(url, 'id');
rectangles = nc_varget(url, 'rectangle');
x_from = nc_varget(url, 'x_from');
x_to = nc_varget(url, 'x_to');
y_from = nc_varget(url, 'y_from');
y_to = nc_varget(url, 'y_to');

%% construct bounding boxes and find potential relevant ones
x_rect = [x_from x_from x_to x_to x_from];
y_rect = [y_from y_to y_to y_from y_from];
rect_preselect = any(sign(x_rect - x(1)) == x_direction, 2) & ...
	any(sign(y_rect - y(1)) == y_direction, 2);

%% plot pre-selected area
if OPT.debug
    figure;
    subplot(2,2,1);
    ldbncfile = 'http://opendap.tudelft.nl/thredds/dodsC/data2/deltares/deltares/landboundaries/holland.nc';
    plot(nc_varget(ldbncfile, 'x'), nc_varget(ldbncfile, 'y'))
    hold on
    for i = 1:length(ids)
        rectangle('position', rectangles(i,:), 'tag', strtrim(ids(i,:)), 'edgecolor', 'b');
    end
    for i = find(rect_preselect)'
        rectangle('position', rectangles(i,:), 'tag', strtrim(ids(i,:)), 'edgecolor', 'r');
    end
    plot(x([1 end]),y([1 end]), 'r-o')
end

%% locate most seaward point of extended transect
if x_direction == 0
    if y_direction < 0
        y_end = min(y_from(rect_preselect));
    else
        y_end = max(y_to(rect_preselect));
    end
    x_end = x(1);
else
    if x_direction < 0
        x_end = min(x_from(rect_preselect));
    else
        x_end = max(x_to(rect_preselect));
    end
    y_end = polyval(px2y, x_end);
end

%% select the map areas that the transects is actually crossing
rect_select = false(size(rect_preselect));
for i = find(rect_preselect)'
    xcr = findCrossingsOfLineAndPolygon([x(1) x_end], [y(1) y_end],...
        x_rect(i,:), y_rect(i,:));
    if ~isempty(xcr)
        rect_select(i) = true;
    end
end

%% plot selected area
if OPT.debug
    for sb = 1:2
        subplot(2,2,sb)
        for i = find(rect_select)'
            rectangle('position', rectangles(i,:),...
                'tag', strtrim(ids(i,:)),...
                'edgecolor', 'r',...
                'linewidth', 2);
        end
    end
    hold on
    plot(x([1 end]),y([1 end]), 'r-o')
end

%% retreive bathymetry data from vaklodingen
[xvl yvl zvl] = deal(repmat({}, size(ids)));
for i = find(rect_select)'
    ncfile = ['http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingen' ids(i,:) '.nc'];
    
    xvl{i} = nc_varget(ncfile, 'x');
    yvl{i} = nc_varget(ncfile, 'y');
    zta  = nc_varget(ncfile, 'z');
    % start with latest measurement
    zvl{i} = squeeze(zta(end,:,:));
    % fill NaN's with older measurements
    for t = size(zta,1):-1:1
        ii = isnan(zvl{i});
        zt = squeeze(zta(t,:,:));
        zvl{i}(ii) = zt(ii);
    end
end
[X Y Z] = xb_grid_merge('x', xvl(rect_select), 'y', yvl(rect_select), 'z', zvl(rect_select), 'maxsize', 'max');

%% plot bathymetry
if OPT.debug
    pc = pcolor(X,Y,Z);
    shading interp
    colorbar
    uistack(pc,'bottom')
    axis image
end

%% create common cross-shore grid and interpolate data
xe = x(1):dx:x_end;
ye = y(1):dy:y_end;
ze = interp2(X,Y,Z, xe, ye);
id0 = tr.cross_shore == 0;
ide0 = xe == tr.x(id0);
% calculate distance to RSP
cse = round(sqrt((xe - xe(ide0)).^2 + (ye - ye(ide0)).^2));
% change sign of first (landward) part of vector
cse(1:find(cse==0, 1, 'first')-1) = -cse(1:find(cse==0, 1, 'first')-1);
cs = tr.cross_shore(nnid);
cross_shore = unique([cse(:); cs(:)]');

%% plot cross-shore profile
if OPT.debug
    subplot(2,2,[3 4]);
    hold on
    
    plot(cross_shore, ze, tr.cross_shore(nnid), z)
    if x_direction < 0
        set(gca, 'xdir', 'reverse')
    end
end

%% combine data to structure
tr.x = xe;
tr.y = ye;
tr.altitude_jarkus = NaN(size(cross_shore));
tr.altitude_jarkus(ismember(cross_shore, cs)) = z;
tr.altitude_vakloding = NaN(size(cross_shore));
tr.altitude_vakloding(ismember(cross_shore, cse)) = ze; 
tr.altitude = tr.altitude_vakloding;
tr.altitude(ismember(cross_shore, cs)) = z;
tr.cross_shore = cross_shore;

transect = tr;