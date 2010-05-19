function ddb_editDelft3DWAVEConstants

ddb_refreshScreen('Physical Parameters','Constants');
handles=getHandles;

hp = uipanel('Units','pixels','Position',[35 35 960 100],'Tag','UIControl');

handles.GUIHandles.ToggleUniformW          = uicontrol(gcf,'Style','radiobutton', 'String','Uniform','Position',[50 110 110 15],'Tag','UIControl');
handles.GUIHandles.ToggleSpacevaryingW     = uicontrol(gcf,'Style','radiobutton', 'String','Space-varying','Position',[50 90 110 15],'Tag','UIControl');

handles.GUIHandles.TextSpeedW              = uicontrol(gcf,'Style','text','String','Speed : ','Position',[50 60 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditSpeedW              = uicontrol(gcf,'Style','edit', 'Position',[100 60 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSpeedWUnit          = uicontrol(gcf,'Style','text','String','[m/s]','Position',[160 60 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditSpeedW,'Max',1);
set(handles.GUIHandles.EditSpeedW,'String',handles.Model(md).Input.SpeedW);
set(handles.GUIHandles.EditSpeedW,'CallBack',{@EditSpeedW_CallBack});

handles.GUIHandles.TextDirectionW       = uicontrol(gcf,'Style','text','String','Direction : ','Position',[50 40 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditDirectionW       = uicontrol(gcf,'Style','edit', 'Position',[100 40 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextDirectionWUnit   = uicontrol(gcf,'Style','text','String','deg]','Position',[160 40 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditDirectionW,'Max',1);
set(handles.GUIHandles.EditDirectionW,'String',handles.Model(md).Input.DirectionW);
set(handles.GUIHandles.EditDirectionW,'CallBack',{@EditDirectionW_CallBack});

handles.GUIHandles.PushAdd          = uicontrol(gcf,'Style','pushbutton',  'String','Select wind field File','Position',[210 100 200 20],'Tag','UIControl');
handles.GUIHandles.TextWindFile     = uicontrol(gcf,'Style','text','String',['Wind field file : ' handles.Model(md).Input.WindFile],'Position',[210 80 280 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleAsbathy    = uicontrol(gcf,'Style','radiobutton', 'String','As bathymetry','Position',[210 60 200 15],'Tag','UIControl');
handles.GUIHandles.ToggleTospecify  = uicontrol(gcf,'Style','radiobutton', 'String','To specify','Position',[210 40 200 15],'Tag','UIControl');

handles.GUIHandles.TextWindText     = uicontrol(gcf,'Style','text','String','Wind grid data : ','Position',[500 100 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextXoriginW     = uicontrol(gcf,'Style','text','String','X-origin : ','Position',[530 80 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditXoriginW     = uicontrol(gcf,'Style','edit', 'Position',[600 80 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextYoriginW     = uicontrol(gcf,'Style','text','String','Y-origin : ','Position',[530 60 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditYoriginW     = uicontrol(gcf,'Style','edit', 'Position',[600 60 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextAngleW       = uicontrol(gcf,'Style','text','String','Angle : ','Position',[530 40 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditAngleW       = uicontrol(gcf,'Style','edit', 'Position',[600 40 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextXcellsW      = uicontrol(gcf,'Style','text','String','Number of X-cells : ','Position',[700 100 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditXcellsW      = uicontrol(gcf,'Style','edit', 'Position',[800 100 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextYcellsW      = uicontrol(gcf,'Style','text','String','Number of Y-cells : ','Position',[700 80 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditYcellsW      = uicontrol(gcf,'Style','edit', 'Position',[800 80 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextXsizeW       = uicontrol(gcf,'Style','text','String','X-grid size : ','Position',[700 60 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditXsizeW       = uicontrol(gcf,'Style','edit', 'Position',[800 60 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextYsizeW       = uicontrol(gcf,'Style','text','String','Y-grid size : ','Position',[700 40 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditYsizeW       = uicontrol(gcf,'Style','edit', 'Position',[800 40 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.EditXoriginW,  'Max',1);
set(handles.GUIHandles.EditYoriginW,  'Max',1);
set(handles.GUIHandles.EditAngleW,    'Max',1);
set(handles.GUIHandles.EditXcellsW,   'Max',1);
set(handles.GUIHandles.EditYcellsW,   'Max',1);
set(handles.GUIHandles.EditXsizeW,    'Max',1);
set(handles.GUIHandles.EditYsizeW,    'Max',1);
        
if handles.Model(md).Input.UniformW
    set(handles.GUIHandles.ToggleUniformW,     'Value',1);
    set(handles.GUIHandles.TextSpeedW,         'Enable','on');    
    set(handles.GUIHandles.EditSpeedW,         'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextSpeedWUnit,     'Enable','on');
    set(handles.GUIHandles.TextDirectionW,     'Enable','on');
    set(handles.GUIHandles.EditDirectionW,     'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextDirectionWUnit, 'Enable','on');    
    set(handles.GUIHandles.ToggleSpacevaryingW,'Value',0);
    set(handles.GUIHandles.PushAdd,            'Enable','off');
    set(handles.GUIHandles.ToggleAsbathy,      'Enable','off');
    set(handles.GUIHandles.ToggleTospecify,    'Enable','off');
    set(handles.GUIHandles.ToggleAsbathy,      'Value',0);
    set(handles.GUIHandles.ToggleTospecify,    'Value',0);
    set(handles.GUIHandles.TextWindFile,       'Enable','off');
    set(handles.GUIHandles.TextWindText,       'Enable','off');
    set(handles.GUIHandles.TextXoriginW,       'Enable','off');
    set(handles.GUIHandles.EditXoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYoriginW,       'Enable','off');
    set(handles.GUIHandles.EditYoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextAngleW,         'Enable','off');
    set(handles.GUIHandles.EditAngleW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextXcellsW,        'Enable','off');
    set(handles.GUIHandles.EditXcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYcellsW,        'Enable','off');
    set(handles.GUIHandles.EditYcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextXsizeW,         'Enable','off');
    set(handles.GUIHandles.EditXsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYsizeW,         'Enable','off');
    set(handles.GUIHandles.EditYsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
elseif handles.Model(md).Input.SpacevaryingW
    set(handles.GUIHandles.ToggleUniformW,     'Value',0);
    set(handles.GUIHandles.TextSpeedW,         'Enable','off');
    set(handles.GUIHandles.EditSpeedW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.GUIHandles.TextSpeedWUnit,     'Enable','off');
    set(handles.GUIHandles.TextDirectionW,     'Enable','off');
    set(handles.GUIHandles.EditDirectionW,     'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.GUIHandles.TextDirectionWUnit, 'Enable','off');
    set(handles.GUIHandles.ToggleSpacevaryingW,'Value',1);
    set(handles.GUIHandles.PushAdd,            'Enable','on');
    set(handles.GUIHandles.ToggleAsbathy,      'Enable','on');  
    set(handles.GUIHandles.ToggleTospecify,    'Enable','on');
    set(handles.GUIHandles.TextWindFile,       'Enable','on');
    if handles.Model(md).Input.Tospecify
        set(handles.GUIHandles.ToggleTospecify,    'Value',1);        
        set(handles.GUIHandles.TextWindText,       'Enable','on');
        set(handles.GUIHandles.TextXoriginW,       'Enable','on');
        set(handles.GUIHandles.EditXoriginW,       'Enable','on','BackgroundColor',[1 1 1],'String',handles.Model(md).Input.XoriginW);
        set(handles.GUIHandles.TextYoriginW,       'Enable','on');
        set(handles.GUIHandles.EditYoriginW,       'Enable','on','BackgroundColor',[1 1 1],'String',handles.Model(md).Input.YoriginW);        
        set(handles.GUIHandles.TextAngleW,         'Enable','on');
        set(handles.GUIHandles.EditAngleW,         'Enable','on','BackgroundColor',[1 1 1],'String',handles.Model(md).Input.AngleW);        
        set(handles.GUIHandles.TextXcellsW,        'Enable','on');
        set(handles.GUIHandles.EditXcellsW,        'Enable','on','BackgroundColor',[1 1 1],'String',handles.Model(md).Input.XcellsW);        
        set(handles.GUIHandles.TextYcellsW,        'Enable','on');
        set(handles.GUIHandles.EditYcellsW,        'Enable','on','BackgroundColor',[1 1 1],'String',handles.Model(md).Input.YcellsW);
        set(handles.GUIHandles.TextXsizeW,         'Enable','on');
        set(handles.GUIHandles.EditXsizeW,         'Enable','on','BackgroundColor',[1 1 1],'String',handles.Model(md).Input.XsizeW);
        set(handles.GUIHandles.TextYsizeW,         'Enable','on');
        set(handles.GUIHandles.EditYsizeW,         'Enable','on','BackgroundColor',[1 1 1],'String',handles.Model(md).Input.YsizeW);
    else
        set(handles.GUIHandles.ToggleAsbathy,      'Value',1);
        set(handles.GUIHandles.TextWindText,       'Enable','off');
        set(handles.GUIHandles.TextXoriginW,       'Enable','off');
        set(handles.GUIHandles.EditXoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.GUIHandles.TextYoriginW,       'Enable','off');
        set(handles.GUIHandles.EditYoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.GUIHandles.TextAngleW,         'Enable','off');
        set(handles.GUIHandles.EditAngleW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.GUIHandles.TextXcellsW,        'Enable','off');
        set(handles.GUIHandles.EditXcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.GUIHandles.TextYcellsW,        'Enable','off');
        set(handles.GUIHandles.EditYcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.GUIHandles.TextXsizeW,         'Enable','off');
        set(handles.GUIHandles.EditXsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.GUIHandles.TextYsizeW,         'Enable','off');
        set(handles.GUIHandles.EditYsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');  
    end
else
    set(handles.GUIHandles.ToggleUniformW,     'Value',0);
    set(handles.GUIHandles.TextSpeedW,         'Enable','off');
    set(handles.GUIHandles.EditSpeedW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.GUIHandles.TextSpeedWUnit,     'Enable','off');
    set(handles.GUIHandles.TextDirectionW,     'Enable','off');
    set(handles.GUIHandles.EditDirectionW,     'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.GUIHandles.TextDirectionWUnit, 'Enable','off');
    set(handles.GUIHandles.ToggleSpacevaryingW,'Value',0);
    set(handles.GUIHandles.PushAdd,            'Enable','off');
    set(handles.GUIHandles.ToggleAsbathy,      'Enable','off');
    set(handles.GUIHandles.ToggleTospecify,    'Enable','off');
    set(handles.GUIHandles.ToggleAsbathy,      'Value',0);
    set(handles.GUIHandles.ToggleTospecify,    'Value',0);
    set(handles.GUIHandles.TextWindFile,       'Enable','off');
    set(handles.GUIHandles.TextWindText,       'Enable','off');
    set(handles.GUIHandles.TextXoriginW,       'Enable','off');
    set(handles.GUIHandles.EditXoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYoriginW,       'Enable','off');
    set(handles.GUIHandles.EditYoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextAngleW,         'Enable','off');
    set(handles.GUIHandles.EditAngleW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextXcellsW,        'Enable','off');
    set(handles.GUIHandles.EditXcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYcellsW,        'Enable','off');
    set(handles.GUIHandles.EditYcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextXsizeW,         'Enable','off');
    set(handles.GUIHandles.EditXsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYsizeW,         'Enable','off');
    set(handles.GUIHandles.EditYsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
end

set(handles.GUIHandles.ToggleUniformW,       'CallBack',{@ToggleUniformW_CallBack});
set(handles.GUIHandles.ToggleSpacevaryingW,  'CallBack',{@ToggleSpacevaryingW_CallBack});
set(handles.GUIHandles.EditSpeedW,           'CallBack',{@EditSpeedW_CallBack});
set(handles.GUIHandles.EditDirectionW,       'CallBack',{@EditDirectionW_CallBack});
set(handles.GUIHandles.PushAdd,              'CallBack',{@PushAdd_CallBack});
set(handles.GUIHandles.ToggleAsbathy,        'CallBack',{@ToggleAsbathy_CallBack});
set(handles.GUIHandles.ToggleTospecify,      'CallBack',{@ToggleTospecify_CallBack});
set(handles.GUIHandles.EditXoriginW,         'CallBack',{@EditXoriginW_CallBack});
set(handles.GUIHandles.EditYoriginW,         'CallBack',{@EditYoriginW_CallBack});
set(handles.GUIHandles.EditAngleW,           'CallBack',{@EditAngleW_CallBack});
set(handles.GUIHandles.EditXcellsW,          'CallBack',{@EditXcellsW_CallBack});
set(handles.GUIHandles.EditYcellsW,          'CallBack',{@EditYcellsW_CallBack});
set(handles.GUIHandles.EditXsizeW,           'CallBack',{@EditXsizeW_CallBack});
set(handles.GUIHandles.EditYsizeW,           'CallBack',{@EditYsizeW_CallBack});

setHandles(handles);

%%

function EditSpeedW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.SpeedW=get(hObject,'String');
setHandles(handles);

function EditDirectionW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.DirectionW=get(hObject,'String');
setHandles(handles);

function ToggleUniformW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.UniformW=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.TextSpeedW,         'Enable','on');    
    set(handles.GUIHandles.EditSpeedW,         'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextSpeedWUnit,     'Enable','on');
    set(handles.GUIHandles.TextDirectionW,     'Enable','on');
    set(handles.GUIHandles.EditDirectionW,     'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextDirectionWUnit, 'Enable','on');    
    set(handles.GUIHandles.ToggleSpacevaryingW,'Value',0); 
    handles.Model(md).Input.SpacevaryingW=0;
    set(handles.GUIHandles.PushAdd,            'Enable','off');
    set(handles.GUIHandles.ToggleAsbathy,      'Enable','off');
    set(handles.GUIHandles.ToggleTospecify,    'Enable','off');
    set(handles.GUIHandles.ToggleAsbathy,      'Value',0);
    set(handles.GUIHandles.ToggleTospecify,    'Value',0);
    set(handles.GUIHandles.TextWindFile,       'Enable','off');
    set(handles.GUIHandles.TextWindText,       'Enable','off');
    set(handles.GUIHandles.TextXoriginW,       'Enable','off');
    set(handles.GUIHandles.EditXoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYoriginW,       'Enable','off');
    set(handles.GUIHandles.EditYoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextAngleW,         'Enable','off');
    set(handles.GUIHandles.EditAngleW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextXcellsW,        'Enable','off');
    set(handles.GUIHandles.EditXcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYcellsW,        'Enable','off');
    set(handles.GUIHandles.EditYcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextXsizeW,         'Enable','off');
    set(handles.GUIHandles.EditXsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYsizeW,         'Enable','off');
    set(handles.GUIHandles.EditYsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
else
    set(handles.GUIHandles.TextSpeedW,         'Enable','off');    
    set(handles.GUIHandles.EditSpeedW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.GUIHandles.TextSpeedWUnit,     'Enable','off');
    set(handles.GUIHandles.TextDirectionW,     'Enable','off');
    set(handles.GUIHandles.EditDirectionW,     'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.GUIHandles.TextDirectionWUnit, 'Enable','off');    
end
setHandles(handles);

function ToggleSpacevaryingW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.SpacevaryingW=get(hObject,'Value');
if get(hObject,'Value')==1
    handles.Model(md).Input.UniformW=0;
    set(handles.GUIHandles.ToggleUniformW,     'Value',0);     
    set(handles.GUIHandles.TextSpeedW,         'Enable','off');    
    set(handles.GUIHandles.EditSpeedW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.GUIHandles.TextSpeedWUnit,     'Enable','off');
    set(handles.GUIHandles.TextDirectionW,     'Enable','off');
    set(handles.GUIHandles.EditDirectionW,     'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.GUIHandles.TextDirectionWUnit, 'Enable','off');
    set(handles.GUIHandles.PushAdd,            'Enable','on');
    set(handles.GUIHandles.ToggleAsbathy,      'Enable','on');
    set(handles.GUIHandles.ToggleAsbathy,      'Value',1);    
    set(handles.GUIHandles.ToggleTospecify,    'Enable','on');
    set(handles.GUIHandles.TextWindFile,       'Enable','on');    
else
    set(handles.GUIHandles.PushAdd,            'Enable','off');
    set(handles.GUIHandles.ToggleAsbathy,      'Enable','off');
    set(handles.GUIHandles.ToggleTospecify,    'Enable','off');
    set(handles.GUIHandles.ToggleAsbathy,      'Value',0);
    set(handles.GUIHandles.ToggleTospecify,    'Value',0);
    set(handles.GUIHandles.TextWindFile,       'Enable','off');    
end
setHandles(handles);

function PushAdd_CallBack(hObject,eventdata)
handles=getHandles;
try
[filename, pathname, filterindex] = uigetfile('*.wnd', 'Select Wind File');
grid = wlgrid('read',[pathname filename]);
wind = wldep('read',[pathname filename],grid);
curdir=[lower(cd) '\'];
if ~strcmp(lower(curdir),lower(pathname))
    filename=[pathname filename];
end
handles.Model(md).Input.WindFile=filename;
end
setHandles(handles);

function ToggleAsbathy_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Asbathy=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleAsbathy,'Value',1);
    set(handles.GUIHandles.ToggleTospecify,'Value',0);
    handles.Model(md).Input.Tospecify=0;
    set(handles.GUIHandles.TextWindText,       'Enable','off');
    set(handles.GUIHandles.TextXoriginW,       'Enable','off');
    set(handles.GUIHandles.EditXoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYoriginW,       'Enable','off');
    set(handles.GUIHandles.EditYoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextAngleW,         'Enable','off');
    set(handles.GUIHandles.EditAngleW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextXcellsW,        'Enable','off');
    set(handles.GUIHandles.EditXcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYcellsW,        'Enable','off');
    set(handles.GUIHandles.EditYcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextXsizeW,         'Enable','off');
    set(handles.GUIHandles.EditXsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.GUIHandles.TextYsizeW,         'Enable','off');
    set(handles.GUIHandles.EditYsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');     
end
setHandles(handles);

function ToggleTospecify_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Tospecify=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleAsbathy,'Value',0);
    set(handles.GUIHandles.ToggleTospecify,'Value',1);
    handles.Model(md).Input.Asbathy=0;
    set(handles.GUIHandles.TextWindText,       'Enable','on');
    set(handles.GUIHandles.TextXoriginW,       'Enable','on');
    set(handles.GUIHandles.EditXoriginW,       'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextYoriginW,       'Enable','on');
    set(handles.GUIHandles.EditYoriginW,       'Enable','on','BackgroundColor',[1 1 1]);    
    set(handles.GUIHandles.TextAngleW,         'Enable','on');
    set(handles.GUIHandles.EditAngleW,         'Enable','on','BackgroundColor',[1 1 1]);    
    set(handles.GUIHandles.TextXcellsW,        'Enable','on');
    set(handles.GUIHandles.EditXcellsW,        'Enable','on','BackgroundColor',[1 1 1]);    
    set(handles.GUIHandles.TextYcellsW,        'Enable','on');
    set(handles.GUIHandles.EditYcellsW,        'Enable','on','BackgroundColor',[1 1 1]);    
    set(handles.GUIHandles.TextXsizeW,         'Enable','on');
    set(handles.GUIHandles.EditXsizeW,         'Enable','on','BackgroundColor',[1 1 1]);    
    set(handles.GUIHandles.TextYsizeW,         'Enable','on');
    set(handles.GUIHandles.EditYsizeW,         'Enable','on','BackgroundColor',[1 1 1]);    
end
setHandles(handles);

function EditXoriginW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.XoriginW=get(hObject,'String');
setHandles(handles);

function EditYoriginW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.YoriginW=get(hObject,'String');
setHandles(handles);

function EditAngleW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.AngleW=get(hObject,'String');
setHandles(handles);

function EditXcellsW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.XcellsW=get(hObject,'String');
setHandles(handles);

function EditYcellsW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.YcellsW=get(hObject,'String');
setHandles(handles);

function EditXsizeW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.XsizeW=get(hObject,'String');
setHandles(handles);

function EditYsizeW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.YsizeW=get(hObject,'String');
setHandles(handles);




