function ddb_editDelft3DWAVEProcesses

ddb_refreshScreen('Physical Parameters','Processes');
handles=getHandles;

hp = uipanel('Units','pixels','Position',[35 35 960 100],'Tag','UIControl');

handles.GUIHandles.TextGeneration     = uicontrol(gcf,'Style','text','String','Generation mode for physics :','Position',[50 110 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditGeneration     = uicontrol(gcf,'Style','popupmenu','String',' ','Position',[220 110 120 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditGeneration,'Max',1);
set(handles.GUIHandles.EditGeneration,'String',handles.Model(md).Input.Generation);
set(handles.GUIHandles.EditGeneration,'CallBack',{@EditGeneration_CallBack});

handles.GUIHandles.ToggleBreaking      = uicontrol(gcf,'Style','checkbox','String','Depth-induced breaking (B&J model)','Position',[70 80 210 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleBreaking,'Value',handles.Model(md).Input.Breaking);
set(handles.GUIHandles.ToggleBreaking,  'CallBack',{@ToggleBreaking_CallBack});

handles.GUIHandles.TextAlpha1       = uicontrol(gcf,'Style','text','String','Alpha : ','Position',[70 60 70 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditAlpha1       = uicontrol(gcf,'Style','edit', 'Position',[120 60 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextAlpha1Unit   = uicontrol(gcf,'Style','text','String','[-]','Position',[180 60 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextGamma       = uicontrol(gcf,'Style','text','String','Gamma : ','Position',[70 40 70 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditGamma       = uicontrol(gcf,'Style','edit', 'Position',[120 40 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextGammaUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[180 40 20 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditAlpha1,'string',handles.Model(md).Input.Alpha1);
set(handles.GUIHandles.EditGamma,'string',handles.Model(md).Input.Gamma); 
if handles.Model(md).Input.Breaking
    set(handles.GUIHandles.EditAlpha1,'enable','on');
    set(handles.GUIHandles.EditGamma,'enable','on');
else
    set(handles.GUIHandles.EditAlpha1,'enable','off');
    set(handles.GUIHandles.EditGamma,'enable','off');
end
set(handles.GUIHandles.EditAlpha1,       'CallBack',{@EditAlpha1_CallBack});
set(handles.GUIHandles.EditGamma,        'CallBack',{@EditGamma_CallBack});

handles.GUIHandles.ToggleTriad      = uicontrol(gcf,'Style','checkbox','String','Non-linear triad interactions (LTA)','Position',[280 80 190 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleTriad,'Value',handles.Model(md).Input.Triad);
set(handles.GUIHandles.ToggleTriad,  'CallBack',{@ToggleTriad_CallBack});

handles.GUIHandles.TextAlpha2       = uicontrol(gcf,'Style','text','String','Alpha : ','Position',[280 60 70 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditAlpha2       = uicontrol(gcf,'Style','edit', 'Position',[330 60 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextAlpha2Unit   = uicontrol(gcf,'Style','text','String','[-]','Position',[390 60 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextBeta       = uicontrol(gcf,'Style','text','String','Beta : ','Position',[280 40 70 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditBeta       = uicontrol(gcf,'Style','edit', 'Position',[330 40 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextBetaUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[390 40 20 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditAlpha2,'string',handles.Model(md).Input.Alpha2);
set(handles.GUIHandles.EditBeta,'string',handles.Model(md).Input.Beta); 
if handles.Model(md).Input.Triad
    set(handles.GUIHandles.EditAlpha2,'enable','on');
    set(handles.GUIHandles.EditBeta,'enable','on');   
else
    set(handles.GUIHandles.EditAlpha2,'enable','off');
    set(handles.GUIHandles.EditBeta,'enable','off');
end
set(handles.GUIHandles.EditAlpha2,       'CallBack',{@EditAlpha2_CallBack});
set(handles.GUIHandles.EditBeta,        'CallBack',{@EditBeta_CallBack});

handles.GUIHandles.ToggleFriction      = uicontrol(gcf,'Style','checkbox','String','Bottom friction','Position',[490 80 150 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleFriction,'Value',handles.Model(md).Input.Friction);
set(handles.GUIHandles.ToggleFriction,  'CallBack',{@ToggleFriction_CallBack});

handles.GUIHandles.TextType       = uicontrol(gcf,'Style','text','String','Type : ','Position',[490 60 70 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditType       = uicontrol(gcf,'Style','popupmenu','String',handles.Model(md).Input.Type,'Position',[560 60 100 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextCoefficient       = uicontrol(gcf,'Style','text','String','Coefficient : ','Position',[490 40 70 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditCoefficient       = uicontrol(gcf,'Style','edit', 'Position',[560 40 100 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.EditType,'String',handles.Model(md).Input.Type);
set(handles.GUIHandles.EditType,'value',handles.Model(md).Input.Typeval);    
set(handles.GUIHandles.EditCoefficient,'string',handles.Model(md).Input.Coefficient);  
if handles.Model(md).Input.Friction
    set(handles.GUIHandles.EditType,'enable','on');
    set(handles.GUIHandles.EditCoefficient,'enable','on');  
else
    set(handles.GUIHandles.EditType,'enable','off');
    set(handles.GUIHandles.EditCoefficient,'enable','off');
end
set(handles.GUIHandles.EditType,       'CallBack',{@EditType_CallBack});
set(handles.GUIHandles.EditCoefficient,        'CallBack',{@EditCoefficient_CallBack});

handles.GUIHandles.ToggleDiffraction      = uicontrol(gcf,'Style','checkbox','String','Diffraction','Position',[700 80 150 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleDiffraction,'Value',handles.Model(md).Input.Diffraction);
set(handles.GUIHandles.ToggleDiffraction,  'CallBack',{@ToggleDiffraction_CallBack});

handles.GUIHandles.TextSmoothcoef       = uicontrol(gcf,'Style','text','String','Smoothing coef. : ','Position',[700 60 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditSmoothcoef       = uicontrol(gcf,'Style','edit', 'Position',[800 60 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSmoothcoefUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[860 60 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextSmoothsteps       = uicontrol(gcf,'Style','text','String','Smoothing steps : ','Position',[700 40 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditSmoothsteps       = uicontrol(gcf,'Style','edit', 'Position',[800 40 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSmoothstepsUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[860 40 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TogglePropagation      = uicontrol(gcf,'Style','checkbox','String','adapt propagation','Position',[880 60 110 15],'Tag','UIControl');

set(handles.GUIHandles.EditSmoothcoef,'string',handles.Model(md).Input.Smoothcoef);
set(handles.GUIHandles.EditSmoothsteps,'string',handles.Model(md).Input.Smoothsteps);
set(handles.GUIHandles.TogglePropagation,'value',handles.Model(md).Input.Propagation);

if handles.Model(md).Input.Diffraction
    set(handles.GUIHandles.EditSmoothcoef,'enable','on');
    set(handles.GUIHandles.EditSmoothsteps,'enable','on');
    set(handles.GUIHandles.TogglePropagation,'enable','on');
else
    set(handles.GUIHandles.EditSmoothcoef,'enable','off');
    set(handles.GUIHandles.EditSmoothsteps,'enable','off');
    set(handles.GUIHandles.TogglePropagation,'enable','off');
end
set(handles.GUIHandles.EditSmoothsteps,        'CallBack',{@EditSmoothsteps_CallBack});
set(handles.GUIHandles.EditSmoothcoef,       'CallBack',{@EditSmoothcoef_CallBack});
set(handles.GUIHandles.TogglePropagation,  'CallBack',{@TogglePropagation_CallBack});

setHandles(handles);

%%

function EditGeneration_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.GenerationIval=get(hObject,'value');
set(handles.GUIHandles.EditGeneration,'Value',handles.Model(md).Input.GenerationIval);
setHandles(handles);

function ToggleBreaking_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Breaking=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleBreaking,'Value',1);
    set(handles.GUIHandles.EditAlpha1,'enable','on');
    set(handles.GUIHandles.EditGamma,'enable','on');
else
    set(handles.GUIHandles.ToggleBreaking,'Value',0);
    set(handles.GUIHandles.EditAlpha1,'enable','off');
    set(handles.GUIHandles.EditGamma,'enable','off');    
end
setHandles(handles);

function ToggleTriad_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Triad=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleTriad,'Value',1);
    set(handles.GUIHandles.EditAlpha2,'enable','on');
    set(handles.GUIHandles.EditBeta,'enable','on');
else
    set(handles.GUIHandles.ToggleTriad,'Value',0);
    set(handles.GUIHandles.EditAlpha2,'enable','off');
    set(handles.GUIHandles.EditBeta,'enable','off');    
end
setHandles(handles);

function ToggleFriction_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Friction=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleFriction,'Value',1);
    set(handles.GUIHandles.EditType,'enable','on');
    set(handles.GUIHandles.EditCoefficient,'enable','on');
else
    set(handles.GUIHandles.ToggleFriction,'Value',0);
    set(handles.GUIHandles.EditType,'enable','off');
    set(handles.GUIHandles.EditCoefficient,'enable','off');    
end
setHandles(handles);

function ToggleDiffraction_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Diffraction=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleDiffraction,'Value',1);
    set(handles.GUIHandles.EditSmoothcoef,'enable','on');
    set(handles.GUIHandles.EditSmoothsteps,'enable','on');
    set(handles.GUIHandles.TogglePropagation,'enable','on');    
else
    set(handles.GUIHandles.ToggleDiffraction,'Value',0);
    set(handles.GUIHandles.EditSmoothcoef,'enable','off');
    set(handles.GUIHandles.EditSmoothsteps,'enable','off');
    set(handles.GUIHandles.TogglePropagation,'enable','off');
end
setHandles(handles);

function EditAlpha1_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Alpha1=get(hObject,'value');
setHandles(handles);

function EditGamma_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Gamma=get(hObject,'value');
setHandles(handles);

function EditAlpha2_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Alpha2=get(hObject,'value');
setHandles(handles);

function EditBeta_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Beta=get(hObject,'value');
setHandles(handles);

function EditType_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Typeval=get(hObject,'value');
setHandles(handles);

function EditCoefficient_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Coefficient=get(hObject,'value');
setHandles(handles);

function EditSmoothcoef_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Smoothcoef=get(hObject,'value');
setHandles(handles);

function EditSmoothsteps_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Smoothsteps=get(hObject,'value');
setHandles(handles);

function TogglePropagation_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Propagation=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.TogglePropagation,'Value',1);
else
    set(handles.GUIHandles.TogglePropagation,'Value',0);
end
setHandles(handles);
