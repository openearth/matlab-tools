function [x y z ne] = xb_read_bathy(xfile, yfile, depfile, nefile)
%XB_READ_BATHY  read xbeach bathymetry files
%
%   Routine to read xbeach bathymetry files.
%
%   Syntax:
%   [x y z ne] = xb_read_bathy(xfile, yfile, depfile, nefile)
%
%   Input:
%   xfile   = file name of x-coordinates file (cross-shore)
%   yfile   = file name of y-coordinates file (alongshore)
%   depfile = file name of bathymetry file
%   nefile  = file name of non erodible layer file
%
%   Output:
%   x       = x-coordinates
%   y       = y-coordinates
%   z       = bathymetry
%   ne      = non-erodible layer
%
%   Example
%   xb_read_bathy
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
if nargin > 0 && exist(xfile, 'file')
    % read file with x-coordinates (cross-shore)
    x = load(xfile);
end

if nargin > 1 && exist(yfile, 'file')
    % read file with y-coordinates (alongshore)
    y = load(yfile);
end

if nargin > 2 && exist(depfile, 'file')
    % read bathymetry file
    z = load(depfile);
end

if nargin > 3 && exist(nefile, 'file')
    % read non-erodible layer file
    ne = load(nefile);
end