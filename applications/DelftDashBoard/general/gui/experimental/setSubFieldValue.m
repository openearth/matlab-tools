function s=setSubFieldValue(s,sfields,sindices,varname,v)

nf=length(sfields);
switch nf
    case 1
        s.(sfields{1}).(varname)=v;
    case 2
        s.(sfields{1})(sindices{1}).(sfields{2}).(varname)=v;
    case 3
        s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3}).(varname)=v;
    case 4
        s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4}).(varname)=v;
    case 5
        s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4})(sindices{4}).(sfields{5}).(varname)=v;
end
