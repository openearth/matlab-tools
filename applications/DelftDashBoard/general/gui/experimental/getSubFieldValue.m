function val=getSubFieldValue(s,sfields,sindices,varname)

nf=length(sfields);
switch nf
    case 1
        val=s.(sfields{1}).(varname);
    case 2
        val=s.(sfields{1})(sindices{1}).(sfields{2}).(varname);
    case 3
        val=s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3}).(varname);
    case 4
        val=s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4}).(varname);
    case 5
        val=s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4})(sindices{4}).(sfields{5}).(varname);
end
