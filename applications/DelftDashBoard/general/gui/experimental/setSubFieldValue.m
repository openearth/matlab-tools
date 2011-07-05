function s=setSubFieldValue(s,variable,v)

if ischar(variable)

    variable=strrep(variable,'handles','s');
    
%     ip=strfind(variable,'.');
%     if ~isempty(ip)
%         ip=ip(end);
%         str1=variable(1:ip-1);
%         str1=variable(ip+1:end);
%         b=eval(str);
%         n=length(b);
%         for ii=1:n
%             
%         end
%     else
%     end    
    
    eval([variable '=v;']);
    
else
    
    varname=variable.name;
    if isstruct(varname)
        varname=getSubFieldValue(s,variable.name.variable);
    end
    varindex=variable.index;
    if isstruct(varindex)
        varindex=getSubFieldValue(s,variable.index.variable);
    end
    
    nf=length(variable.subFields);
    
    for i=1:nf
        name=variable.subFields(i).subField.name;
        if ~isstruct(name)
            sfields{i}=name;
        else
            sfields{i}=getSubFieldValue(s,variable.subFields(i).subField.name);
        end
        indx=variable.subFields(i).subField.index;
        if isa(indx,'function_handle')
            sindices{i}=feval(indx);
        elseif ~isstruct(indx)
            sindices{i}=indx;
        else
            sindices{i}=getSubFieldValue(s,variable.subFields(i).subField.index);
        end
    end
    
    % switch nf
    %     case 1
    %         s.(sfields{1})(sindices{1}).(varname)(varindex)=v;
    %     case 2
    %         s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(varname)(varindex)=v;
    %     case 3
    %         s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(varname)(varindex)=v;
    %     case 4
    %         s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4})(sindices{4}).(varname)(varindex)=v;
    %     case 5
    %         s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4})(sindices{4}).(sfields{5})(sindices{5}).(varname)(varindex)=v;
    % end
    
    switch nf
        case 1
            s.(sfields{1})(sindices{1}).(varname)=v;
        case 2
            s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(varname)=v;
        case 3
            s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(varname)=v;
        case 4
            s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4})(sindices{4}).(varname)=v;
        case 5
            s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4})(sindices{4}).(sfields{5})(sindices{5}).(varname)=v;
    end
    
end
