function res = stat_freqexc_fit(res, varargin)
%STAT_FREQEXC_FIT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = stat_freqexc_fit(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   stat_freqexc_fit
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
    'f',      1./[1 1.001 1.1 2 5 10 25 30 50 100 200 500 1000 5000 10000 50000 100000], ...
    'fcnfit', {@stat_fit_rayleigh @stat_fit_gumbel @stat_fit_normal @stat_fit_max} ...
);

OPT = setproperty(OPT, varargin{:});

%% fit data

res.fit = struct();

data    = [res.peaks.maxima.value];

for i = 1:length(OPT.fcnfit)
    if ishandle(OPT.fcnfit{i})
        feval(OPT.fcnfit{i},data,OPT.f);
    end
end


