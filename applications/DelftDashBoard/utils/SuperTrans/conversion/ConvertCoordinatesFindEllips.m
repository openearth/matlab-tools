function CS = ConvertCoordinatesFindEllips(CS,STD)
%CONVERTCOORDINATESFINDELLIPS .

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% $Id: ConvertCoordinatesFindEllips.m 2568 2009-11-12 14:27:10Z ormondt $
% $Date: 2009-11-12 15:27:10 +0100 (Thu, 12 Nov 2009) $
% $Author: ormondt $
% $Revision: 2568 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/mc_programs/DelftDashBoard/general/SuperTrans/conversion/ConvertCoordinatesFindEllips.m $
% $Keywords: $

ind1 = find(STD.datum.datum_code == CS.datum.code);
ell.code = STD.datum.ellipsoid_code(ind1) ; %#ok<FNDSB>
ind2 = find(STD.ellipsoid.ellipsoid_code == ell.code);

ell.name  = STD.ellipsoid.ellipsoid_name{ind2}; %#ok<FNDSB>
ell.inv_flattening = STD.ellipsoid.inv_flattening(ind2); %#ok<FNDSB>
ell.semi_major_axis = STD.ellipsoid.semi_major_axis(ind2); %#ok<FNDSB>
ell.semi_minor_axis = STD.ellipsoid.semi_minor_axis(ind2); %#ok<FNDSB>

% calculate inv_flattening if it is not given
if isnan(ell.inv_flattening)
    ell.inv_flattening=ell.semi_major_axis/(ell.semi_major_axis-ell.semi_minor_axis);
end

% calculate semi minor axis if it is not given
if isnan(ell.semi_minor_axis)
    ell.semi_minor_axis = -(ell.semi_major_axis/ell.inv_flattening)+ell.semi_major_axis;
end

CS.ellips = ell;


