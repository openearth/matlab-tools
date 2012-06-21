function val=getSubFieldValue(s,el)

% s is global handles structure
% el is element structure

val=[];

% Variable name
if ~isempty(el.variableprefix)
    varstring=[el.variableprefix '.' el.variable];
else
    varstring=el.variable;
end

% Dashboard adaptation
if length(el.variable)>=7
    if strcmpi(el.variable(1:7),'handles')
        varstring=el.variable;
        varstring=strrep(varstring,'handles','s');
    end
end

try
    val=eval(v);
end
