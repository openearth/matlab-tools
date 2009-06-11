function param = ConvertCoordinatesFindDatumTransParams(coord_op_code,STD)

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


