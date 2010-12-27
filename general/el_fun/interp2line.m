function [zc xc yc] = interp2line(x, y, z, x0, y0, varargin)
%INTERP2LINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = interp2line(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   interp2line
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
% Created: 27 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% determine nearest point

xy = [x ; y];
xy0 = [x0 ; y0];

d = Inf; R = [Inf Inf];
for i = 1:size(xy,2)-1
    Ri = (  dot(xy0-xy(:,i+1), xy(:,i)-xy(:,i+1)) * xy(:,i) + ...
            dot(xy0-xy(:,i), xy(:,i+1)-xy(:,i)) * xy(:,i+1)  ) / ...
            dot(xy(:,i+1)-xy(:,i), xy(:,i+1)-xy(:,i));

    if norm(Ri - xy0) < d
        if (i == 1 && Ri(1) <= max(xy(1,i:i+1)) && Ri(2) <= max(xy(2,i:i+1))) || ...
            (   Ri(1) >= min(xy(1,i:i+1)) && Ri(2) >= min(xy(2,i:i+1)) && ...
                Ri(1) <= max(xy(1,i:i+1)) && Ri(2) <= max(xy(2,i:i+1))  ) || ...
            (i == length(x)-1 && Ri(1) >= min(xy(1,i:i+1)) && Ri(2) >= min(xy(2,i:i+1)))
            d = norm(Ri - xy0);

            R = Ri;
            L1 = sqrt(sum((xy(:,i)-R).^2));
            L2 = sqrt(sum((xy(:,i+1)-R).^2));
            L = L1 + L2;

            xc = R(1);
            yc = R(2);
            zc = z(i)*L2/L+z(i+1)*L1/L;
        end
    end
end

% figure; hold on;
% plot(x,y,'-ok');
% plot(x0,y0,'or');
% plot(xc,yc,'og');
% axis equal;