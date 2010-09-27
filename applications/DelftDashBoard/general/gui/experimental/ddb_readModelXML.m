function handles=ddb_readModelXML(handles,j)

fname=[handles.SettingsDir 'xml' filesep 'models' filesep handles.Model(j).Name filesep handles.Model(j).Name '.xml'];

s.elements=[];

if exist(fname,'file')

    handles.Model(j).useXML=1;    
    xml=xml_load(fname);
    
    handles.Model(j).longName=xml.longname;

    handles.Model(j).supportsMultipleDomains=0;
    if isfield(xml,'multipledomains')
        if strcmpi(xml.multipledomains(1),'y')
            handles.Model(j).supportsMultipleDomains=1;
        end
    end
    
    s=readUIElementsXML(xml);

end

%% Menu File
handles.Model(j).GUI.elements=s.elements;
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

