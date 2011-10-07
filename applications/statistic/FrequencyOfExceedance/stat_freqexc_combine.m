function res = stat_freqexc_combine(res, varargin)
%STAT_FREQEXC_COMBINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = stat_freqexc_combine(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   stat_freqexc_combine
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
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
% Created: 07 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read settings

OPT = struct( ...
    'f',        [1e1 1e0 1e-1 1e-2 1e-3 1e-4 1e-5], ...
    'split',    .1                                  ...
);

OPT = setproperty(OPT, varargin{:});

if ~isfield(res, 'filter')
    error('No data selected, please use stat_freqexc_filter first');
end

if ~isfield(res, 'fit')
    error('No fit made, pleas use stat_freqexc_fit first');
end

%% combine data and fit

yf  = sort([res.filter.maxima.value],2,'descend');
yc1 = interp1([1:res.filter.nmax]./res.filter.nmax,yf,OPT.f(OPT.f>=OPT.split),'linear','extrap');

[f fi] = unique(res.fit.f);
yc2 = interp1(f,res.fit.y(fi),OPT.f(OPT.f<OPT.split),'linear','extrap');

res.combined.f = OPT.f;
res.combined.y = [yc1 yc2];

