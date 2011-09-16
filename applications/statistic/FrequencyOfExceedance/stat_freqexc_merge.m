function res = stat_freqexc_merge(varargin)
%STAT_FREQEXC_MERGE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = stat_freqexc_merge(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   stat_freqexc_merge
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

%% merge freqexc structs

res = stat_freqexc_struct;

c = 1;
for i = 1:length(varargin)
    s = varargin{i};
    
    res.time        = [res.time;nan;s.time];
    res.data        = [res.data;nan;s.data];
    res.dt          = (res.dt*res.duration+s.dt*s.duration)/(res.duration+s.duration);
    res.duration    = res.duration+s.duration;
    
    for j = 1:length(s.peaks)
        idx = ismember([res.peaks.threshold], s.peaks(j).threshold);
        
        if isempty(idx) || ~any(idx)
            res.peaks(c) = s.peaks(j);
            c = c+1;
        else
            res.peaks(idx).nmax = res.peaks(idx).nmax + s.peaks(j).nmax;
            res.peaks(idx).maxima = [res.peaks(idx).maxima s.peaks(j).maxima];
        end
    end
end

for i = 1:length(res.peaks)
    res.peaks(i).frequency = sum([res.peaks(i).maxima.duration])/res.duration;
end

res.peaks = res.peaks(isort([res.peaks.threshold]));