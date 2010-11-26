function ConvertCoordinatesDatumTransform_test()
% CONVERTCOORDINATESDATUMTRANSFORM_TEST  Test routine for
% CONVERTCOORDINATESDATUMTRANSFORM
%  
% More detailed description of the test goes here.
%
%
%   See also CONVERTCOORDINATESDATUMTRANSFORM

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

lat1=100000;
lon1=100000;
OPT.CS1.code = 28992;
OPT.CS1.type = 'projected';
OPT.CS2.code = 4326;
OPT.CS1.type = 'geographic 2D';
STD = load('EPSG');

OPT = FindCSOptions(OPT,STD,{'CS1.code',OPT.CS1.code,'CS2.code',OPT.CS2.code});
[lat1,lon1] = ConvertCoordinatesProjectionConvert(lat1,lon1,OPT.CS1,OPT.proj_conv1,'xy2geo',STD);
OPT = ConvertCoordinatesFindDatumTransOpt(OPT,STD);

OK = 0;
[lat2,lon2] = ConvertCoordinatesDatumTransform(lat1,lon1,OPT,'datum_trans',STD);
OK = ~isempty(lat2);
