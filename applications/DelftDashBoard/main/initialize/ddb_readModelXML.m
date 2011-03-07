function handles=ddb_readModelXML(handles,j)

fname=[handles.Model(j).name '.xml'];

%s.elements=[];

%xmldir=[handles.settingsDir filesep 'xml' filesep 'models' filesep handles.Model(j).name filesep];
%xmldir=[handles.settingsDir filesep 'xml' filesep 'models' filesep handles.Model(j).name filesep];
%xmldir=[handles.settingsDir filesep 'models' filesep handles.Model(j).name filesep 'xml' filesep ];
xmldir= handles.Model(j).xmlDir;

if exist(fname,'file')

    handles.Model(j).useXML=1;
    xml=xml_load([xmldir fname]);
    
    handles.Model(j).longName=xml.longname;

    handles.Model(j).supportsMultipleDomains=0;
    if isfield(xml,'multipledomains')
        if strcmpi(xml.multipledomains(1),'y')
            handles.Model(j).supportsMultipleDomains=1;
        end
    end

    handles.Model(j).enable=1;
    if isfield(xml,'enable')
        handles.Model(j).enable=str2double(xml.enable);
    end

    tag = '';
    subFields={'Model','Input'};
%    subIndices={j,'ad'};
    subIndices={j,@ad};
    s=readUIElementsXML(xml,xmldir,tag,subFields,subIndices);

end

handles.Model(j).GUI.elements=s.elements;

%% Menu File
if isfield(xml.menu,'menuopenfile')
    for i=1:length(xml.menu.menuopenfile)
        handles.Model(j).GUI.menu.openFile(i).string=xml.menu.menuopenfile(i).menuitem.string;
        handles.Model(j).GUI.menu.openFile(i).callback=str2func(xml.menu.menuopenfile(i).menuitem.callback);
        handles.Model(j).GUI.menu.openFile(i).option=xml.menu.menuopenfile(i).menuitem.option;
    end
else
    handles.Model(j).GUI.menu.openFile=[];
end

if isfield(xml.menu,'menusavefile')
    for i=1:length(xml.menu.menusavefile)
        handles.Model(j).GUI.menu.saveFile(i).string=xml.menu.menusavefile(i).menuitem.string;
        handles.Model(j).GUI.menu.saveFile(i).callback=str2func(xml.menu.menusavefile(i).menuitem.callback);
        handles.Model(j).GUI.menu.saveFile(i).option=xml.menu.menusavefile(i).menuitem.option;
    end
else
    handles.Model(j).GUI.menu.saveFile=[];
end

