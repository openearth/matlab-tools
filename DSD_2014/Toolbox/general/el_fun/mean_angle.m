function angle_m = mean_angle(angle)
%UNTITLED  Computes mean angle.
%
%   Syntax:
%   angle_m = mean_angle(angle)
%
%   Input:
%   angle: array with angles
%
%   Output:
%   angle_m: mean angle
%
%   Example
%   angle_m = mean_angle([340:1:20])
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 <COMPANY>
%       Jaap van Thiel de Vries
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 05 Jan 2011
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: mean_angle.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/el_fun/mean_angle.m $
% $Keywords: $

%%

vy = sind(angle);
vx = cosd(angle);

angle_m = atan2(sum(vy),sum(vx))*180/pi;

