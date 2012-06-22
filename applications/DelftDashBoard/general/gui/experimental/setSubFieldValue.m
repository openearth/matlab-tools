function s=setSubFieldValue(s,variable,v)
% Sets variable
try
    if length(variable)>=7
        if strcmpi(variable(1:7),'handles')
            % Old code, used for Delft Dashboard
            variable=strrep(variable,'handles','s');
            eval([variable '=v;']);
        else
            s.(variable)=v;
        end
    else
        s.(variable)=v;
    end
end
