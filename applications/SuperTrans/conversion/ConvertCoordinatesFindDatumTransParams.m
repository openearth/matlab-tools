function param = ConvertCoordinatesFindDatumTransParams(coord_op_code,STD)
%CONVERTCOORDINATESFINDDATUMTRANSPARAMS .

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

%% indices of transformation parameters
ind               = find(STD.coordinate_operation_parameter_value.coord_op_code == coord_op_code);
param.value       =      STD.coordinate_operation_parameter_value.parameter_value(ind);
param.codes       =      STD.coordinate_operation_parameter_value.parameter_code(ind);
for ii=1:length(param.codes)
    param.ind(ii) = find(STD.coordinate_operation_parameter.parameter_code == param.codes(ii));
end
param.name        =      STD.coordinate_operation_parameter.parameter_name(param.ind);

%% Conversion parameters; Unit of Measure
param.UoM.codes   =      STD.coordinate_operation_parameter_value.uom_code(ind);
for ii=1:length(param.UoM.codes)
    param.UoM.ind(ii)  = find(STD.unit_of_measure.uom_code == param.UoM.codes(ii));
end
param.UoM.sourceN =      STD.unit_of_measure.unit_of_meas_name(param.UoM.ind);
param.UoM.sourceT =      STD.unit_of_measure.unit_of_meas_type(param.UoM.ind);
param.UoM.fact_b  =      STD.unit_of_measure.factor_b(param.UoM.ind);
param.UoM.fact_c  =      STD.unit_of_measure.factor_c(param.UoM.ind);
param.UoM.targetC =      STD.unit_of_measure.target_uom_code(param.UoM.ind);
for ii=1:length(param.UoM.targetC)
    param.UoM.targetI(ii) =...
        find(STD.unit_of_measure.uom_code == param.UoM.targetC(ii));
end
param.UoM.targetN =      STD.unit_of_measure.unit_of_meas_name(param.UoM.targetI);


