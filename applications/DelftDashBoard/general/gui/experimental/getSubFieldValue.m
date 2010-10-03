function val=getSubFieldValue(s,v)

hh=s;

%try
for i=1:length(v.subFields)
    name=v.subFields(i).subField.name;
    indx=v.subFields(i).subField.index;
    if isstruct(indx)
        indx=getSubFieldValue(s,indx);
    end
%    try
        if isa(indx,'function_handle')
            indx=feval(indx);
        end
    hh=hh.(name)(indx);
%    catch
%        shite=1
%    end
end
%catch
%    shite=13
%end
varname=v.name;
val=hh.(varname);
