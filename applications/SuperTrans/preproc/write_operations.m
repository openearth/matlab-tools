load EPSG.mat

coordinate_operation           = EPSG.coordinate_operation;
copv                           = EPSG.coordinate_operation_parameter_value;
coordinate_operation_method    = EPSG.coordinate_operation_method;
coordinate_operation_parameter = EPSG.coordinate_operation_parameter;
unit_of_measure                = EPSG.unit_of_measure;

nconv=length(coordinate_operation);

Operations=[];

nc=0;
for i=1:nconv
    i
    co=coordinate_operation(i);
    flds=fieldnames(co);
    switch(lower(co.coord_op_type))
        case{'conversion','transformation'}
            nc=nc+1;
            for iii=1:length(flds)
                fld=flds{iii};
                val=getfield(co,fld);
                Operations=setfield(Operations,{nc},fld,val);
            end
            comc=co.coord_op_method_code;
            j=findinstruct(coordinate_operation_method,'coord_op_method_code',comc);
            Operations(nc).coordinate_operation_method=coordinate_operation_method(j).coord_op_method_name;
            coc=co.coord_op_code;
            n=findinstruct(copv,'coord_op_code',coc,'coord_op_method_code',comc);
            parameters=[];
            for ii=1:length(n)

                cc=copv(n(ii));
                
                % name
                parameter_code=cc.parameter_code;
                j=findinstruct(coordinate_operation_parameter,'parameter_code',parameter_code);
                cop=coordinate_operation_parameter(j);
                str=cop.parameter_name;
                str=strrep(str,' ','_');
                str=strrep(str,'-','_');
                str=strrep(str,'.','');
                parameters(ii).name=str;

                % value and unit
                switch cc.uom_code,
                    % Convert to degrees
                    case{9110}
                        cc.parameter_value=dms2deg(cc.parameter_value);
                        cc.uom_code=9102;
                end

                parameters(ii).value=cc.parameter_value;
                parameters(ii).uom_code=cc.uom_code;
                j=findinstruct(unit_of_measure,'uom_code',cc.uom_code);
                parameters(ii).unit_of_meas_name=unit_of_measure(j).unit_of_meas_name;
                parameters(ii).unit_of_meas_type=unit_of_measure(j).unit_of_meas_type;
                parameters(ii).target_uom_code=unit_of_measure(j).target_uom_code;
                parameters(ii).factor_b=unit_of_measure(j).factor_b;
                parameters(ii).factor_c=unit_of_measure(j).factor_c;
                
            end
            Operations=setfield(Operations,{nc},'parameters',parameters);
    end
end
