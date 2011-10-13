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
    'y',      -10:.1:10, ...
    'fcnfit', {{@stat_fit_rayleigh @stat_fit_gumbel @stat_fit_normal @stat_fit_gamma}} ...
);

OPT = setproperty(OPT, varargin{:});

if ~isfield(res, 'filter')
    error('No data selected, please use stat_freqexc_filter first');
end

%% fit data

res.fit = struct();

data    = [res.filter.maxima.value];

n = 1;
for i = 1:length(OPT.fcnfit)
    if isa(OPT.fcnfit{i}, 'function_handle')
        try
            res.fit.fits(n) = struct(   ...
                'fcn',  OPT.fcnfit{i},  ...
                'y',    OPT.y(:),          ...
                'f',    1-feval(OPT.fcnfit{i},data,OPT.y(:)));

            n = n+1;
        catch
            e = lasterror;
            disp(e.message);
        end
    end
end

%% compute average

f = [res.fit.fits.f];
f = f(:,~all(isnan(f),1));

res.fit.y = OPT.y(:);
res.fit.f = mean(f,2);
