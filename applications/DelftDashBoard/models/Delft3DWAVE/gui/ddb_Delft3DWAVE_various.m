function ddb_Delft3DWAVE_various(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dwave.physicalparameters.physicalparameterspanel.various');
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
ddb_refreshScreen('Physical Parameters','Various');
handles=getHandles;

hp = uipanel('Title','Processes activated','Units','pixels','Position',[40 40 470 90],'Tag','UIControl');

handles.GUIHandles.TextWind  = uicontrol(gcf,'Style','text','String','Wind growth : ','Position',[60 90 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleActi1       = uicontrol(gcf,'Style','radiobutton', 'String','activated','Position',[60 70 100 15],'Tag','UIControl');
handles.GUIHandles.ToggleDeActi1     = uicontrol(gcf,'Style','radiobutton', 'String','de-activated','Position',[60 50 100 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleActi1,'value',handles.Model(md).Input.Acti1);
set(handles.GUIHandles.ToggleDeActi1,'value',handles.Model(md).Input.DeActi1); 
set(handles.GUIHandles.ToggleActi1,  'CallBack',{@ToggleActi1_CallBack});
set(handles.GUIHandles.ToggleDeActi1,'CallBack',{@ToggleDeActi1_CallBack});

handles.GUIHandles.TextWhitecapping  = uicontrol(gcf,'Style','text','String','Whitecapping : ','Position',[200 90 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleActi2       = uicontrol(gcf,'Style','radiobutton', 'String','activated','Position',[200 70 100 15],'Tag','UIControl');
handles.GUIHandles.ToggleDeActi2     = uicontrol(gcf,'Style','radiobutton', 'String','de-activated','Position',[200 50 100 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleActi2,'value',handles.Model(md).Input.Acti2);
set(handles.GUIHandles.ToggleDeActi2,'value',handles.Model(md).Input.DeActi2); 
set(handles.GUIHandles.ToggleActi2,  'CallBack',{@ToggleActi2_CallBack});
set(handles.GUIHandles.ToggleDeActi2,'CallBack',{@ToggleDeActi2_CallBack});

handles.GUIHandles.TextQuadruplets  = uicontrol(gcf,'Style','text','String','Quadruplets : ','Position',[340 90 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleActi3       = uicontrol(gcf,'Style','radiobutton', 'String','activated','Position',[340 70 100 15],'Tag','UIControl');
handles.GUIHandles.ToggleDeActi3     = uicontrol(gcf,'Style','radiobutton', 'String','de-activated','Position',[340 50 100 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleActi3,'value',handles.Model(md).Input.Acti3);
set(handles.GUIHandles.ToggleDeActi3,'value',handles.Model(md).Input.DeActi3);
if handles.Model(md).Input.Acti3
    set(handles.GUIHandles.ToggleDeActi3,'enable','off');     
else
    set(handles.GUIHandles.ToggleActi3,'enable','off');    
end

setHandles(handles);

hp = uipanel('Title','Wave propagation in spectral space','Units','pixels','Position',[520 40 470 90],'Tag','UIControl');

handles.GUIHandles.TextRefraction  = uicontrol(gcf,'Style','text','String','Refraction : ','Position',[540 90 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleActi4       = uicontrol(gcf,'Style','radiobutton', 'String','activated','Position',[540 70 100 15],'Tag','UIControl');
handles.GUIHandles.ToggleDeActi4         = uicontrol(gcf,'Style','radiobutton', 'String','de-activated','Position',[540 50 100 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleActi4,'value',handles.Model(md).Input.Acti4);
set(handles.GUIHandles.ToggleDeActi4,'value',handles.Model(md).Input.DeActi4); 
set(handles.GUIHandles.ToggleActi4,  'CallBack',{@ToggleActi4_CallBack});
set(handles.GUIHandles.ToggleDeActi4,'CallBack',{@ToggleDeActi4_CallBack});

handles.GUIHandles.TextFrequency  = uicontrol(gcf,'Style','text','String','Frequency shift : ','Position',[700 90 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleActi5       = uicontrol(gcf,'Style','radiobutton', 'String','activated','Position',[700 70 100 15],'Tag','UIControl');
handles.GUIHandles.ToggleDeActi5         = uicontrol(gcf,'Style','radiobutton', 'String','de-activated','Position',[700 50 100 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleActi5,'value',handles.Model(md).Input.Acti5);
set(handles.GUIHandles.ToggleDeActi5,'value',handles.Model(md).Input.DeActi5); 
set(handles.GUIHandles.ToggleActi5,  'CallBack',{@ToggleActi5_CallBack});
set(handles.GUIHandles.ToggleDeActi5,'CallBack',{@ToggleDeActi5_CallBack});

setHandles(handles);

%%

function ToggleActi1_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Acti1=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleActi1,'Value',1);
    set(handles.GUIHandles.ToggleDeActi1,'Value',0);
    set(handles.GUIHandles.ToggleActi3,'Value',1);
    set(handles.GUIHandles.ToggleActi3,'enable','on');     
    set(handles.GUIHandles.ToggleDeActi3,'Value',0);
    set(handles.GUIHandles.ToggleDeActi3,'enable','off');    
    handles.Model(md).Input.DeActi1=0;
    handles.Model(md).Input.Acti3=1;
    handles.Model(md).Input.DeActi3=0;
else
    set(handles.GUIHandles.ToggleActi1,'Value',0);
    set(handles.GUIHandles.ToggleDeActi1,'Value',1);
    set(handles.GUIHandles.ToggleActi3,'Value',0);
    set(handles.GUIHandles.ToggleActi3,'enable','off');    
    set(handles.GUIHandles.ToggleDeActi3,'Value',1);
    set(handles.GUIHandles.ToggleDeActi3,'enable','on');    
    handles.Model(md).Input.DeActi1=1;
    handles.Model(md).Input.Acti3=0;
    handles.Model(md).Input.DeActi3=1;    
end
setHandles(handles);

function ToggleDeActi1_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.DeActi1=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleActi1,'Value',0);
    set(handles.GUIHandles.ToggleDeActi1,'Value',1);
    set(handles.GUIHandles.ToggleActi3,'Value',0);
    set(handles.GUIHandles.ToggleActi3,'enable','off');     
    set(handles.GUIHandles.ToggleDeActi3,'Value',1);
    set(handles.GUIHandles.ToggleDeActi3,'enable','on');
    handles.Model(md).Input.Acti1=0;
    handles.Model(md).Input.Acti3=0;
    handles.Model(md).Input.DeActi3=1;
else
    set(handles.GUIHandles.ToggleActi1,'Value',1);
    set(handles.GUIHandles.ToggleDeActi1,'Value',0);
    set(handles.GUIHandles.ToggleActi3,'Value',1);
    set(handles.GUIHandles.ToggleActi3,'enable','on');    
    set(handles.GUIHandles.ToggleDeActi3,'Value',0);
    set(handles.GUIHandles.ToggleDeActi3,'enable','off');    
    handles.Model(md).Input.DeActi1=0;
    handles.Model(md).Input.Acti3=1;
    handles.Model(md).Input.DeActi3=0;    
end
setHandles(handles);

function ToggleActi2_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Acti2=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleActi2,'Value',1);
    set(handles.GUIHandles.ToggleDeActi2,'Value',0);
    handles.Model(md).Input.DeActi2=0;
end
setHandles(handles);

function ToggleDeActi2_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.DeActi2=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleActi2,'Value',0);
    set(handles.GUIHandles.ToggleDeActi2,'Value',1);
    handles.Model(md).Input.Acti2=0;
end
setHandles(handles);

function ToggleActi4_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Acti4=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleActi4,'Value',1);
    set(handles.GUIHandles.ToggleDeActi4,'Value',0);
    handles.Model(md).Input.DeActi4=0;
end
setHandles(handles);

function ToggleDeActi4_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.DeActi4=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleActi4,'Value',0);
    set(handles.GUIHandles.ToggleDeActi4,'Value',1);
    handles.Model(md).Input.Acti4=0;
end
setHandles(handles);

function ToggleActi5_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Acti5=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleActi5,'Value',1);
    set(handles.GUIHandles.ToggleDeActi5,'Value',0);
    handles.Model(md).Input.DeActi5=0;
end
setHandles(handles);

function ToggleDeActi5_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.DeActi5=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleActi5,'Value',0);
    set(handles.GUIHandles.ToggleDeActi5,'Value',1);
    handles.Model(md).Input.Acti5=0;
end
setHandles(handles);
%}
