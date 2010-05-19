function CS = ConvertCoordinatesFindUoM(CS,STD)
%CONVERTCOORDINATESGETUNITOFMEASURE Summary of this function goes here
%   Detailed explanation goes here

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

% $Id: ConvertCoordinatesFindUoM.m 2568 2009-11-12 14:27:10Z ormondt $
% $Date: 2009-11-12 15:27:10 +0100 (Thu, 12 Nov 2009) $
% $Author: ormondt $
% $Revision: 2568 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/mc_programs/DelftDashBoard/general/SuperTrans/conversion/ConvertCoordinatesFindUoM.m $
% $Keywords: $


ind1 = find(STD.coordinate_axis.coord_sys_code == CS.coordSys.code);
UoM.code = STD.coordinate_axis.uom_code(ind1(1));

if ~isempty(CS.UoM.code), UoM.code = CS.UoM.code; end

ind2 = find(STD.unit_of_measure.uom_code == UoM.code);
UoM.name = STD.unit_of_measure.unit_of_meas_name{ind2}; %#ok<FNDSB>

if ~isempty(CS.UoM.name), 
    ind3 = find(strcmpi(STD.unit_of_measure.unit_of_meas_name, CS.UoM.name));
    CS.UoM.code = STD.unit_of_measure.uom_code(ind3);
    CS.UoM.name = STD.unit_of_measure.unit_of_meas_name{ind3};
else
    CS.UoM.name = UoM.name;
    CS.UoM.code = UoM.code;
end

