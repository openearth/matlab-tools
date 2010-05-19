function ddb_editD3DFlowRoughness

ddb_refreshScreen('Phys. Parameters','Roughness');
handles=getHandles;

hp = uipanel('Title','Bottom Roughness','Units','pixels','Position',[60 30 305 125],'Tag','UIControl');
str={'Chezy','Manning','White-Colebrook','Z0'};
handles.GUIHandles.SelectType = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[205 115 150 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextType   = uicontrol(gcf,'Style','text', 'String','Roughness Formula','Position',[70 111 100 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleUniform  = uicontrol(gcf,'Style','radiobutton', 'String','Uniform','Position',[70 90 60 20],'Tag','UIControl');
handles.GUIHandles.EditU  = uicontrol(gcf,'Style','edit','String','65.0','Position',[205 90 40 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditV  = uicontrol(gcf,'Style','edit','String','65.0','Position',[270 90 40 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextU  = uicontrol(gcf,'Style','text','String','U','Position',[180 86 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextV  = uicontrol(gcf,'Style','text','String','V','Position',[245 86 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.ToggleFile  = uicontrol(gcf,'Style','radiobutton', 'String','File','Position',[70 65 60 20],'Tag','UIControl');
handles.GUIHandles.TextFile    = uicontrol(gcf,'Style','text', 'String','','Position',[205 61 150 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.PushSelectFile    = uicontrol(gcf,'Style','pushbutton', 'String','Select File','Position',[110 65 80 20],'Tag','UIControl');
str={'Fredsoe','Myrhaug et al.','Grant et al.','Huynh-Thanh et al.','Davis et al.','Bijker','Christoffersen & Jonsson','O''Connor & Yoo','Van Rijn 2004'};
handles.GUIHandles.SelectWaveStress = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[205 40 150 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextWaveStress  = uicontrol(gcf,'Style','text','String','Wave Stress Formulation','Position',[70 36 130 20],'HorizontalAlignment','left','Tag','UIControl');

hp = uipanel('Title','Wall Roughness','Units','pixels','Position',[385 30 210 125],'Tag','UIControl');
str={'Free','Partial','No'};
handles.GUIHandles.SelectWallRoughnessType = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[515 115 70 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSlipConditions   = uicontrol(gcf,'Style','text', 'String','Slip Condition','Position',[395 111 70 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditRoughnessLength  = uicontrol(gcf,'Style','edit','String','','Position',[515 85 70 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextRoughnessLength  = uicontrol(gcf,'Style','text','String','Roughness Length (m)','Position',[395 81 115 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIData.RoughnessTypes={'C','M','W','Z'};
handles.GUIData.RouWav={'FR84','MS90','GM79','HT91','DS88','BK67','CJ85','OY88','VR04'};

set(handles.GUIHandles.SelectType,'CallBack',{@SelectType_CallBack});
set(handles.GUIHandles.EditU,'CallBack',{@EditU_CallBack});
set(handles.GUIHandles.EditV,'CallBack',{@EditV_CallBack});
set(handles.GUIHandles.ToggleUniform,'CallBack',{@ToggleUniform_CallBack});
set(handles.GUIHandles.ToggleFile,'CallBack',{@ToggleFile_CallBack});
set(handles.GUIHandles.SelectWaveStress,'CallBack',{@SelectWaveStress_CallBack});
set(handles.GUIHandles.PushSelectFile,'CallBack',{@PushSelectFile_CallBack});
set(handles.GUIHandles.SelectWallRoughnessType,'CallBack',{@SelectWallRoughnessType_CallBack});
set(handles.GUIHandles.EditRoughnessLength,'CallBack',{@EditRoughnessLength_CallBack});

SetUIBackgroundColors;

setHandles(handles);

RefreshRoughness(handles);

%%
function SelectType_CallBack(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
handles.Model(md).Input(ad).RoughnessType=handles.GUIData.RoughnessTypes{ii};
setHandles(handles);

%%
function EditU_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).URoughness=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditV_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).VRoughness=str2num(get(hObject,'String'));
setHandles(handles);

%%
function ToggleFile_CallBack(hObject,eventdata)
handles=getHandles;
if get(hObject,'Value')==1
    handles.Model(md).Input(ad).UniformRoughness=0;
end
RefreshRoughness(handles);
setHandles(handles);

%%
function ToggleUniform_CallBack(hObject,eventdata)
handles=getHandles;
if get(hObject,'Value')==1
    handles.Model(md).Input(ad).UniformRoughness=1;
end
RefreshRoughness(handles);
setHandles(handles);

%%
function PushSelectFile_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.rgh', 'Select Roughness File');
if ~pathname==0
    curdir=[lower(cd) '\'];
    if ~strcmp(lower(curdir),lower(pathname))
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).RghFile=filename;
    RefreshRoughness(handles);
end
setHandles(handles);

%%
function SelectWaveStress_CallBack(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
handles.Model(md).Input(ad).RouWav=handles.GUIData.RouWav{ii};
setHandles(handles);


%%
function SelectWallRoughnessType_CallBack(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
handles.Model(md).Input(ad).Irov=ii-1;
RefreshRoughness(handles);
setHandles(handles);

%%
function EditRoughnessLength_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Z0v=str2num(get(hObject,'String'));
setHandles(handles);


%%
function RefreshRoughness(handles);

i=strmatch(lower(handles.Model(md).Input(ad).RoughnessType),lower(handles.GUIData.RoughnessTypes),'exact');
set(handles.GUIHandles.SelectType,'Value',i);

set(handles.GUIHandles.TextFile,'String',['File : ' handles.Model(md).Input(ad).RghFile]);
if handles.Model(md).Input(ad).UniformRoughness==0
    set(handles.GUIHandles.EditU,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.EditV,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.TextU,'Enable','off');
    set(handles.GUIHandles.TextV,'Enable','off');
    set(handles.GUIHandles.ToggleUniform,'Value',0);
    set(handles.GUIHandles.ToggleFile,'Value',1);
    set(handles.GUIHandles.PushSelectFile,'Enable','on');
    set(handles.GUIHandles.TextFile,'Enable','on');
else
    set(handles.GUIHandles.EditU,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditV,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextU,'Enable','on');
    set(handles.GUIHandles.TextV,'Enable','on');
    set(handles.GUIHandles.EditU,'String',num2str(handles.Model(md).Input(ad).URoughness));
    set(handles.GUIHandles.EditV,'String',num2str(handles.Model(md).Input(ad).VRoughness));
    set(handles.GUIHandles.ToggleUniform,'Value',1);
    set(handles.GUIHandles.ToggleFile,'Value',0);
    set(handles.GUIHandles.PushSelectFile,'Enable','off');
    set(handles.GUIHandles.TextFile,'Enable','off');
end

i=strmatch(lower(handles.Model(md).Input(ad).RouWav),lower(handles.GUIData.RouWav),'exact');
set(handles.GUIHandles.SelectWaveStress,'Value',i);
if handles.Model(md).Input(ad).Waves==0
    set(handles.GUIHandles.SelectWaveStress,'Visible','off');
    set(handles.GUIHandles.TextWaveStress,'Visible','off');
end

set(handles.GUIHandles.SelectWallRoughnessType,'Value',handles.Model(md).Input(ad).Irov+1);
set(handles.GUIHandles.EditRoughnessLength,'String',num2str(handles.Model(md).Input(ad).Z0v));
if handles.Model(md).Input(ad).Irov==1
    set(handles.GUIHandles.EditRoughnessLength,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextRoughnessLength,'Enable','on');
else
    set(handles.GUIHandles.EditRoughnessLength,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.TextRoughnessLength,'Enable','off');
end

    
