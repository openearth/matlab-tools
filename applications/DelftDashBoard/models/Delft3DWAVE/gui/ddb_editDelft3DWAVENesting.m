function ddb_editDelft3DWAVENesting

ddb_refreshScreen('Grids','Nesting');
handles=getHandles;

id=handles.Model(md).Input.ActiveDomain;

hp = uipanel('Title','Grids','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.GUIHandles.TextComputationalGrids = uicontrol(gcf,'Style','text','string','Computational grids :','Position',[40 145 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditComputationalGrids = uicontrol(gcf,'Style','listbox','Position',[40 90 200 50],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditComputationalGrids,'Max',3);
set(handles.GUIHandles.EditComputationalGrids,'String',handles.Model(md).Input.ComputationalGrids,'Value',id);
set(handles.GUIHandles.EditComputationalGrids,'CallBack',{@EditComputationalGrids_CallBack});

handles.GUIHandles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[250 120 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushAdd,'Enable','off');

handles.GUIHandles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[250 90 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushDelete,'Enable','off');

handles.GUIHandles.TextCoordinateSystem = uicontrol(gcf,'Style','text','string',['Co-ordinate System : '],'Position',[40 70 150 15],'HorizontalAlignment','left','Tag','UIControl');

setHandles(handles);

hp = uipanel('Title','Grid data','Units','pixels','Position',[340 25 655 140],'Tag','UIControl');

handles.GUIHandles.TextGridNested       = uicontrol(gcf,'Style','text','String','Computational grid nested in : ','Position',[360 100 140 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditGridNested       = uicontrol(gcf,'Style','popupmenu', 'Position',[520 105 130 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.textGridname         = uicontrol(gcf,'Style','text', 'String',['Grid filename : '],'Position',[360 80 300 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.textAssosGrid        = uicontrol(gcf,'Style','text', 'String',['Associated bathymetry grid : '],'Position',[360 60 700 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.textAssosData        = uicontrol(gcf,'Style','text', 'String',['Associated bathymetry data : '],'Position',[360 40 700 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditGridNested,'Max',1);
set(handles.GUIHandles.EditGridNested,'String',handles.Model(md).Input.ComputationalGrids);
set(handles.GUIHandles.EditGridNested,'CallBack',{@EditGridNested_CallBack}); 

setHandles(handles);

Refresh(handles)

%%
function EditComputationalGrids_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.ActiveDomain=get(hObject,'Value');
setHandles(handles);
Refresh(handles)

function EditGridNested_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
inst=get(handles.GUIHandles.EditGridNested,'Value');
handles.Model(md).Input.Domain(id).NestedValue = inst;
handles.Model(md).Input.Domain(id).GridNested = handles.Model(md).Input.Domain(inst).GrdFile;
handles.Model(md).Input.Domain(id).NstFile = handles.Model(md).Input.ComputationalGrids{inst};
set(handles.GUIHandles.TextGridNested,'value',inst);
set(handles.GUIHandles.textAssosGrid, 'String',['Associated bathymetry grid : ' handles.Model(md).Input.Domain(inst).GrdFile]);
set(handles.GUIHandles.textAssosData, 'String',['Associated bathymetry data : ' handles.Model(md).Input.Domain(inst).DepFile]);
setHandles(handles);

function Refresh(handles)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
if ~isempty(handles.Model(md).Input.Domain(id).GridNested)
    inst=handles.Model(md).Input.Domain(id).NestedValue;
    set(handles.GUIHandles.EditGridNested,'value',inst);
    set(handles.GUIHandles.textAssosGrid, 'String',['Associated bathymetry grid : ' handles.Model(md).Input.Domain(inst).GrdFile]);
    set(handles.GUIHandles.textAssosData, 'String',['Associated bathymetry data : ' handles.Model(md).Input.Domain(inst).DepFile]);
else
    set(handles.GUIHandles.textAssosGrid, 'String',['Associated bathymetry grid : ' ]);
    set(handles.GUIHandles.textAssosData, 'String',['Associated bathymetry data : ' ]);    
end
setHandles(handles);


