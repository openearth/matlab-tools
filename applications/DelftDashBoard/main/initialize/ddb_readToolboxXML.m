function handles=ddb_readToolboxXML(handles,j)

s.elements=[];

fname=[handles.Toolbox(j).name '.xml'];

xmldir=[handles.Toolbox(j).dir filesep 'xml' filesep];

handles.Toolbox(j).useXML=0;

if exist([xmldir fname],'file')>0

    handles.Toolbox(j).useXML=1;
    xml=xml_load([xmldir fname]);
    
    handles.Toolbox(j).longName=xml.longname;
    
    tag = '';
    subFields={'Toolbox','Input'};
    subIndices={j,1};
    s=readUIElementsXML(xml,xmldir,tag,subFields,subIndices);

end

handles.Toolbox(j).GUI.elements=s.elements;
