function ddb_Delft3DWAVE_numericalparameters(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dwave.numericalparameters');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectgrid'}
            selectGrid;
        case{'selectenclosure'}
            selectEnclosure;
        case{'generatelayers'}
            generateLayers;
        case{'editkmax'}
            editKMax;
        case{'changelayers'}
            changeLayers;
        case{'loadlayers'}
            loadLayers;
        case{'savelayers'}
            saveLayers;
    end
end


%{
ddb_refreshScreen('Numerical Parameters');
handles=getHandles;

hp = uipanel('Title','Geographical space','Units','pixels','Position',[20 20 250 150],'Tag','UIControl');

handles.GUIHandles.ToggleFirst       = uicontrol(gcf,'Style','radiobutton', 'String','First-order','Position',[30 100 230 15],'Tag','UIControl');
handles.GUIHandles.ToggleFirstExtra  = uicontrol(gcf,'Style','text', 'String','(SWAN 40.01/Second-order 40.11)','Position',[45 80 200 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleThird     = uicontrol(gcf,'Style','radiobutton', 'String','Third-order (not yet operational)','Position',[30 50 230 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleFirst,'value',handles.Model(md).Input.First);
set(handles.GUIHandles.ToggleThird,'value',handles.Model(md).Input.Third); 
set(handles.GUIHandles.ToggleThird,'enable','off'); 
set(handles.GUIHandles.ToggleFirst,  'CallBack',{@ToggleFirst_CallBack});
set(handles.GUIHandles.ToggleThird,'CallBack',{@ToggleThird_CallBack});

setHandles(handles);

hp = uipanel('Title','Spectral space','Units','pixels','Position',[280 20 250 150],'Tag','UIControl');

handles.GUIHandles.TextCDD       = uicontrol(gcf,'Style','text','String','Directional space (CDD) : ','Position',[290 120 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditCDD       = uicontrol(gcf,'Style','edit', 'Position',[420 120 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextCDDUnit   = uicontrol(gcf,'Style','text','String','[-] (0.0-1.0)','Position',[465 120 60 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditCDD,'string',handles.Model(md).Input.CDD);
set(handles.GUIHandles.EditCDD,     'CallBack',{@EditCDD_CallBack});

handles.GUIHandles.TextCSS       = uicontrol(gcf,'Style','text','String','Frequency space (CSS) : ','Position',[290 90 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditCSS       = uicontrol(gcf,'Style','edit', 'Position',[420 90 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextCSSUnit   = uicontrol(gcf,'Style','text','String','[-] (0.0-1.0)','Position',[465 90 60 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditCSS,'string',handles.Model(md).Input.CSS);
set(handles.GUIHandles.EditCSS,     'CallBack',{@EditCSS_CallBack});

handles.GUIHandles.TextScheme1   = uicontrol(gcf,'Style','text','String','CDD and CSS determine the numerical scheme ','Position',[290 60 230 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextScheme2   = uicontrol(gcf,'Style','text','String','0 = central, 1 = upwind ','Position',[290 40 230 15],'HorizontalAlignment','left','Tag','UIControl');

setHandles(handles);

hp = uipanel('Title','Accuracy criteria (to terminate the iterative computations)','Units','pixels','Position',[540 20 470 150],'Tag','UIControl');

handles.GUIHandles.Textchange1      = uicontrol(gcf,'Style','text','String','Relative change : ','Position',[550 120 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextHSTM01       = uicontrol(gcf,'Style','text','String','Hs-Tm01 :','Position',[550 100 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditHSTM01       = uicontrol(gcf,'Style','edit', 'Position',[610 100 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextHSTM01Unit   = uicontrol(gcf,'Style','text','String','[-]','Position',[660 100 60 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditHSTM01,'string',handles.Model(md).Input.HSTM01);
set(handles.GUIHandles.EditHSTM01,'CallBack',{@EditHSTM01_CallBack});

handles.GUIHandles.Textchange2  = uicontrol(gcf,'Style','text','String','Relative change w.r.t. mean value : ','Position',[550 70 200 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextHs       = uicontrol(gcf,'Style','text','String','Hs : ','Position',[550 50 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditHS       = uicontrol(gcf,'Style','edit', 'Position',[610 50 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextHSUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[660 50 60 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditHS,'string',handles.Model(md).Input.HSchange);
set(handles.GUIHandles.EditHS,'CallBack',{@EditHS_CallBack});
handles.GUIHandles.TextTM01      = uicontrol(gcf,'Style','text','String','Tm01 : ','Position',[550 30 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditTM01      = uicontrol(gcf,'Style','edit', 'Position',[610 30 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextTM01Unit  = uicontrol(gcf,'Style','text','String','[-]','Position',[660 30 60 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditTM01,'string',handles.Model(md).Input.TM01);
set(handles.GUIHandles.EditTM01,'CallBack',{@EditTM01_CallBack});

handles.GUIHandles.TextPercWet       = uicontrol(gcf,'Style','text','String','Percentage of wet grid points : ','Position',[750 120 200 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditPercWet       = uicontrol(gcf,'Style','edit', 'Position',[750 100 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextPercWetUnit   = uicontrol(gcf,'Style','text','String','[%] (0.0-1.0)','Position',[800 100 60 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditPercWet,'string',handles.Model(md).Input.PercWet);
set(handles.GUIHandles.EditPercWet,'CallBack',{@EditPercWet_CallBack});

handles.GUIHandles.TextMaxIter       = uicontrol(gcf,'Style','text','String','Maximum number of iterations : ','Position',[750 70 200 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditMaxIter       = uicontrol(gcf,'Style','edit', 'Position',[750 50 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditMaxIter,'string',handles.Model(md).Input.MaxIter);
set(handles.GUIHandles.EditMaxIter,'CallBack',{@EditMaxIter_CallBack});

setHandles(handles);

%%
function ToggleFirst_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.First=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleFirst,'Value',1);
    set(handles.GUIHandles.ToggleThird,'Value',0);  
    handles.Model(md).Input.Third=0;
else
    set(handles.GUIHandles.ToggleFirst,'Value',0);
    set(handles.GUIHandles.ToggleThird,'Value',1); 
    handles.Model(md).Input.Third=1;  
end
setHandles(handles);

function ToggleThird_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Third=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleFirst,'Value',0);
    set(handles.GUIHandles.ToggleThird,'Value',1);
    handles.Model(md).Input.First=0;
else
    set(handles.GUIHandles.ToggleFirst,'Value',1);
    set(handles.GUIHandles.ToggleThird,'Value',0);
    handles.Model(md).Input.Third=0; 
end
setHandles(handles);

function EditCDD_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.CDD=str2double(get(hObject,'string'));
setHandles(handles);

function EditCSS_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.CSS=str2double(get(hObject,'string'));
setHandles(handles);

function EditHSTM01_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.HSTM01=str2double(get(hObject,'string'));
setHandles(handles);

function EditHS_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.HSchange=str2double(get(hObject,'string'));
setHandles(handles);

function EditTM01_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.TM01=str2double(get(hObject,'string'));
setHandles(handles);

function EditPercWet_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.PercWet=str2double(get(hObject,'string'));
setHandles(handles);

function EditMaxIter_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.MaxIter=str2double(get(hObject,'string'));
setHandles(handles);

%}