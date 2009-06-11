function CS = ConvertCoordinatesFindUoM(CS,STD)
%CONVERTCOORDINATESGETUNITOFMEASURE Summary of this function goes here
%   Detailed explanation goes here

ind1 = find(STD.coordinate_axis.coord_sys_code == CS.coordSys.code);
UoM.code = STD.coordinate_axis.uom_code(ind1(1));

if ~isempty(CS.UoM.code), UoM.code = CS.UoM.code; end

ind2 = find(STD.unit_of_measure.uom_code == UoM.code);
UoM.name = STD.unit_of_measure.unit_of_meas_name(ind2); %#ok<FNDSB>

if ~isempty(CS.UoM.name), 
    ind3 = find(strcmpi(STD.unit_of_measure.unit_of_meas_name, CS.UoM.name));
    CS.UoM.code = STD.unit_of_measure.uom_code(ind3);
    CS.UoM.name = STD.unit_of_measure.unit_of_meas_name(ind3);
else
    CS.UoM.name = UoM.name;
    CS.UoM.code = UoM.code;
end

