function CS = ConvertCoordinatesFindCoordSys(CS,STD)
%CONVERTCOORDINATESFINDCOORDSYS Finds coordinate system name and code
%
%   This routine searches in the EPSG database for the name and code of the
%   input coordinate system.
%
%   Syntax:
%   CS = ConvertCoordinatesFindCoordSys(CS,STD)
%
%   Input:
%   CS  = input coordinate system structure
%   STD = structure with all EPSG codes
%
%   Output:
%   CS = output coordinate system structure, containing extra field
%       'coordSys' with coordinate system information
%
%   See also CONVERTCOORDINATES

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

ind1             = find(STD.coordinate_reference_system.coord_ref_sys_code == CS.code);
CS.coordSys.code =      STD.coordinate_reference_system.coord_sys_code(ind1); %#ok<FNDSB>
ind2             = find(STD.coordinate_system.coord_sys_code == CS.coordSys.code);
CS.coordSys.name =      STD.coordinate_system.coord_sys_name{ind2}; %#ok<FNDSB>
