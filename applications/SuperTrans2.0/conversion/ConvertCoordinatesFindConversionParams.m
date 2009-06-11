function CS = ConvertCoordinatesFindConversionParams(CS,STD)
ind1 = find(STD.coordinate_reference_system.coord_ref_sys_code == CS.code);
% Conversion parameters
conv.code =      STD.coordinate_reference_system.projection_conv_code(ind1); %#ok<FNDSB>
ind2      = find(STD.coordinate_operation_parameter_value.coord_op_code == conv.code);
conv.param.value       =      STD.coordinate_operation_parameter_value.parameter_value(ind2);
conv.param.codes       =      STD.coordinate_operation_parameter_value.parameter_code(ind2);
for ii=1:length(conv.param.codes)
    ind3(ii) = find(STD.coordinate_operation_parameter.parameter_code == conv.param.codes(ii));
end
conv.param.name        =      STD.coordinate_operation_parameter.parameter_name(ind3);

% Conversion parameters; Unit of Measure
conv.param.UoM.codes   =      STD.coordinate_operation_parameter_value.uom_code(ind2);
for ii=1:length(conv.param.UoM.codes)
    ind4(ii) = find(STD.unit_of_measure.uom_code == conv.param.UoM.codes(ii));
end
conv.param.UoM.name = STD.unit_of_measure.unit_of_meas_name(ind4);

% Conversion method
ind5             = find(STD.coordinate_operation.coord_op_code == conv.code); 
conv.name        =      STD.coordinate_operation.coord_op_name(ind5);
conv.method.code =      STD.coordinate_operation.coord_op_method_code(ind5);
ind6             = find(STD.coordinate_operation_method.coord_op_method_code == conv.method.code);
conv.method.name =      STD.coordinate_operation_method.coord_op_method_name{ind6};

CS.conv = conv;