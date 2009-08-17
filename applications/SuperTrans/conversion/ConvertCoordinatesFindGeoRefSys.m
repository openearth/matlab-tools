function CS = ConvertCoordinatesFindGeoRefSys(CS,STD)
%ConvertCoordinatesFindGeoRefSys .

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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

if strcmp(CS.type,'projected')
    ind1 = find(STD.coordinate_reference_system.coord_ref_sys_code == CS.code);
    CS.geoRefSys.code = STD.coordinate_reference_system.source_geogcrs_code(ind1); %#ok<FNDSB>
    ind2 = find(STD.coordinate_reference_system.coord_ref_sys_code == CS.geoRefSys.code);
    CS.geoRefSys.name = STD.coordinate_reference_system.coord_ref_sys_name{ind2}; %#ok<FNDSB>
else
    CS.geoRefSys.name = CS.name;
    CS.geoRefSys.code = CS.code;
end
