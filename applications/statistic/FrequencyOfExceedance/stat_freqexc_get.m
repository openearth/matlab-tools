function res = stat_freqexc_get(t, x, varargin)
%STAT_FREQEXC_GET  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = stat_freqexc_get(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   stat_freqexc_get
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
% Created: 15 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read settings

OPT = struct( ...
    'dx', .01, ...
    'horizon', 15 ...
);

OPT = setproperty(OPT, varargin{:});

%% output structure

dt              = mean(diff(t));
duration        = range(t);

res = stat_freqexc_struct;

res.time        = t(:);
res.data        = x(:);
res.duration    = duration;
res.dt          = dt;
res.fraction    = sum(isfinite(x))/length(x);

years           = res.duration/365.2425;

%% find maxima

% create computational grid
mn = min(round(x(isfinite(x))/OPT.dx)*OPT.dx);
mx = max(round(x(isfinite(x))/OPT.dx)*OPT.dx);

g  = mn:OPT.dx:mx;
        
for i = 1:length(g)

    % initialize values
    res.peaks(i).threshold  = g(i);
    res.peaks(i).maxima     = struct('time', {}, 'value', {}, 'duration', {});

    % determine up- and down crossings
    uc = find((x(1:end-1)<=g(i)|isnan(x(1:end-1)))&x(2:end)>g(i));
    dc = find((x(2:end)<=g(i)|isnan(x(2:end)))&x(1:end-1)>g(i));
    
    startidx = 1;
    
    if isempty(uc) && isempty(dc)
        if x(1) >= g(i)
            uc = startidx;
            dc = length(x);
        end
    elseif isempty(uc)
        uc = startidx;
    elseif isempty(dc)
        dc = length(x);
    else
        if uc(1) > dc(1)
            uc = [startidx;uc(:)];
        end
        if uc(end) > dc(end)
            dc = [dc(:);length(x)];
        end
    end

    % determine wave maxima
    c = 1;
    for j = 1:length(uc)
        
        tj      = uc(j):dc(j);
        [m k]   = max(x(tj));
        idx     = find(abs(t(tj(k))-[res.peaks(i).maxima.time])<OPT.horizon,1);

        % add waves to result structure if distant enought from previous
        % peak, otherwise merge with previous peak
        if ~isempty(idx)
            
            if res.peaks(i).maxima(idx).value < m
                res.peaks(i).maxima(idx).time   = t(tj(k));
                res.peaks(i).maxima(idx).value  = m;
            end

            res.peaks(i).maxima(idx).duration   = res.peaks(i).maxima(idx).duration+(dc(j)-uc(j))*dt;
        else
            res.peaks(i).maxima(c).time         = t(tj(k));
            res.peaks(i).maxima(c).value        = m;
            res.peaks(i).maxima(c).duration     = (dc(j)-uc(j))*dt;

            c = c+1;
        end
    end
    
    res.peaks(i).nmax           = length(res.peaks(i).maxima);
    res.peaks(i).probability    = sum([res.peaks(i).maxima.duration])/duration/res.fraction;
    res.peaks(i).frequency      = [res.peaks(i).nmax]/years;
end
