function [xmin xmax ymin ymax] = xb_grid_crop(x, y, z, varargin)
%XB_GRID_CROP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_grid_crop(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_grid_crop
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 15 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'crop', [] ...
);

OPT = setproperty(OPT, varargin{:});

%% determine crop position

if isempty(OPT.crop)
    OPT.crop = [0 0 Inf Inf];
    
    n = ~isnan(z);
    
    [cellsize xmin xmax] = xb_grid_resolution(x, y, 'maxsize', 100*1024);
    
    S_max = 0;
    for x1 = xmin:cellsize:xmax
        i = x>=x1&x<x1+cellsize&n;
        
        if ~any(any(i)); continue; end;
        
        y1 = min(y(i));
        y2 = max(y(i));
        
        j1 = y>=y1&y<y1+cellsize&n;
        j2 = y>=y2&y<y2+cellsize&n;
        
        if ~any(any(j1)) || ~any(any(j2)); continue; end;
        
        x2 = min([max(x(j1)) max(x(j2))]);
        
        x0 = min([x1 x2]);
        y0 = min([y1 y2]);
        w = abs(diff([x1 x2]));
        h = abs(diff([y1 y2]));
        
        % calculate number of non-nan's in selection
        S = sum(sum(x>=x0&x<x0+w&y>=y0&y<=y0+h&n));
        
        if S > S_max
            S_max = S;
            OPT.crop = [x0 y0 w h];
        end
    end
end

%% crop grid

xmin = OPT.crop(1);
ymin = OPT.crop(2);
xmax = OPT.crop(1)+OPT.crop(3);
ymax = OPT.crop(2)+OPT.crop(4);

