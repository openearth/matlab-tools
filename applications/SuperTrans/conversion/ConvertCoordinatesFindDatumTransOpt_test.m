function OK = ConvertCoordinatesFindDatumTransOpt_test()
% CONVERTCOORDINATESFINDDATUMTRANSOPT_TEST  Test routine for
% ConvertCoordinatesFindDatumTransOpt
%  
% More detailed description of the test goes here.
%
%
%   See also CONVERTCOORDINATESFINDDATUMTRANSOPT

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

MTest.category('UnCategorized');

OPT.CS1.geoRefSys.code = 4289;
OPT.CS2.geoRefSys.code = 4326;

OPT.datum_trans_to_WGS84.code = [];
OPT.datum_trans_to_WGS84=[];
OPT.WGS84=[];
OPT.datum_trans_from_WGS84=[];
OPT.datum_trans.code = [];

STD = load('EPSG');

OK = 0;

OPT = ConvertCoordinatesFindDatumTransOpt(OPT,STD);

OK = (OPT.datum_trans.code == 15934);