function ddb_editD3DFlowWind

ddb_refreshScreen('Phys. Parameters','Wind');
handles=getHandles;

ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

handles.GUIHandles.ToggleSpaceVarying = uicontrol(gcf,'Style','radiobutton','String','Space varying','Position',[60 130 250 20],'Tag','UIControl');
handles.GUIHandles.ToggleUniform  = uicontrol(gcf,'Style','radiobutton','String','Uniform','Position', [60 105 250 20],'Tag','UIControl');

handles.GUIHandles.ToggleLinear = uicontrol(gcf,'Style','radiobutton','String','Linear','Position',[150 30 50 20],'Tag','UIControl');
handles.GUIHandles.ToggleBlock  = uicontrol(gcf,'Style','radiobutton','String','Block','Position', [220 30 50 20],'Tag','UIControl');
handles.GUIHandles.TextInterp   = uicontrol(gcf,'Style','text','String','Interpolation',       'Position',[60 30 60 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.PushOpenWind   = uicontrol(gcf,'Style','pushbutton','String','Open',   'Position',[60 80 60 20],'Tag','UIControl');
handles.GUIHandles.PushSaveWind   = uicontrol(gcf,'Style','pushbutton','String','Save',   'Position',[150 80 60 20],'Tag','UIControl');
handles.GUIHandles.TextWndFile       = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).WndFile],'Position',[60 55 170 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.ToggleSpaceVarying, 'CallBack',{@ToggleSpaceVarying_CallBack});
set(handles.GUIHandles.ToggleUniform,  'CallBack',{@ToggleUniform_CallBack});
set(handles.GUIHandles.ToggleLinear, 'CallBack',{@ToggleLinear_CallBack});
set(handles.GUIHandles.ToggleBlock,  'CallBack',{@ToggleBlock_CallBack});
set(handles.GUIHandles.PushOpenWind, 'CallBack',{@PushOpenWind_CallBack});
set(handles.GUIHandles.PushSaveWind, 'CallBack',{@PushSaveWind_CallBack});

SetUIBackgroundColors;

setHandles(handles);

RefreshWind(handles);
%%
function ToggleLinear_CallBack(hObject,eventdata)
handles=getHandles;
k=get(hObject,'Value');
if k==0
    set(hObject,'Value',1);
else
    set(handles.GUIHandles.ToggleBlock,'Value',0);
    handles.Model(md).Input(ad).WndInt='Y';
end
setHandles(handles);
RefreshWind(handles);
%%
function ToggleBlock_CallBack(hObject,eventdata)
handles=getHandles;
k=get(hObject,'Value');
if k==0
    set(hObject,'Value',1);
else
    set(handles.GUIHandles.ToggleLinear,'Value',0);
    handles.Model(md).Input(ad).WndInt='N';
end
setHandles(handles);
RefreshWind(handles);
%%
function ToggleSpaceVarying_CallBack(hObject,eventdata)
handles=getHandles;
k=get(hObject,'Value');
if k==0
    set(hObject,'Value',1);
else
    set(handles.GUIHandles.ToggleUniform,'Value',0);
    handles.Model(md).Input(ad).WindType='SpaceVarying';
end
setHandles(handles);
RefreshWind(handles);
%%
function ToggleUniform_CallBack(hObject,eventdata)
handles=getHandles;
k=get(hObject,'Value');
if k==0
    set(hObject,'Value',1);
else
    set(handles.GUIHandles.ToggleSpaceVarying,'Value',0);
    handles.Model(md).Input(ad).WindType='Uniform';
end
setHandles(handles);
RefreshWind(handles);
%%
function AdjustData_CallBack(hObject,eventdata)
handles=getHandles;
data=table2(findobj('Tag','MainWindow'),'table','getdata');
handles.Model(handles.ActiveModel.Nr).Input(ad).WindData=cell2mat(data);
setHandles(handles);
%%
function PushSaveWind_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.wnd', 'Select Wind File',handles.Model(md).Input(ad).WndFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).WndFile=filename;
    ddb_saveWndFile(handles,ad);
    set(handles.GUIHandles.TextWndFile,'String',['File : ' filename]);
    setHandles(handles);
end
%%
function PushOpenWind_CallBack(hObject,eventdata)
handles=getHandles;
id=ad;
[filename, pathname, filterindex] = uigetfile('*.wnd', 'Select Wind File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(id).WndFile=filename;
    if strcmp(get(hObject,'String'),'Open')
        handles=ddb_readWndFile(handles,id);
    end
    RefreshWind(handles);
    set(handles.GUIHandles.TextWndFile,'String',['File : ' filename]);
    setHandles(handles);
end

%%
function RefreshWind(handles)
id=ad;

windType = handles.Model(md).Input(id).WindType;
Interpolation = handles.Model(md).Input(id).WndInt;
data=num2cell(handles.Model(md).Input(id).WindData);

try
    table2(findobj('Tag','MainWindow'),'table','delete');
    delete(handles.GUIHandles.TextSpeed);
    delete(handles.GUIHandles.TextDirection);
end

switch windType
    case 'Uniform'
        set(handles.GUIHandles.ToggleUniform,'Value',1);
        set(handles.GUIHandles.ToggleSpaceVarying,'Value',0);
        set(handles.GUIHandles.PushOpenWind,'String','Open');
        set(handles.GUIHandles.PushSaveWind,'Enable','On');        
        
        cltp={'edittime','editreal','editreal'};
        callbacks{1}=[];
        callbacks{2}=[];
        callbacks{3}=[];
        wdt=[110 80 80];
        handles.GUIHandles.TextSpeed = uicontrol(gcf,'Style','text','String','Speed [m/s]','Position',[410 130 80 15],'HorizontalAlignment','center','Tag','UIControl');
        handles.GUIHandles.TextDirection = uicontrol(gcf,'Style','text','String','Direction [deg]','Position',[490 130 80 15],'HorizontalAlignment','center','Tag','UIControl');
        table2(findobj('Tag','MainWindow'),'table','create','position',[300 30],'nrrows',5,'columntypes',cltp,'width',wdt,'data',data,'callbacks',{@AdjustData_CallBack,@AdjustData_CallBack,@AdjustData_CallBack},'includebuttons');
    otherwise
        set(handles.GUIHandles.ToggleUniform,'Value',0);
        set(handles.GUIHandles.ToggleSpaceVarying,'Value',1);
        set(handles.GUIHandles.PushOpenWind,'String','Select File');
        set(handles.GUIHandles.PushSaveWind,'Enable','Off');
end

switch Interpolation
    case 'Y'
        set(handles.GUIHandles.ToggleBlock,'Value',0);
        set(handles.GUIHandles.ToggleLinear,'Value',1);
    case 'N'
        set(handles.GUIHandles.ToggleBlock,'Value',1);
        set(handles.GUIHandles.ToggleLinear,'Value',0);        
end
setHandles(handles);
