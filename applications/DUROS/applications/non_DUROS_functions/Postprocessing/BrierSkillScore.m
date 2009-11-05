function BSS = BrierSkillScore(xc, zc, xm, zm, x0, z0, varargin)
%BRIERSKILLSCORE  Brier Skill Score of cross-shore profile
%
%   Derive Brier Skill Score (Sutherland et al, 2004). 
%
%   Syntax:
%   BSS = BrierSkillScore(xc, zc, xm, zm, x0, z0, nx)
%
%   Input:
%   xc  = calculated x grid
%   zc  = calculated z values
%   xm  = measured x grid
%   zm  = measured z values
%   x0  = initial x grid
%   z0  = initial z values
%   varargin  = PropertyName-PropertyValue pairs
%       'equidistant' : - false for a weighted score based on the combined
%                           xgrid
%                       - <nx> for the number of equidistant gridcells
%       'lower_threshold' : - [] empty for no threshold
%                           - <lower_threshold> any value to ceil all lower
%                             values to
%
%   Output:
%   BSS =
%
%   Example
%   BrierSkillScore
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer / C.(Kees) den Heijer
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 30 Jun 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT = struct(...
    'equidistant', false,... % either false or # gridcells
    'lower_threshold', []);

if ~isempty(varargin) && ischar(varargin{1})
    OPT = setProperty(OPT, varargin{:});
elseif ~isempty(varargin)
    % backward compatible (varargin{1} = nx)
    OPT = setProperty(OPT, 'equidistant', varargin{1});
end

%% clear all nan values in input (to avoid problems with interpolation)
x0(isnan(z0)) = [];
z0(isnan(z0)) = [];
xc(isnan(zc)) = [];
zc(isnan(zc)) = [];
xm(isnan(zm)) = [];
zm(isnan(zm)) = [];

%% determine new grid covered by all profiles
if OPT.equidistant
    newxlow = max([min(x0) min(xc) min(xm)]);
    newxhigh = min([max(x0) max(xc) max(xm)]);
    xextends = newxhigh - newxlow;

    nx = OPT.equidistant;
    x_new = newxlow:xextends/nx:newxhigh;
else
    x_new = unique([x0' xc' xm']);
end

%% interpolate profiles onto new grid
[x0,id1] = unique(x0);
[xc,id2] = unique(xc);
[xm,id3] = unique(xm);
z0 = z0(id1);
zc = zc(id2);
zm = zm(id3);

z0_new = interp1(x0, z0, x_new);
zc_new = interp1(xc, zc, x_new);
zm_new = interp1(xm, zm, x_new);

%% calculate BSS
if OPT.equidistant
    % weight is equaly devided over all points.
    weight = ones(size(x_new));
else
    % weight is defined as half of diff left and half of diff right of each
    % point; first and last point are considered to have only one side.
    weight = diff([x_new(1) diff(x_new)/2 + x_new(1:end-1) x_new(end)]);
end
total = sum(weight);
    
mse_p = sum(((zm_new - zc_new).^2).*weight)/total;
mse_0 = sum(((zm_new - z0_new).^2).*weight)/total;
BSS = 1. - (mse_p/mse_0);

%% apply lower threshold
below_threshold = BSS < OPT.lower_hreshold;
if any(below_threshold)
    disp(['Replaced Brier Skill Score <' num2str(OPT.lower_hreshold) ' with a skill score of ' num2str(OPT.lower_hreshold)]);
    BSS(below_threshold) = OPT.lower_threshold;
end