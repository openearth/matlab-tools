function EditSwanConstants

ddb_refreshScreen('Physical Parameters','Constants');
handles=getHandles;

handles.ToggleUniformW          = uicontrol(gcf,'Style','radiobutton', 'String','Uniform','Position',[50 110 110 15],'Tag','UIControl');
handles.ToggleSpacevaryingW     = uicontrol(gcf,'Style','radiobutton', 'String','Space-varying','Position',[50 90 110 15],'Tag','UIControl');

handles.TextSpeedW              = uicontrol(gcf,'Style','text','String','Speed : ','Position',[50 60 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditSpeedW              = uicontrol(gcf,'Style','edit', 'Position',[100 60 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextSpeedWUnit          = uicontrol(gcf,'Style','text','String','[m/s]','Position',[160 60 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditSpeedW,'Max',1);
set(handles.EditSpeedW,'String',handles.SwanInput(handles.ActiveDomain).SpeedW);
set(handles.EditSpeedW,'CallBack',{@EditSpeedW_CallBack});

handles.TextDirectionW       = uicontrol(gcf,'Style','text','String','Direction : ','Position',[50 40 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditDirectionW       = uicontrol(gcf,'Style','edit', 'Position',[100 40 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextDirectionWUnit   = uicontrol(gcf,'Style','text','String','deg]','Position',[160 40 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditDirectionW,'Max',1);
set(handles.EditDirectionW,'String',handles.SwanInput(handles.ActiveDomain).DirectionW);
set(handles.EditDirectionW,'CallBack',{@EditDirectionW_CallBack});

handles.PushAdd          = uicontrol(gcf,'Style','pushbutton',  'String','Select wind field File','Position',[210 100 200 20],'Tag','UIControl');
handles.TextWindFile     = uicontrol(gcf,'Style','text','String',['Wind field file : ' handles.SwanInput(handles.ActiveDomain).WindFile],'Position',[210 80 280 15],'HorizontalAlignment','left','Tag','UIControl');
handles.ToggleAsbathy    = uicontrol(gcf,'Style','radiobutton', 'String','As bathymetry','Position',[210 60 200 15],'Tag','UIControl');
handles.ToggleTospecify  = uicontrol(gcf,'Style','radiobutton', 'String','To specify','Position',[210 40 200 15],'Tag','UIControl');

handles.TextWindText     = uicontrol(gcf,'Style','text','String','Wind grid data : ','Position',[500 100 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextXoriginW     = uicontrol(gcf,'Style','text','String','X-origin : ','Position',[530 80 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditXoriginW     = uicontrol(gcf,'Style','edit', 'Position',[600 80 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextYoriginW     = uicontrol(gcf,'Style','text','String','Y-origin : ','Position',[530 60 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditYoriginW     = uicontrol(gcf,'Style','edit', 'Position',[600 60 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextAngleW       = uicontrol(gcf,'Style','text','String','Angle : ','Position',[530 40 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditAngleW       = uicontrol(gcf,'Style','edit', 'Position',[600 40 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextXcellsW      = uicontrol(gcf,'Style','text','String','Number of X-cells : ','Position',[700 100 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditXcellsW      = uicontrol(gcf,'Style','edit', 'Position',[800 100 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextYcellsW      = uicontrol(gcf,'Style','text','String','Number of Y-cells : ','Position',[700 80 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditYcellsW      = uicontrol(gcf,'Style','edit', 'Position',[800 80 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextXsizeW       = uicontrol(gcf,'Style','text','String','X-grid size : ','Position',[700 60 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditXsizeW       = uicontrol(gcf,'Style','edit', 'Position',[800 60 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextYsizeW       = uicontrol(gcf,'Style','text','String','Y-grid size : ','Position',[700 40 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditYsizeW       = uicontrol(gcf,'Style','edit', 'Position',[800 40 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.EditXoriginW,  'Max',1);
set(handles.EditYoriginW,  'Max',1);
set(handles.EditAngleW,    'Max',1);
set(handles.EditXcellsW,   'Max',1);
set(handles.EditYcellsW,   'Max',1);
set(handles.EditXsizeW,    'Max',1);
set(handles.EditYsizeW,    'Max',1);
        
if handles.SwanInput(handles.ActiveDomain).UniformW
    set(handles.ToggleUniformW,     'Value',1);
    set(handles.TextSpeedW,         'Enable','on');    
    set(handles.EditSpeedW,         'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.TextSpeedWUnit,     'Enable','on');
    set(handles.TextDirectionW,     'Enable','on');
    set(handles.EditDirectionW,     'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.TextDirectionWUnit, 'Enable','on');    
    set(handles.ToggleSpacevaryingW,'Value',0);
    set(handles.PushAdd,            'Enable','off');
    set(handles.ToggleAsbathy,      'Enable','off');
    set(handles.ToggleTospecify,    'Enable','off');
    set(handles.ToggleAsbathy,      'Value',0);
    set(handles.ToggleTospecify,    'Value',0);
    set(handles.TextWindFile,       'Enable','off');
    set(handles.TextWindText,       'Enable','off');
    set(handles.TextXoriginW,       'Enable','off');
    set(handles.EditXoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYoriginW,       'Enable','off');
    set(handles.EditYoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextAngleW,         'Enable','off');
    set(handles.EditAngleW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextXcellsW,        'Enable','off');
    set(handles.EditXcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYcellsW,        'Enable','off');
    set(handles.EditYcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextXsizeW,         'Enable','off');
    set(handles.EditXsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYsizeW,         'Enable','off');
    set(handles.EditYsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
elseif handles.SwanInput(handles.ActiveDomain).SpacevaryingW
    set(handles.ToggleUniformW,     'Value',0);
    set(handles.TextSpeedW,         'Enable','off');
    set(handles.EditSpeedW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.TextSpeedWUnit,     'Enable','off');
    set(handles.TextDirectionW,     'Enable','off');
    set(handles.EditDirectionW,     'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.TextDirectionWUnit, 'Enable','off');
    set(handles.ToggleSpacevaryingW,'Value',1);
    set(handles.PushAdd,            'Enable','on');
    set(handles.ToggleAsbathy,      'Enable','on');  
    set(handles.ToggleTospecify,    'Enable','on');
    set(handles.TextWindFile,       'Enable','on');
    if handles.SwanInput(handles.ActiveDomain).Tospecify
        set(handles.ToggleTospecify,    'Value',1);        
        set(handles.TextWindText,       'Enable','on');
        set(handles.TextXoriginW,       'Enable','on');
        set(handles.EditXoriginW,       'Enable','on','BackgroundColor',[1 1 1],'String',handles.SwanInput(handles.ActiveDomain).XoriginW);
        set(handles.TextYoriginW,       'Enable','on');
        set(handles.EditYoriginW,       'Enable','on','BackgroundColor',[1 1 1],'String',handles.SwanInput(handles.ActiveDomain).YoriginW);        
        set(handles.TextAngleW,         'Enable','on');
        set(handles.EditAngleW,         'Enable','on','BackgroundColor',[1 1 1],'String',handles.SwanInput(handles.ActiveDomain).AngleW);        
        set(handles.TextXcellsW,        'Enable','on');
        set(handles.EditXcellsW,        'Enable','on','BackgroundColor',[1 1 1],'String',handles.SwanInput(handles.ActiveDomain).XcellsW);        
        set(handles.TextYcellsW,        'Enable','on');
        set(handles.EditYcellsW,        'Enable','on','BackgroundColor',[1 1 1],'String',handles.SwanInput(handles.ActiveDomain).YcellsW);
        set(handles.TextXsizeW,         'Enable','on');
        set(handles.EditXsizeW,         'Enable','on','BackgroundColor',[1 1 1],'String',handles.SwanInput(handles.ActiveDomain).XsizeW);
        set(handles.TextYsizeW,         'Enable','on');
        set(handles.EditYsizeW,         'Enable','on','BackgroundColor',[1 1 1],'String',handles.SwanInput(handles.ActiveDomain).YsizeW);
    else
        set(handles.ToggleAsbathy,      'Value',1);
        set(handles.TextWindText,       'Enable','off');
        set(handles.TextXoriginW,       'Enable','off');
        set(handles.EditXoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.TextYoriginW,       'Enable','off');
        set(handles.EditYoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.TextAngleW,         'Enable','off');
        set(handles.EditAngleW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.TextXcellsW,        'Enable','off');
        set(handles.EditXcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.TextYcellsW,        'Enable','off');
        set(handles.EditYcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.TextXsizeW,         'Enable','off');
        set(handles.EditXsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
        set(handles.TextYsizeW,         'Enable','off');
        set(handles.EditYsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');  
    end
else
    set(handles.ToggleUniformW,     'Value',0);
    set(handles.TextSpeedW,         'Enable','off');
    set(handles.EditSpeedW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.TextSpeedWUnit,     'Enable','off');
    set(handles.TextDirectionW,     'Enable','off');
    set(handles.EditDirectionW,     'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.TextDirectionWUnit, 'Enable','off');
    set(handles.ToggleSpacevaryingW,'Value',0);
    set(handles.PushAdd,            'Enable','off');
    set(handles.ToggleAsbathy,      'Enable','off');
    set(handles.ToggleTospecify,    'Enable','off');
    set(handles.ToggleAsbathy,      'Value',0);
    set(handles.ToggleTospecify,    'Value',0);
    set(handles.TextWindFile,       'Enable','off');
    set(handles.TextWindText,       'Enable','off');
    set(handles.TextXoriginW,       'Enable','off');
    set(handles.EditXoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYoriginW,       'Enable','off');
    set(handles.EditYoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextAngleW,         'Enable','off');
    set(handles.EditAngleW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextXcellsW,        'Enable','off');
    set(handles.EditXcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYcellsW,        'Enable','off');
    set(handles.EditYcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextXsizeW,         'Enable','off');
    set(handles.EditXsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYsizeW,         'Enable','off');
    set(handles.EditYsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
end

set(handles.ToggleUniformW,       'CallBack',{@ToggleUniformW_CallBack});
set(handles.ToggleSpacevaryingW,  'CallBack',{@ToggleSpacevaryingW_CallBack});
set(handles.EditSpeedW,           'CallBack',{@EditSpeedW_CallBack});
set(handles.EditDirectionW,       'CallBack',{@EditDirectionW_CallBack});
set(handles.PushAdd,              'CallBack',{@PushAdd_CallBack});
set(handles.ToggleAsbathy,        'CallBack',{@ToggleAsbathy_CallBack});
set(handles.ToggleTospecify,      'CallBack',{@ToggleTospecify_CallBack});
set(handles.EditXoriginW,         'CallBack',{@EditXoriginW_CallBack});
set(handles.EditYoriginW,         'CallBack',{@EditYoriginW_CallBack});
set(handles.EditAngleW,           'CallBack',{@EditAngleW_CallBack});
set(handles.EditXcellsW,          'CallBack',{@EditXcellsW_CallBack});
set(handles.EditYcellsW,          'CallBack',{@EditYcellsW_CallBack});
set(handles.EditXsizeW,           'CallBack',{@EditXsizeW_CallBack});
set(handles.EditYsizeW,           'CallBack',{@EditYsizeW_CallBack});

setHandles(handles);

%%

function EditSpeedW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).SpeedW=get(hObject,'String');
setHandles(handles);

function EditDirectionW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).DirectionW=get(hObject,'String');
setHandles(handles);

function ToggleUniformW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).UniformW=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.TextSpeedW,         'Enable','on');    
    set(handles.EditSpeedW,         'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.TextSpeedWUnit,     'Enable','on');
    set(handles.TextDirectionW,     'Enable','on');
    set(handles.EditDirectionW,     'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.TextDirectionWUnit, 'Enable','on');    
    set(handles.ToggleSpacevaryingW,'Value',0); 
    handles.SwanInput(handles.ActiveDomain).SpacevaryingW=0;
    set(handles.PushAdd,            'Enable','off');
    set(handles.ToggleAsbathy,      'Enable','off');
    set(handles.ToggleTospecify,    'Enable','off');
    set(handles.ToggleAsbathy,      'Value',0);
    set(handles.ToggleTospecify,    'Value',0);
    set(handles.TextWindFile,       'Enable','off');
    set(handles.TextWindText,       'Enable','off');
    set(handles.TextXoriginW,       'Enable','off');
    set(handles.EditXoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYoriginW,       'Enable','off');
    set(handles.EditYoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextAngleW,         'Enable','off');
    set(handles.EditAngleW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextXcellsW,        'Enable','off');
    set(handles.EditXcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYcellsW,        'Enable','off');
    set(handles.EditYcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextXsizeW,         'Enable','off');
    set(handles.EditXsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYsizeW,         'Enable','off');
    set(handles.EditYsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
else
    set(handles.TextSpeedW,         'Enable','off');    
    set(handles.EditSpeedW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.TextSpeedWUnit,     'Enable','off');
    set(handles.TextDirectionW,     'Enable','off');
    set(handles.EditDirectionW,     'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.TextDirectionWUnit, 'Enable','off');    
end
setHandles(handles);

function ToggleSpacevaryingW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).SpacevaryingW=get(hObject,'Value');
if get(hObject,'Value')==1
    handles.SwanInput(handles.ActiveDomain).UniformW=0;
    set(handles.ToggleUniformW,     'Value',0);     
    set(handles.TextSpeedW,         'Enable','off');    
    set(handles.EditSpeedW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.TextSpeedWUnit,     'Enable','off');
    set(handles.TextDirectionW,     'Enable','off');
    set(handles.EditDirectionW,     'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.TextDirectionWUnit, 'Enable','off');
    set(handles.PushAdd,            'Enable','on');
    set(handles.ToggleAsbathy,      'Enable','on');
    set(handles.ToggleAsbathy,      'Value',1);    
    set(handles.ToggleTospecify,    'Enable','on');
    set(handles.TextWindFile,       'Enable','on');    
else
    set(handles.PushAdd,            'Enable','off');
    set(handles.ToggleAsbathy,      'Enable','off');
    set(handles.ToggleTospecify,    'Enable','off');
    set(handles.ToggleAsbathy,      'Value',0);
    set(handles.ToggleTospecify,    'Value',0);
    set(handles.TextWindFile,       'Enable','off');    
end
setHandles(handles);

function PushAdd_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.wnd', 'Select Wind File');
grid = ddb_wlgrid('read',[pathname filename]);
wind = ddb_wldep('read',[pathname filename],grid);
curdir=[lower(cd) '\'];
if ~strcmp(lower(curdir),lower(pathname))
    filename=[pathname filename];
end
handles.SwanInput(handles.ActiveDomain).WindFile=filename;
handles=Add(handles);
setHandles(handles);

function ToggleAsbathy_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Asbathy=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleAsbathy,'Value',1);
    set(handles.ToggleTospecify,'Value',0);
    handles.SwanInput(handles.ActiveDomain).Tospecify=0;
    set(handles.TextWindText,       'Enable','off');
    set(handles.TextXoriginW,       'Enable','off');
    set(handles.EditXoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYoriginW,       'Enable','off');
    set(handles.EditYoriginW,       'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextAngleW,         'Enable','off');
    set(handles.EditAngleW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextXcellsW,        'Enable','off');
    set(handles.EditXcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYcellsW,        'Enable','off');
    set(handles.EditYcellsW,        'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextXsizeW,         'Enable','off');
    set(handles.EditXsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');    
    set(handles.TextYsizeW,         'Enable','off');
    set(handles.EditYsizeW,         'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');     
end
setHandles(handles);

function ToggleTospecify_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Tospecify=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleAsbathy,'Value',0);
    set(handles.ToggleTospecify,'Value',1);
    handles.SwanInput(handles.ActiveDomain).Asbathy=0;
    set(handles.TextWindText,       'Enable','on');
    set(handles.TextXoriginW,       'Enable','on');
    set(handles.EditXoriginW,       'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.TextYoriginW,       'Enable','on');
    set(handles.EditYoriginW,       'Enable','on','BackgroundColor',[1 1 1]);    
    set(handles.TextAngleW,         'Enable','on');
    set(handles.EditAngleW,         'Enable','on','BackgroundColor',[1 1 1]);    
    set(handles.TextXcellsW,        'Enable','on');
    set(handles.EditXcellsW,        'Enable','on','BackgroundColor',[1 1 1]);    
    set(handles.TextYcellsW,        'Enable','on');
    set(handles.EditYcellsW,        'Enable','on','BackgroundColor',[1 1 1]);    
    set(handles.TextXsizeW,         'Enable','on');
    set(handles.EditXsizeW,         'Enable','on','BackgroundColor',[1 1 1]);    
    set(handles.TextYsizeW,         'Enable','on');
    set(handles.EditYsizeW,         'Enable','on','BackgroundColor',[1 1 1]);    
end
setHandles(handles);

function EditXoriginW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).XoriginW=get(hObject,'String');
setHandles(handles);

function EditYoriginW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).YoriginW=get(hObject,'String');
setHandles(handles);

function EditAngleW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).AngleW=get(hObject,'String');
setHandles(handles);

function EditXcellsW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).XcellsW=get(hObject,'String');
setHandles(handles);

function EditYcellsW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).YcellsW=get(hObject,'String');
setHandles(handles);

function EditXsizeW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).XsizeW=get(hObject,'String');
setHandles(handles);

function EditYsizeW_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).YsizeW=get(hObject,'String');
setHandles(handles);
