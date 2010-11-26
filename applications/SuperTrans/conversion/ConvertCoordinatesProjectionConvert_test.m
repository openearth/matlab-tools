function OK = ConvertCoordinatesProjectionConvert_test
% CONVERTCOORDINATESPROJECTIONCONVERT_TEST  Test routine for
% ConvertCoordinatesProjectionConvert
%  
% More detailed description of the test goes here.
%
%
%   See also CONVERTCOORDINATESPROJECTIONCONVERT

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Oct 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Unit;

CS.name = 'Amersfoort / RD New';
CS.type = 'projected';
CS.code = 28992;
STD = load('EPSG');
x1 = 100000;
y1 = 100000;
proj_conv = ConvertCoordinatesFindConversionParams(CS,STD);

CS.ellips.code = 7004;
CS.ellips.name = 'Bessel 1841';
CS.ellips.inv_flattening = 299.1528;
CS.ellips.semi_major_axis = 6.3774e+006;
CS.ellips.semi_minor_axis = 6.3561e+006;

OK = 0;

[y1,x1] = ConvertCoordinatesProjectionConvert(x1,y1,CS,proj_conv,'xy2geo',STD);

OK = any(y1);