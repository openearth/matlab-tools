function res = stat_freqexc_consolidate(res, varargin)
%STAT_FREQEXC_CONSOLIDATE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = stat_freqexc_consolidate(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   stat_freqexc_consolidate
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
% Created: 06 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read settings

OPT = struct( ...
    'mask',         'yyyy', ...
    'threshold',    -Inf    ...
);

OPT = setproperty(OPT, varargin{:});

%% determine year maxima

[n ni] = max(cellfun(@length,{res.peaks.maxima}));

y      = num2cell(datestr([res.peaks(ni).maxima.time],OPT.mask),2);
years  = unique(y);
mis    = [];

for i = 1:length(years)
    idx    = ismember(y,years(i));
    [m mi] = max([res.peaks(ni).maxima(idx).value]);
    
    if m >= OPT.threshold
        mis = [mis mi];
    end
end

%% consolidate peaks

res.peaks        = res.peaks(ni);
res.peaks.nmax   = length(mis);
res.peaks.maxima = res.peaks.maxima(mis);
