function [Lambda1, Lambda2] = getLambda_2Stations(varargin)
%GETLAMBDA_2STATIONS  Calculate lambda for profiles that are in between 2
%stations
%
%   Lambda is the relative distance to station 1 from the intersection of
%   the normal of the Jarkus profile and the line connecting the 2 stations
%
%   Syntax:
%   varargout = getLambda_2Stations(varargin)
%
%   Input: For <keyword,value> pairs call getLambda_2Stations() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getLambda_2Stations
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 07 Mar 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings

OPT = struct(...
    'Station1',     '',         ...
    'Station2',     '',         ...
    'JarkusId',     [],         ...
    'Distance',     40000,      ...
    'RSPX',         [],         ...
    'RSPY',         [],         ... 
    'Angle',        [],         ...
    'JarkusURL',    jarkus_url  ...
    );

OPT = setproperty(OPT, varargin{:});

%% Determine Jarkus location

if ~isempty(OPT.JarkusId)
    % Get Jarkus info from NetCDF file
    IDs         = nc_varget(OPT.JarkusURL,'id');
    iLocation   = find(IDs == OPT.JarkusId)-1; % Target file is 0 based, where Matlab is 1 based
    RSPX        = nc_varget(OPT.JarkusURL,'rsp_x',iLocation,1);
    RSPY        = nc_varget(OPT.JarkusURL,'rsp_y',iLocation,1);
    Angle       = nc_varget(OPT.JarkusURL,'angle',iLocation,1);
    ExtendedX   = RSPX + OPT.Distance*cosd(90-Angle);
    ExtendedY   = RSPY + OPT.Distance*sind(90-Angle);
elseif ~isempty(OPT.RSPX) && ~isempty(OPT.RSPY) && ~isempty(OPT.Angle)
    % Use given Jarkus info
    RSPX        = OPT.RSPX;
    RSPY        = OPT.RSPY;
    ExtendedX   = RSPX + OPT.Distance*cosd(90-OPT.Angle);
    ExtendedY   = RSPY + OPT.Distance*sind(90-OPT.Angle);
else
    error('You need to specify either a Jarkus ID or a location (in RD coordinates) with an angle!')
end

%% Determine the two stations

% Station information obtained from "Resultaten analyse HR2006 duinen" HKV
% & WL|Delft Hydraulics, 2006
StationInfo = {
    'Hoek van Holland',     58748,  450830;
    'IJmuiden',             79249,  501800;
    'Den Helder',           99703,  552650;
    'Eierlandse Gat',       106514, 587985;
    'Steunpunt Waddenzee',  150000, 621230;
    'Borkum',               221990, 621330
    };

Station1X   = []; 
Station1Y   = [];
Station2X   = []; 
Station2Y   = [];

for iStation = 1:size(StationInfo,1)
    if strcmpi(StationInfo{iStation,1}, OPT.Station1)
        Station1X   = StationInfo{iStation,2}; 
        Station1Y   = StationInfo{iStation,3};
    elseif strcmpi(StationInfo{iStation,1}, OPT.Station2)
        Station2X   = StationInfo{iStation,2}; 
        Station2Y   = StationInfo{iStation,3};
    end
end

if isempty(Station1X) || isempty(Station1Y) || isempty(Station2X) || isempty(Station2Y)
    error('Please specify valid station names!')
end

%% Calculate Lambda

% Interpolate both to the same grid
XDummy      = linspace(RSPX, ExtendedX, 1000);
JarkusLine  = interp1([RSPX ExtendedX], [RSPY ExtendedY], XDummy);
StationLine = interp1([Station1X Station2X], [Station1Y Station2Y], XDummy);

% Find intersection
[XIntersection, YIntersection]  = intersection(XDummy, JarkusLine, StationLine);

% Calculate both Lambdas
Lambda1     = distance([Station1X XIntersection],[Station1Y YIntersection])/distance([Station1X Station2X],[Station1Y Station2Y]);
Lambda2     = distance([Station2X XIntersection],[Station2Y YIntersection])/distance([Station1X Station2X],[Station1Y Station2Y]);