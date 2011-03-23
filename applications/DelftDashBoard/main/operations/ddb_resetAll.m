function ddb_resetAll

handles=getHandles;

% Delete new axes that is sometimes created for no apparent reason. Another
% fix for this should be found!!!
h=findobj(gcf,'Type','axes');
for i=1:length(h)
    if isempty(get(h(i),'Tag'));
        delete(h(i));
    end
end

if handles.debugMode

    h=findobj(gcf,'Tag','UIControl');
    if ~isempty(h)
        delete(h);
    end

    % Temporarily set map panel as child of current figure
    set(handles.GUIHandles.mapPanel,'Parent',gcf);

    iac=handles.Model(md).GUI.elements(1).activeTabNr;
    tbname=handles.Model(md).GUI.elements(1).tabs(iac).tabname;

    % Delete tab panels
    for i=1:length(handles.Model)
        try
            delete(handles.Model(i).GUI.elements(1).handle);
        end
    end
    
    % Read model xml files
    for i=1:length(handles.Model)
        handles=ddb_readModelXML(handles,i);
    end

    % Read toolbox xml files
    for i=1:length(handles.Toolbox)
        handles=ddb_readToolboxXML(handles,i);
    end

    for i=1:length(handles.Model)
        elements=handles.Model(i).GUI.elements;
        if ~isempty(elements)
            elements=addUIElements(gcf,elements,'getFcn',@getHandles,'setFcn',@setHandles);
            set(elements(1).handle,'Visible','off');
            handles.Model(i).GUI.elements=elements;
        end
    end

    handles=ddb_addToolboxElements(handles);
        
    setHandles(handles);
    
    ddb_resize;
    
    ddb_selectModel(handles.Model(md).name,tbname,'runcallback',0);
    
end

handles=getHandles;

for i=1:length(handles.Model)
    try
        feval(handles.Model(i).plotFcn,'delete');
    end
end

for i=1:length(handles.Toolbox)
    try
        feval(handles.Toolbox(i).plotFcn,'delete');
    end
end

ddb_initialize('all');

handles=getHandles;

% Make ModelMaker toolbox active
handles.activeToolbox.name='ModelMaker';
handles.activeToolbox.nr=1;

% Make sure that tb is updated
setHandles(handles);

% Check Model Maker in menu
c=handles.GUIHandles.Menu.Toolbox.ModelMaker;
p=get(c,'Parent');
ch=get(p,'Children');
set(ch,'Checked','off');
set(c,'Checked','on');

ddb_selectToolbox;

% % Add ModelMaker elements to model elements
% handles=ddb_addToolboxElements(handles);

% Update elements in model guis
for i=1:length(handles.Model)
    elements=handles.Model(i).GUI.elements;
    if ~isempty(elements)
        setUIElements(elements);
    end
end

setHandles(handles);

% % Select toolbox tab
% tabpanel('select','tag',handles.Model(md).name,'tabname','toolbox','runcallback',0);
% 
% % Now select ModelMaker toolbox (Quick Mode)
% ddb_ModelMakerToolbox_quickMode;

