function ZI = griddata_remap(X, Y, Z, XI, YI, varargin)
%GRIDDATA_REMAP places regularly spaced xyz column data onto an X,Y grid returning Z
%   
%   Only rempas data from a 1D column to a regularly spaced 2D array, does
%   not interpolate anything.
%
%   Syntax:
%   ZI = griddata_remap(X, Y, Z, XI, YI)
%
%   Input:
%   X  = 1D vectore with coordinates
%   Y  = 1D vectore with coordinates
%   Z  = 1D vectore with coordinates
%   XI = XI must be either a 1D vector, or a 2D array made with meshgrid
%   YI = YI must be either a 1D vector, or a 2D array made with meshgrid
%
%   Output:
%   ZI = 2D array
%
%   Example
%   griddata_remap
%
%   See also: GRIDDATA, GRIDDATA_NEAREST, GRIDDATA_AVERAGE, GRIDDATE_REMAP,
%   INTERP2, BIN2 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       tda
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
% Created: 21 Apr 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $
%% set properties

OPT.errorCheck = true;

% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

%% vectorize data
x=X(:);
y=Y(:);
z=Z(:);

nans = isnan(z+x+y);

x(nans) = [];
y(nans) = [];
z(nans) = [];

%% input check
if OPT.errorCheck
    dimx = size(XI);
    dimy = size(YI);
    if length(dimx) ~= 2
        error('XI must be a 1D or 2D array')
    end
    
    dimx(dimx == 1) = [];
    dimy(dimy == 1) = [];
end
    
XI = unique(XI);
YI = unique(YI);
    
if OPT.errorCheck    
    if all(dimx ~= length(XI))||all(dimy ~= length(YI))
        error(['XI and YI must be either 1D vectors, or 2D vectors made with'...
            'meshgrid. Also, no duplicate values are allowed in XI or YI'])
    end
end
%% remap x and y to rounded gridpoints

ZI = nan(length(YI),length(XI));
for ii = 1:length(x)
    nn = YI == y(ii);
    mm = XI == x(ii);
    if OPT.errorCheck
        if any(nn)&&any(mm)
            if isnan(ZI(nn,mm))
                ZI(nn,mm) = z(ii);
            else
                warning('duplicate z value found at point #%d (z = %0.4f and z = %0.4f) at coordinates (x = %0.24f, y = %0.4f)',...
                    ii,ZI(nn,mm),z(ii),x(ii),y(ii)) %#ok<*WNTAG>
            end
        else
            warning(['point #%d (z = %0.4f) at coordinates (x = %0.4f, y = %0.4f)\n ',...
                '     could not be mapped to the XI,YI grid, maybe use griddata_average instead.\n',...
                '     The closest match off by dx = %0.6f, dy = %0.6f'],...
                ii,z(ii),x(ii),y(ii),min(abs(XI - x(ii))),min(abs(YI - y(ii))));
        end
    else % without error check
        ZI(nn,mm) = z(ii);
    end
end

