function data = simona2mdf_getglobaldata(global_data,data)

% siminp2mdf_getflobal : gets global field data out of the parsed siminp file

mmax = size(data,1);
nmax = size(data,2);

if global_data.LAYOUT > 1
    simona2mdf_warning('LAYOUT > 1 not yet implemented');
end

if simona2mdf_fieldandvalue(global_data,'CONST_VALUES')
    data(1:mmax,1:nmax) = global_data.CONST_VALUES;
end

if simona2mdf_fieldandvalue(global_data,'VARIABLE_VAL')
    for m = mmax
        for n = 1:nmax
            data(m,n) = global_data.VARIABLE_VAL((m-m1)*(n2-n1+1) + n - n1 + 1);
        end
    end
end
