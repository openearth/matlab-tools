function BSS = BrierSkillScore(xc, zc, xm, zm, x0, z0, varargin)
%BRIERSKILLSCORE  One line description goes here.
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
%   varargin  = leave empty for a weighted score based on the combined
%   xgrid, otherwise either the number of grid cells <nx> or a PropertyName
%   PropertyValue pair 'equidistant', <nx>. 
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
    'equidistant', []);

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
if ~isempty(OPT.equidistant)
    newxlow = max([min(x0) min(xc) min(xm)]);
    newxhigh = min([max(x0) max(xc) max(xm)]);
    xextends = newxhigh - newxlow;

    nx = OPT.equidistant;
    x_new = newxlow:xextends/nx:newxhigh;
else
    x_new = unique([x0' xc' xm']);
end

%% interpolate profiles onto new grid
z0_new = interp1(x0, z0, x_new);
zc_new = interp1(xc, zc, x_new);
zm_new = interp1(xm, zm, x_new);

%% calculate BSS
if isempty(OPT.equidistant)
    % weight is defined as half of diff left and half of diff right of each
    % point; first and last point are considered to have only one side.
    weight = diff([x_new(1) diff(x_new)/2 + x_new(1:end-1) x_new(end)]);
else
    % weight is equaly devided over all points.
    weight = ones(size(x_new));
end
total = sum(weight);
    
mse_p = sum(((zm_new - zc_new).^2).*weight)/total;
mse_0 = sum(((zm_new - z0_new).^2).*weight)/total;
BSS = 1. - (mse_p/mse_0);