function handles=ddb_readToolboxXML(handles,j)

s.elements=[];

fname=[handles.Toolbox(j).name '.xml'];

xmldir=handles.Toolbox(j).xmlDir;

handles.Toolbox(j).useXML=0;

handles.Toolbox(j).enable=0;

if exist([xmldir fname],'file')>0

    handles.Toolbox(j).useXML=1;
    xml=xml_load([xmldir fname]);
    
    handles.Toolbox(j).longName=xml.longname;
    
    tag = '';
    subFields={'Toolbox','Input'};
    subIndices={j,1};
    s=readUIElementsXML(xml,xmldir,tag,subFields,subIndices);
    if isfield(xml,'enable')
        handles.Toolbox(j).enable=str2double(xml.enable);
    end

end

handles.Toolbox(j).GUI.elements=s.elements;
