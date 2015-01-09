function varargout = scatterbin(x,y,varargin)
%plot bivariate histogram to indicate density of scatter plot
%
% scatterbin(x,y) plots pcolor density plot with automatic bin
% edges. Bin is scaled to represent percentage of total points.
% Text is percentage is added to the plot.
%
% scatterbin(x,y,EDGESx,EDGESy) uses user-defined edges.
% Edges can be a vector with edge corners, or a scaler as the 
% number of bins (default 25), like hist. 
%
% Example:
%  scatterbin(x,y,EDGESx,EDGESy) 
%  hold on
%  scatter (x,y)
%  colorbarwithvtext('fraction [%]')
%
%See also: histc2, scatter, wind_rose

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Van Oord
%       Gerben de Boer, <gerben.deboer@vanoord.com>
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

OPT.scale = 100; % percent
OPT.fmt   = '%0.2f'; % percent
OPT.text  = 1;

EDGESx = 25;
EDGESy = 25;
if nargin==3
elseif nargin==4
    EDGESx = varargin{1};
    EDGESy = varargin{2};
end

if isscalar(EDGESx)
    EDGESx = linspace(min(x(:)),max(x(:)),EDGESx)';
end
if isscalar(EDGESy)
    EDGESy = linspace(min(y(:)),max(y(:)),EDGESy)';
end

% c = bin2(x,y,ones(size(x)),EDGESx,EDGESy,'exact',1);c = c.n;
bin = histc2(x,y,EDGESx,EDGESy);
bin = OPT.scale.*bin(1:end-1,1:end-1)./nansum(bin(:));
bin(bin==0)=nan;
h = pcolorcorcen(EDGESx,EDGESy,bin);
set(gca,'xtick',EDGESx)
set(gca,'ytick',EDGESy)

if OPT.text
    [xc,yc] = meshgrid(corner2center1(EDGESx),corner2center1(EDGESy));
    txt = cellstr(num2str(bin(:),OPT.fmt));
    txt = cellfun(@(x) strtrim(x),txt,'UniformOutput',0);
    ind = strmatch('NaN',txt);
    for i=ind(:)'
        txt{i} = '';
    end
    text(xc(:),yc(:),txt,'horizontal','center')
end


if nargout==1
    varargout = {h};
elseif nargout==2
    varargout = {h,bin};    
elseif nargout==4
    varargout = {h,bin,EDGESx,EDGESy};
elseif nargout==5
    varargout = {h,bin,EDGESx,EDGESy,txt};       
end


