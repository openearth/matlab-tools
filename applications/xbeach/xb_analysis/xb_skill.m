function [r2 sci relbias bss] = xb_skill(measured, computed, varargin)
%XB_SKILL  Computes a variety skill scores
%
%   Computes a variety skill scores: R^2, Sci, Relative bias, Brier Skill
%   Score. Special feature: within the XBeach testbed, the results are
%   stored to be able to show the development of the different skill scores
%   in time.
%
%   Syntax:
%   [r2 sci relbias bss] = xb_skill(measured, computed, varargin)
%
%   Input:
%   measured  = Measured data where the first column contains independent
%               values and the second column contains dependent values
%   computed  = Computed data where the first column contains independent
%               values and the second column contains dependent values
%   varargin  = var:    Name of the variable that is supplied
%
%   Output:
%   r2        = R^2 skill score
%   sci       = Sci skill score
%   relbias   = Relative bias
%   bss       = Brier Skill Score
%
%   Example
%   [r2 sci relbias bss] = xb_skill(measured, computed)
%   [r2 sci relbias bss] = xb_skill(measured, computed, 'var', 'zb')
%
%   See also xb_plot_skill

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 13 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'var',      '' ...
);

OPT = setproperty(OPT, varargin{:});

%% compute skills

x       = unique([computed(:,1) ; measured(:,1)]);

zmt     = interp1(measured(:,1), measured(:,2), x);
zct     = interp1(computed(:,1), computed(:,2), x);

zc      = zct(~isnan(zct)&abs(zmt)>.05*max(abs(zmt)));
zm      = zmt(~isnan(zct)&abs(zmt)>.05*max(abs(zmt)));

r2      = mean((zc-mean(zc)).*(zm-mean(zm)))/(std(zm)*std(zc));

rms     = sqrt(mean((zc-zm).^2));
rmsm    = sqrt(mean(zm.^2));
sci     = rms/max(rmsm,abs(mean(zm)));

relbias = mean(zc-zm)/max(rmsm,abs(mean(zm)));

bss     = 1-(std(zc-zm))^2/var(zm);

%% store skills

if ~isempty(OPT.var)
    xb_testbed_storeskill(OPT.var, r2, sci, relbias, bss);
end

