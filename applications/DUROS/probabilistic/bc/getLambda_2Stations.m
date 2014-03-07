function [lambda1, lambda2, station1, station2] = getLambda_2Stations(varargin)
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
    'JarkusXRD',    [],         ...
    'JarkusYRD',    [],         ... 
    'JarkusAngle',  [],         ...
    'JarkusURL',    jarkus_url  ...
    );

OPT = setproperty(OPT, varargin{:});

%% Determine Jarkus location

if ~isempty(OPT.JarkusId)
    
elseif ~isempty(OPT.JarkusYRD) && ~isempty(OPT.JarkusYRD) && ~isempty(OPT.JarkusAngle)
else
    error('You need to specify either a Jarkus ID or a location (in RD coordinates) with an angle!')
end

%% Determine the two stations

%% Calculate Lambda