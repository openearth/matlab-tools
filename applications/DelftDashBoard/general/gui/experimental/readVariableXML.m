function v=readVariableXML(sxml,subFields,subIndices)

% Name
try
if ~isstruct(sxml.name)
    v.name = sxml.name;
else
    v.name = readVariableXML(sxml.name.variable,subFields,subIndices);
end
catch
    shite=12
end

% Type
if isfield(sxml,'type')
    if ~isstruct(sxml.type)
        v.type = sxml.type;
    else
        v.type = readVariableXML(sxml.type.variable,subFields,subIndices);
    end
end

% Index
if isfield(sxml,'index')
    if ~isstruct(sxml.index)
        v.index = str2num(sxml.index);
    else
        v.index = readVariableXML(sxml.index.variable,subFields,subIndices);
    end
else
    v.index=1;
end

% SubFields
for i=1:length(subFields)
    v.subFields(i).subField.name=subFields{i};
    v.subFields(i).subField.index=subIndices{i};
end

for i=1:10
    fldname=['subfield' num2str(i)];
    if isfield(sxml,fldname)
        if ~isstruct(sxml.(fldname))
            v.subFields(i).subField.name=sxml.(fldname);
            v.subFields(i).subField.index=1;
        else
            v.subFields(i).subField=readVariableXML(sxml.(fldname).variable,subFields,subIndices);
        end
    end
end
