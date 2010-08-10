function code=findEPSGcode(STD,name,type)

code=[];

if strcmpi(type,'geographic')
    strtype='geographic 2d';
else
    strtype='projected';
end

ii=strmatch(name,STD.coordinate_reference_system.coord_ref_sys_name,'exact');
for k=1:length(ii)
    if strcmpi(STD.coordinate_reference_system.coord_ref_sys_kind{ii(k)},strtype)
        code=STD.coordinate_reference_system.coord_ref_sys_code(ii(k));
        break
    end
end
