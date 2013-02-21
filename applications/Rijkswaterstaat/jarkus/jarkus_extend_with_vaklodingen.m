function [trvk, tr] = jarkus_extend_with_vaklodingen(jarkus_id, jarkus_year, varargin)
%JARKUS_EXTEND_WITH_VAKLODINGEN  extend jarkus transect seaward using vaklodingen.
%
%   More detailed description goes here.
%
%   Syntax:
%   [trvk, tr] = jarkus_extend_with_vaklodingen(id, year)
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
%   trvk = jarkus transect structure, with data as interpolated from
%           vaklodingen
%   tr   = jarkus transect structure, with 'real' jarkus data
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
    skipid = ~ismember(year(tr.time + datenum(1970,1,1)), jarkus_year);
    tr.time(skipid) = [];
    tr.altitude(skipid,:,:) = [];
end

nnid = sum(~isnan(squeeze(tr.altitude))) ~= 0;

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
urls = opendap_catalog('http://opendap.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.html',...
    'ignoreCatalogNc', false);

catalogidx = ~cellfun(@isempty, regexp(urls, 'catalog.nc$', 'match'));

[projectionCoverage_x, projectionCoverage_y] = deal([]);

if any(catalogidx)
    urlPath = cellstr(nc_varget(urls{catalogidx}, 'urlPath'));
    if isequal(numel(unique(urlPath)), sum(~catalogidx))
        % only possible if matlab/opendap bug that causes the urlPath
        % to be cropped at 64 characters does not occur
        projectionCoverage_x = nc_varget(urls{catalogidx}, 'projectionCoverage_x');
        projectionCoverage_y = nc_varget(urls{catalogidx}, 'projectionCoverage_y');
        projectionCoverage_x = projectionCoverage_x + ones(size(projectionCoverage_x))*[-10 0;0 10];
        projectionCoverage_y = projectionCoverage_y + ones(size(projectionCoverage_y))*[-10 0;0 10];
        
        ids = cellfun(@(s) s{1}, regexp(urlPath, '\d{3}_\d{4}', 'match'),...
            'uniformoutput', false);
    end
end

if ~any(catalogidx) || isempty(projectionCoverage_x)
    D = cellfun(@vaklodingen_definition, urls(~catalogidx));
    ids = {D.name};
    bboxs = [D.BoundingBox];
    projectionCoverage_x = bboxs(:,1:2:end)';
    projectionCoverage_y = bboxs(:,2:2:end)';
end

x_from = projectionCoverage_x(:,1);
x_to = projectionCoverage_x(:,2);
y_from = projectionCoverage_y(:,1);
y_to = projectionCoverage_y(:,2);

rectangles = [x_from y_from ones(size(x_to))*10000  ones(size(y_to))*12500];

% url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/vaklodingen/vaklodingen.nc';
% ids = nc_varget(url, 'id');
% rectangles = nc_varget(url, 'rectangle');
% x_from = nc_varget(url, 'x_from');
% x_to = nc_varget(url, 'x_to');
% y_from = nc_varget(url, 'y_from');
% y_to = nc_varget(url, 'y_to');

%% construct bounding boxes and find potential relevant ones
x_rect = [x_from x_from x_to x_to x_from];
y_rect = [y_from y_to y_to y_from y_from];
rect_preselect = any(sign(x_rect - x(1)) == x_direction, 2) & ...
	any(sign(y_rect - y(1)) == y_direction, 2) | ...
    any(sign(x_rect - x(end)) == -x_direction, 2) & ...
	any(sign(y_rect - y(end)) == -y_direction, 2);

%% plot pre-selected area
if OPT.debug
    figure;
    subplot(2,2,1);
    ldbncfile = 'http://opendap.tudelft.nl/thredds/dodsC/data2/deltares/deltares/landboundaries/holland.nc';
    plot(nc_varget(ldbncfile, 'x'), nc_varget(ldbncfile, 'y'))
    hold on
    for ii = 1:length(ids)
        rectangle('position', rectangles(ii,:), 'tag', ids{ii}, 'edgecolor', 'b');
    end
    for ii = find(rect_preselect)'
        rectangle('position', rectangles(ii,:),'tag', ids{ii}, 'edgecolor', 'r');
    end
    plot(x([1 end]),y([1 end]), 'r-o')
end

%% locate most landward and seaward points of extended transect
if x_direction == 0
    if y_direction < 0
        y_0 = max(y_to(rect_preselect));
        y_end = min(y_from(rect_preselect));
    else
        y_0 = min(y_from(rect_preselect));
        y_end = max(y_to(rect_preselect));
    end
    [x_0, x_end] = deal(x(1));
else
    if x_direction < 0
        x_0 = max(x_to(rect_preselect));
        x_end = min(x_from(rect_preselect));
    else
        x_0 = min(x_from(rect_preselect));
        x_end = max(x_to(rect_preselect));
    end
    y_0 = polyval(px2y, x_0);
    y_end = polyval(px2y, x_end);
end

%% select the map areas that the transects is actually crossing
[xcr(rect_preselect), ycr(rect_preselect)] = cellfun(@(xx,yy) findCrossingsOfLineAndPolygon([x(1) x_end], [y(1) y_end], xx, yy),...
    num2cell(x_rect(rect_preselect,:), 2), num2cell(y_rect(rect_preselect,:), 2),...
    'uniformoutput', false);

rect_select = false(size(rect_preselect));
rect_select(~cellfun(@isempty, xcr)) = true;

%% plot selected area
if OPT.debug
    for sb = 1:2
        subplot(2,2,sb)
        for i = find(rect_select)'
            rectangle('position', rectangles(i,:),...
                'tag', strtrim(ids{i}),...
                'edgecolor', 'r',...
                'linewidth', 2);
        end
    end
    hold on
    plot(x([1 end]),y([1 end]), 'r-o')
end

%% retreive bathymetry data from vaklodingen
% relevant ncfiles
ncfiles = cellfun(@(id) ['http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingen' id '.nc'], ids(rect_select),...
    'UniformOutput', false);
% unique years
Ts = cellfun(@(ncfile) nc_varget(ncfile, 'time'), ncfiles,...
    'uniformoutput', false);
years = cellfun(@(T) year(T + datenum(1970,1,1)), Ts,...
    'uniformoutput', false);
uniqueyears = unique(cell2mat(years'));
uniqueyears = uniqueyears(ismember(uniqueyears, jarkus_year));

[xvl, yvl] = cellfun(@(ncfile) deal(nc_varget(ncfile, 'x'), nc_varget(ncfile, 'y')), ncfiles,...
    'uniformoutput', false);
xe = [fliplr(x(1):-dx:x_0) x(2):dx:x_end];
ye = [fliplr(y(1):-dy:y_0) y(2):dy:y_end];
ze = nan(length(uniqueyears), length(xe));
for iyear = 1:length(uniqueyears)
    % pre-allocate z
    zvl = cellfun(@(X,Y) NaN(length(Y), length(X)), xvl, yvl,...
        'uniformoutput', false);
    for ii = 1:length(ncfiles)
        tidx = find(ismember(years{ii}, uniqueyears(iyear)));
        if ~isempty(tidx)
            ncfile = ncfiles{ii};
            if length(tidx) < 3
                stt = tidx(1)-1; % start t
                ctt = length(tidx); % count t
                sdt = 1; % stride t
                if length(tidx) == 2
                    sdt = diff(tidx); % stride t
                end
                ztmp  = nc_varget(ncfile, 'z', [stt 0 0], [ctt -1 -1], [sdt 1 1]);
            else
                ztmp = cell(0);
                for it = 1:length(tidx)
                    stt = tidx(it)-1;
                    ztmp{it} = nc_varget(ncfile, 'z', [stt 0 0], [1 -1 -1]);
                end
                ztmp = permute(cat(3, ztmp{:}), [3 1 2]);
            end
            if ndims(ztmp) == 3
                % index to pick only one z-value for each point, giving
                % preference to higher slices (earlier in time) an filling
                % up with missings at the lowest slice (independent from
                % this slice containing nans)
                idx = diff(cat(1,...
                    zeros(1,size(ztmp,2), size(ztmp,3)),...
                    ~isnan(ztmp(1:end-1,:,:)),...
                    ones(1,size(ztmp,2), size(ztmp,3))),...
                    1,1) == 1;
                zvl{ii} = ztmp(idx);
            else
                zvl{ii} = ztmp;
            end
        end
    end
    % merge grids
    [X, Y, Z] = xb_grid_merge('x', xvl, 'y', yvl, 'z', zvl, 'maxsize', 'max');
    ze(iyear,:) = interp2(X, Y, Z, xe, ye);
    
end

tmask = cellfun(@all, cellfun(@isnan, num2cell(ze,2), 'uniformoutput', false));
csmask = true(1,size(ze,2));
csmask(find(sum(~isnan(ze) > 0), 1, 'first'):find(sum(~isnan(ze) > 0), 1, 'last')) = false;

altitude = permute(ze(~tmask,~csmask), [1 3 2]);

% altitude = nan(sum(~tmask), 1, sum(~csmask));
% tidx = find(~tmask);
% for it = 1:sum(~tmask)
%     altitude(it,1,:) = ze(tidx(it),~csmask);
% end

xe = xe(~csmask);
ye = ye(~csmask);

id0 = tr.cross_shore == 0;
ide0 = xe == tr.x(id0);
% calculate distance to RSP
cse = round(sqrt((xe - xe(ide0)).^2 + (ye - ye(ide0)).^2));
cse(diff(cse)<0) = -cse(diff(cse)<0);

trvk = struct(...
    'id', tr.id,...
    'time', datenum(uniqueyears(~tmask),7,1) - datenum(1970,1,1),...
    'x', xe,...
    'y', ye,...
    'cross_shore', cse,...
    'altitude', altitude);
    
    
% for i = find(rect_select)'
%     ncfile = ['http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingen' ids{i} '.nc'];
%     
%     info = nc_info(ncfile);
%     
%     xvl{i} = nc_varget(ncfile, 'x');
%     yvl{i} = nc_varget(ncfile, 'y');
%     % derive length of time dimension
%     nt = info.Dimension(strcmp({info.Dimension.Name}, 'time')).Length;
%     % initially load latest measurement
%     zvl{i}  = nc_varget(ncfile, 'z', [nt-1 0 0], [1 -1 -1]);
%     % fill NaN's with older measurements
%     for t = fliplr(1:nt)
%         ii = isnan(zvl{i});
%         zt = nc_varget(ncfile, 'z', [t-1 0 0], [1 -1 -1]);
%         zvl{i}(ii) = zt(ii);
%     end
% end
% [X Y Z] = xb_grid_merge('x', xvl(rect_select), 'y', yvl(rect_select), 'z', zvl(rect_select), 'maxsize', 'max');
% 
% %% plot bathymetry
% if OPT.debug
%     pc = pcolor(X,Y,Z);
%     shading interp
%     colorbar
%     uistack(pc,'bottom')
%     axis image
% end
% 
% %% create common cross-shore grid and interpolate data
% xe = x(1):dx:x_end;
% ye = y(1):dy:y_end;
% ze = interp2(X,Y,Z, xe, ye);
% id0 = tr.cross_shore == 0;
% ide0 = xe == tr.x(id0);
% nnide = find(diff(~isnan([NaN ze NaN]))==1):find(diff(~isnan([NaN ze NaN]))==-1, 1, 'last')-1;
% [xe, ye, ze] = deal(xe(nnide), ye(nnide), ze(nnide));
% % calculate distance to RSP
% cse = round(sqrt((xe - xe(ide0)).^2 + (ye - ye(ide0)).^2));
% % change sign of first (landward) part of vector
% cse(1:find(cse==0, 1, 'first')-1) = -cse(1:find(cse==0, 1, 'first')-1);
% cs = tr.cross_shore(nnid);
% cross_shore = unique([cse(:); cs(:)]');
% 
% %% plot cross-shore profile
% if OPT.debug
%     subplot(2,2,[3 4]);
%     hold on
%     
%     plot(cross_shore(ismember(cross_shore, cse)), ze, tr.cross_shore(nnid), z)
%     if x_direction < 0
%         set(gca, 'xdir', 'reverse')
%     end
% end
% 
% %% combine data to structure
% tr.x = xe;
% tr.y = ye;
% tr.altitude_jarkus = NaN(size(cross_shore));
% tr.altitude_jarkus(ismember(cross_shore, cs)) = z;
% tr.altitude_vakloding = NaN(size(cross_shore));
% tr.altitude_vakloding(ismember(cross_shore, cse)) = ze; 
% tr.altitude = tr.altitude_vakloding;
% tr.altitude(ismember(cross_shore, cs)) = z;
% tr.cross_shore = cross_shore;
% 
% transect = tr;