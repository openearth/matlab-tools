function data = simona2mdf_getboxdata(box,data)

% siminp2mdf_getboxdata : gets box data out of the parsed siminp file

for ibox = 1: length(box)
    m1 = box(ibox).MNMN(1);
    n1 = box(ibox).MNMN(2);
    m2 = box(ibox).MNMN(3);
    n2 = box(ibox).MNMN(4);
    if ~isempty(box(ibox).CONST_VALUES)
        data(m1:m2,n1:n2) = box(ibox).CONST_VALUES;
    end

    if ~isempty(box(ibox).VARIABLE_VAL)
        for m = m1:m2
            for n = n1:n2
                data(m,n) = box(ibox).VARIABLE_VAL((m-m1)*(n2-n1+1) + n - n1 + 1);
            end
        end
    end
    
    if ~isempty(box(ibox).CONST_VALUES)
        data(m1:m2,n1:n2) = box(ibox).CONST_VALUES;
    end
end
