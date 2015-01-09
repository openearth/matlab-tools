function varargout = scatterbin(x,y,varargin)
%plot bivariate histogram to indicate density of scatter plot
%
% scatterbin(x,y) plots pcolor density plot with automatic bin
% edges. scatterbin(x,y,EDGESx,EDGESy) uses user-defined edges.
% Edges can be a vector with edge corners, or a scaler as the 
% number of bins (default 25), like hist.
%
% Example:
%  scatterbin(x,y,EDGESx,EDGESy) 
%  hold on
%  scatter (x,y)
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
c = histc2(x,y,EDGESx,EDGESy);
c(c==0)=nan;
h = pcolorcorcen(EDGESx,EDGESy,c(1:end-1,1:end-1)./max(c(:)));

if nargout==1
    varargout = {h};
end


