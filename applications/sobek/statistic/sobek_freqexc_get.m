function res = sobek_freqexc_get(his, varargin)
%SOBEK_FREQEXC_GET  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = sobek_freqexc_get(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   sobek_freqexc_get
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
% Created: 14 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read settings

OPT = struct( ...
    'params', {{}}, ...
    'locations', {{}}, ...
    'months', 1:12, ...
    'horizon', 15, ...
    'dx', .01 ...
);

OPT = setproperty(OPT, varargin{:});

if isempty(OPT.params);     OPT.params      = {his.params.name};       end;
if isempty(OPT.locations);  OPT.locations   = {his.locations.name};    end;

if ~iscell(OPT.params);     OPT.params      = {OPT.params};            end;
if ~iscell(OPT.locations);  OPT.locations   = {OPT.locations};         end;

clear res;

%% determine peaks

t        = his.time;

for i = 1:length(OPT.params)
    for j = 1:length(OPT.locations)
        
        % determine indicies of params, locations and period
        ii  = strcmpi(OPT.params{i},    {his.params.name}   );
        jj  = strcmpi(OPT.locations{j}, {his.locations.name});
        kk  = ~ismember(str2num(datestr(t,'mm')), OPT.months);
        
        ts  = squeeze(his.data(:,ii,jj));
        ts(kk) = -Inf;
        
        res(i,j) = stat_freqexc_get(t, ts);
        
%         if any(kk)
%             
%             % determine individual periods
%             uc = find(~kk(1:end-1)&kk(2:end));
%             dc = find(~kk(2:end)&kk(1:end-1));
%             
%             if kk(1);   uc = [1;uc(:)];         end;
%             if kk(end); dc = [dc(:);length(t)]; end;
%             
%             resp = {};
% 
%             for k = 1:length(uc)
%                 
%                 % extract time series
%                 ts  = squeeze(his.data(:,ii,jj));
%                 ts(uc(k):dc(k)) = -Inf;
% 
%                 resp{k} = stat_freqexc_get(t(uc(k):dc(k)), ts);
%             end
%             
%             res(i,j) = stat_freqexc_merge(resp{:});
%         end
    end
end

if ~exist('res','var')
    res = [];
end




