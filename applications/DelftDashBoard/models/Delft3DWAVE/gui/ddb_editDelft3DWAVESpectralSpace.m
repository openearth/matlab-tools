function EditD3DWAVESpectralSpace

handles=getHandles;
SettingsDir=getINIValue(handles.IniFile,'SettingsDir');
fig0=gcf;

fig=MakeNewWindow('Spectral space',[400 320],[SettingsDir '\icons\deltares.gif']);

hp = uipanel('Units','pixels','Position',[5 5 390 310],'Tag','UIControl');
        
handles.GUIHandles.TextShape        = uicontrol(gcf,'Style','text','String','Shape : ','Position',[20 290 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.ToggleJonswap    = uicontrol(gcf,'Style','radiobutton', 'String','Jonswap','Position',[100 270 150 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleJonswap,'Value',handles.Model(md).Input.JonswapTemp);
set(handles.GUIHandles.ToggleJonswap,'CallBack',{@ToggleJonswap_CallBack});

handles.GUIHandles.TextJonswapval   = uicontrol(gcf,'Style','text','String','Peak enh. fact.:','Position',[200 270 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditJonswapval   = uicontrol(gcf,'Style','edit', 'Position',[280 270 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditJonswapval,'Max',1);
if handles.Model(md).Input.JonswapTemp == 1
    set(handles.GUIHandles.EditJonswapval,'enable','on');
else
    set(handles.GUIHandles.EditJonswapval,'enable','off');
end
set(handles.GUIHandles.EditJonswapval,'String',num2str(handles.Model(md).Input.JonswapvalTemp));
set(handles.GUIHandles.EditJonswapval,'CallBack',{@EditJonswapval_CallBack});    

handles.GUIHandles.TogglePierson    = uicontrol(gcf,'Style','radiobutton', 'String','Pierson-Moskowitz','Position',[100 250 150 15],'Tag','UIControl');
set(handles.GUIHandles.TogglePierson,'Value',handles.Model(md).Input.PiersonTemp);
set(handles.GUIHandles.TogglePierson,'CallBack',{@TogglePierson_CallBack});

handles.GUIHandles.ToggleGauss    = uicontrol(gcf,'Style','radiobutton', 'String','Gauss','Position',[100 230 150 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleGauss,'Value',handles.Model(md).Input.GaussTemp);
set(handles.GUIHandles.ToggleGauss,'CallBack',{@ToggleGauss_CallBack});

handles.GUIHandles.TextGaussval   = uicontrol(gcf,'Style','text','String','Spreading:','Position',[200 230 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditGaussval   = uicontrol(gcf,'Style','edit', 'Position',[280 230 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditGaussval,'Max',1);
if handles.Model(md).Input.GaussTemp == 1
    set(handles.GUIHandles.EditGaussval,'enable','on');
else
    set(handles.GUIHandles.EditGaussval,'enable','off');
end
set(handles.GUIHandles.EditGaussval,'String',num2str(handles.Model(md).Input.GaussvalTemp));
set(handles.GUIHandles.EditGaussval,'CallBack',{@EditGaussval_CallBack});

handles.GUIHandles.TextPeriod        = uicontrol(gcf,'Style','text','String','Period : ','Position',[20 190 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TogglePeak    = uicontrol(gcf,'Style','radiobutton', 'String','Peak','Position',[100 170 150 15],'Tag','UIControl');
set(handles.GUIHandles.TogglePeak,'Value',handles.Model(md).Input.PeakTemp);
set(handles.GUIHandles.TogglePeak,'CallBack',{@TogglePeak_CallBack});

handles.GUIHandles.ToggleMean    = uicontrol(gcf,'Style','radiobutton', 'String','Mean','Position',[100 150 150 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleMean,'Value',handles.Model(md).Input.MeanTemp);
set(handles.GUIHandles.ToggleMean,'CallBack',{@ToggleMean_CallBack});

handles.GUIHandles.TextDirSpread        = uicontrol(gcf,'Style','text','String','Directional spreading : ','Position',[20 110 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.ToggleCosine    = uicontrol(gcf,'Style','radiobutton', 'String','Cosine power','Position',[100 90 150 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleCosine,'Value',handles.Model(md).Input.CosineTemp);
set(handles.GUIHandles.ToggleCosine,'CallBack',{@ToggleCosine_CallBack});

handles.GUIHandles.ToggleDegrees    = uicontrol(gcf,'Style','radiobutton', 'String','Degrees (standard deviation)','Position',[100 70 200 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleDegrees,'Value',handles.Model(md).Input.DegreesTemp);
set(handles.GUIHandles.ToggleDegrees,'CallBack',{@ToggleDegrees_CallBack});

handles.GUIHandles.PushCloseWindow      = uicontrol(gcf,'Style','pushbutton',  'String','Close','Position',[160 20 80 20],'Tag','UIControl');
set(handles.GUIHandles.PushCloseWindow,'Enable','on');
set(handles.GUIHandles.PushCloseWindow,'CallBack',{@PushCloseWindow_CallBack});

guidata(findobj('Tag','Spectral space'),handles);

%%
function EditJonswapval_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Spectral space'));
handles.Model(md).Input.JonswapvalTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Spectral space'),handles);

function EditGaussval_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Spectral space'));
handles.Model(md).Input.GaussvalTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Spectral space'),handles);

function ToggleJonswap_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Spectral space'));
handles.Model(md).Input.JonswapTemp=get(hObject,'value');
if get(hObject,'value')==1
    set(handles.GUIHandles.ToggleJonswap,'Value',1);
    set(handles.GUIHandles.TogglePierson,'Value',0);
    set(handles.GUIHandles.ToggleGauss,'Value',0);
    set(handles.GUIHandles.EditJonswapval,'enable','on');
    set(handles.GUIHandles.EditGaussval,'enable','off');
    handles.Model(md).Input.PiersonTemp=0;
    handles.Model(md).Input.GaussTemp=0;
end
guidata(findobj('Tag','Spectral space'),handles);

function TogglePierson_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Spectral space'));
handles.Model(md).Input.PiersonTemp=get(hObject,'value');
if get(hObject,'value')==1
    set(handles.GUIHandles.ToggleJonswap,'Value',0);
    set(handles.GUIHandles.TogglePierson,'Value',1);
    set(handles.GUIHandles.ToggleGauss,'Value',0);
    set(handles.GUIHandles.EditJonswapval,'enable','off');
    set(handles.GUIHandles.EditGaussval,'enable','off');
    handles.Model(md).Input.JonswapTemp=0;
    handles.Model(md).Input.GaussTemp=0;
end
guidata(findobj('Tag','Spectral space'),handles);

function ToggleGauss_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Spectral space'));
handles.Model(md).Input.GaussTemp=get(hObject,'value');
if get(hObject,'value')==1
    set(handles.GUIHandles.ToggleJonswap,'Value',0);
    set(handles.GUIHandles.TogglePierson,'Value',0);
    set(handles.GUIHandles.ToggleGauss,'Value',1);
    set(handles.GUIHandles.EditJonswapval,'enable','off');
    set(handles.GUIHandles.EditGaussval,'enable','on');
    handles.Model(md).Input.JonswapTemp=0;
    handles.Model(md).Input.PiersonTemp=0;
end
guidata(findobj('Tag','Spectral space'),handles);

function TogglePeak_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Spectral space'));
handles.Model(md).Input.PeakTemp=get(hObject,'value');
if get(hObject,'value')==1
    set(handles.GUIHandles.TogglePeak,'Value',1);
    set(handles.GUIHandles.ToggleMean,'Value',0);
    handles.Model(md).Input.MeanTemp=0;
end
guidata(findobj('Tag','Spectral space'),handles);

function ToggleMean_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Spectral space'));
handles.Model(md).Input.MeanTemp=get(hObject,'value');
if get(hObject,'value')==1
    set(handles.GUIHandles.TogglePeak,'Value',0);
    set(handles.GUIHandles.ToggleMean,'Value',1);
    handles.Model(md).Input.PeakTemp=0;
end
guidata(findobj('Tag','Spectral space'),handles);

function ToggleCosine_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Spectral space'));
handles.Model(md).Input.CosineTemp=get(hObject,'value');
if get(hObject,'value')==1
    set(handles.GUIHandles.ToggleCosine,'Value',1);
    set(handles.GUIHandles.ToggleDegrees,'Value',0);
    handles.Model(md).Input.DegreesTemp=0;
end
guidata(findobj('Tag','Spectral space'),handles);

function ToggleDegrees_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Spectral space'));
handles.Model(md).Input.DegreesTemp=get(hObject,'value');
if get(hObject,'value')==1
    set(handles.GUIHandles.ToggleCosine,'Value',0);
    set(handles.GUIHandles.ToggleDegrees,'Value',1);
    handles.Model(md).Input.CosineTemp=0;
end
guidata(findobj('Tag','Spectral space'),handles);

function PushCloseWindow_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Spectral space'));
setHandles(handles);
close;

