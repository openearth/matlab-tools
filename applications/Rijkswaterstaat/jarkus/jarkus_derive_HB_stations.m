function varargout = jarkus_derive_HB_stations(varargin)
%JARKUS_DERIVE_HB_STATIONS  Derive weight of hydraulic boundary condition stations
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = jarkus_derive_HB_stations(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_derive_HB_stations
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 29 Mar 2011
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT = struct(...
    'id', [],...
    'jarkus_url', jarkus_url,...
    'x_station', [],...
    'y_station', [],...
    'virtual', [],...
    'angle_range', 21 ...
    );

OPT = setproperty(OPT, varargin{:});

%% input check
if ~isempty(OPT.virtual)
    equaldims = sum(diff(cellfun(@length, {OPT.x_station OPT.y_station OPT.virtual}))) == 0;
    if ~equaldims
        error
    end
    if sum(OPT.virtual) > 1
        error('more than one virtual station is not supported')
    end
    virtual = true;
else
    OPT.virtual = true(size(OPT.x_station));
end

%%
tr = jarkus_transects(...
    'id', OPT.id,...
    'output', {'id' 'angle' 'rsp_x' 'rsp_y'});

xr = [min(OPT.x_station) max(OPT.y_station)]; % x range
[a b xcr ycr] = deal(nan(size(tr.rsp_x)));

for i = 1:length(tr.rsp_x)
    [a(i) b(i)] = xydegN2ab(tr.rsp_x(i), tr.rsp_y(i), tr.angle(i));
    try
        if ismember(tr.angle(i), [0 180])
            % north or south directed transect, no y = ax+b approach possible
            xcr(i) = tr.rsp_x(i);
            ycr(i) = interp1(OPT.x_station, OPT.y_station, xcr(i));
        else
            if any(isnan(polyval([a(i) b(i)], xr)))
                dbstopcurrent
            end
            [xcr(i) ycr(i)] = findCrossings(xr, polyval([a(i) b(i)], xr), OPT.x_station, OPT.y_station);
        end
    catch
        [xcr(i) ycr(i)] = deal(NaN);
    end
end

%% select only transects that face seaward
% derive angles of lines between stations
% positive clockwise 0 north
stationids = 1:length(OPT.x_station);
station_angle.station = xy2degN(OPT.x_station(1:end-1), OPT.y_station(1:end-1), OPT.x_station(2:end), OPT.y_station(2:end));
station1id = NaN(size(xcr));
station_angle.transect = NaN(size(xcr));
for i = 1:length(xcr)
    if ~isnan(xcr(i))
        try
            station1id(i) = find(xcr(i) - OPT.x_station > 0, 1, 'last');
            station_angle.transect(i) = station_angle.station(station1id(i));
        catch
            station1id(i) = NaN;
        end
    end
end
station2id = station1id + 1; % other station is the neighbouring one

angleid = ...
    tr.angle > 270-OPT.angle_range + station_angle.transect' & ...
    tr.angle < 270+OPT.angle_range + station_angle.transect' | ...
    tr.angle < -90+OPT.angle_range + station_angle.transect' & ...
    tr.angle < -90-OPT.angle_range + station_angle.transect';

%% derive lambda
station_distance.station = sqrt((OPT.x_station(1:end-1) - OPT.x_station(2:end)).^2 + ((OPT.y_station(1:end-1) - OPT.y_station(2:end)).^2));
station_distance.transect = NaN(size(xcr));
lambda = NaN(size(xcr));
distance1 = NaN(size(xcr));
for i = 1:length(xcr)
    station_distance.transect(i) = station_distance.station(station1id(i));
    distance1(i) = sqrt((OPT.x_station(station1id(i)) - xcr(i))^2 + (OPT.y_station(station1id(i)) - ycr(i))^2);
    lambda(i) = 1 - distance1(i) / station_distance.transect(i);
end

if virtual
    lambda_virtual1 = 1 - station_distance.station(OPT.virtual(2:end)) / (station_distance.station(OPT.virtual(1:end)) + station_distance.station(OPT.virtual(2:end)));
    % correct lambda for transects where the first station is virtual
    for i = find(station1id == stationids(OPT.virtual))
        rangelambda = [lambda_virtual1 0];
        station1id(i) = station1id(i) - 1;
        lambda(i) = interp1([0 station_distance.station(OPT.virtual(1:end))], rangelambda, distance1(i));
    end
    % correct lambda for transects where the second station is virtual
    for i = find(station2id == stationids(OPT.virtual))
        rangelambda = [1 lambda_virtual1];
        station2id(i) = station2id(i) + 1;
        lambda(i) = interp1([0 station_distance.station(OPT.virtual(2:end))], rangelambda, distance1(i));
    end
end

varargout = {lambda};