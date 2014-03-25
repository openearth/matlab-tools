function [xProfile, zProfile, xInitial, zInitial] = DuneProfileVariation(varargin)
%DUNEPROFILEVARIATION  Creates a gaussian shaped profile variation of a
%jarkus profile, given a certai volume and vertical intersection level
%(w.r.t. N.A.P.)
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = DuneProfileVariation(varargin)
%
%   Input: For <keyword,value> pairs call DuneProfileVariation() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   DuneProfileVariation
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
% Created: 10 Mar 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings
OPT = struct(...
    'VariationVolume',              0,      ...
    'VerticalIntersectionLevel',    0,      ...
    'JarkusID',                     [],     ...
    'JarkusYear',                   [],     ...
    'xInitial',                     [],     ...
    'zInitial',                     []      ...
    );

OPT = setproperty(OPT, varargin{:});

%% Check type of input and get initial profile

if ~isempty(OPT.JarkusID) && ~isempty(OPT.JarkusYear)
    transects   = jarkus_transects('id', OPT.JarkusID, 'year', OPT.JarkusYear);
    
    % Filter transect for NaNs
    xInitial    = transects.cross_shore(:,~isnan(transects.altitude));
    zInitial    = squeeze(transects.altitude(:,:,~isnan(transects.altitude)))';
elseif ~isempty(OPT.xInitial) && ~isempty(OPT.zInitial)
    xInitial    = OPT.xInitial;
    zInitial    = OPT.zInitial;
else
    error('Neither a valid Jarkus ID/Year input or x/z input os given!')
end

if isempty(xInitial) || isempty(zInitial)
    error('No initial profile available!')
end

%% Generate profile variation and final profile

xProfile        = xInitial;

if OPT.VariationVolume ~= 0 || OPT.VerticalIntersectionLevel > max(zInitial)
    % only calculate the profile variation if the volume is not null
    xIntersection   = max(findCrossings(xInitial, zInitial, [min(xInitial) max(xInitial)], ...
        [OPT.VerticalIntersectionLevel OPT.VerticalIntersectionLevel])); 
    SigmaVariation  = 4*sqrt(abs(OPT.VariationVolume));
    dzVariation     = OPT.VariationVolume*norm_pdf(xInitial, xIntersection, SigmaVariation);

    zProfile        = zInitial + dzVariation;
else
    % reuse the initial profile
    zProfile        = zInitial;
end