function handles=ddb_readToolboxXML(handles,j)

s.elements=[];

fname=[handles.Toolbox(j).Name '.xml'];

xmldir=[handles.Toolbox(j).Dir filesep 'xml' filesep];

handles.Toolbox(j).useXML=0;

if exist(fname,'file')

    handles.Toolbox(j).useXML=1;
    xml=xml_load([xmldir fname]);
    
    handles.Toolbox(j).longName=xml.longname;
    
    tag = '';
    subFields={'Toolbox','Input'};
    subIndices={j,1};
    s=readUIElementsXML(xml,xmldir,tag,subFields,subIndices);

end

handles.Toolbox(j).GUI.elements=s.elements;

% %% Menu File
% if isfield(xml.menu,'menuopenfile')
%     for i=1:length(xml.menu.menuopenfile)
%         handles.Toolbox(j).GUI.menu.openFile(i).string=xml.menu.menuopenfile(i).menuitem.string;
%         handles.Toolbox(j).GUI.menu.openFile(i).callback=str2func(xml.menu.menuopenfile(i).menuitem.callback);
%         handles.Toolbox(j).GUI.menu.openFile(i).option=xml.menu.menuopenfile(i).menuitem.option;
%     end
% else
%     handles.Toolbox(j).GUI.menu.openFile=[];
% end
% 
% if isfield(xml.menu,'menusavefile')
%     for i=1:length(xml.menu.menusavefile)
%         handles.Toolbox(j).GUI.menu.saveFile(i).string=xml.menu.menusavefile(i).menuitem.string;
%         handles.Toolbox(j).GUI.menu.saveFile(i).callback=str2func(xml.menu.menusavefile(i).menuitem.callback);
%         handles.Toolbox(j).GUI.menu.saveFile(i).option=xml.menu.menusavefile(i).menuitem.option;
%     end
% else
%     handles.Toolbox(j).GUI.menu.saveFile=[];
% end

