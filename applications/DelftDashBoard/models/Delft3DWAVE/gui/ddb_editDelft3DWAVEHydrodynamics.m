function ddb_editDelft3DWAVEHydrodynamics

ddb_refreshScreen('Hydrodynamics');
handles=getHandles;

uipanel('Title','Hydrodynamics','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.GUIHandles.Text = uicontrol(gcf,'Style','text','String','Select hydrodynamics results from FLOW','Position',[40 135  250 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.ToggleBathymetry  = uicontrol(gcf,'Style','checkbox', 'String','Bathymetry','Position',[40 120  250 15],'Tag','UIControl');
handles.GUIHandles.ToggleWaterLevel  = uicontrol(gcf,'Style','checkbox', 'String','Water level','Position',[40 100  250 15],'Tag','UIControl');
handles.GUIHandles.ToggleCurrent     = uicontrol(gcf,'Style','checkbox', 'String','Current','Position',[40 80  250 15],'Tag','UIControl');
handles.GUIHandles.ToggleWind        = uicontrol(gcf,'Style','checkbox', 'String','Wind','Position',[40 60  250 15],'Tag','UIControl');
handles.GUIHandles.PushSelectMDFfile     = uicontrol(gcf,'Style','pushbutton', 'String','Select FLOW File','Position',[40 30 100 20],'Enable','off','Tag','UIControl');
handles.GUIHandles.TextSelectMDFfile     = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input.MDFFile],'Position',[150 25 600 20],'HorizontalAlignment','left','Enable','off','Tag','UIControl');

set(handles.GUIHandles.ToggleBathymetry,  'Callback',{@ToggleBathymetry_Callback});
set(handles.GUIHandles.ToggleWaterLevel,  'Callback',{@ToggleWaterLevel_Callback});
set(handles.GUIHandles.ToggleCurrent,     'Callback',{@ToggleCurrent_Callback});
set(handles.GUIHandles.ToggleWind,        'Callback',{@ToggleWind_Callback});
set(handles.GUIHandles.PushSelectMDFfile, 'Callback',{@PushSelectMDFfile_Callback});

SetUIBackgroundColors;

setHandles(handles);

handles=Refresh(handles);

%%
function ToggleBathymetry_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.FlowBedLevel=get(hObject,'Value');
setHandles(handles);
handles=Refresh(handles);

%%
function ToggleWaterLevel_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.FlowWaterLevel=get(hObject,'Value');
setHandles(handles);
handles=Refresh(handles);

%%
function ToggleCurrent_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.FlowVelocity=get(hObject,'Value');
setHandles(handles);
handles=Refresh(handles);

%%
function ToggleWind_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.FlowWind=get(hObject,'Value');
setHandles(handles);
handles=Refresh(handles);

%%
function PushSelectMDFfile_Callback(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input.MDFFile=filename;
    MDF=ddb_readMDFText(filename);
    ItDate=datenum(MDF.Itdate,'yyyy-mm-dd');
    ComStartTime=ItDate+MDF.Flpp(1)/1440;
    ComInterval=MDF.Flpp(2)/1440;
    ComStopTime=ItDate+MDF.Flpp(3)/1440;
    handles.Model(md).Input.ItDate=ItDate;
    handles.Model(md).Input.AvailableFlowTimes=ComStartTime:ComInterval:ComStopTime;
    set(handles.GUIHandles.TextSelectMDFfile,'enable','on','String',['File : ' handles.Model(md).Input.MDFFile]);
    setHandles(handles);
end

%%
function handles=Refresh(handles)
handles=getHandles;
set(handles.GUIHandles.PushSelectMDFfile,'Enable','off');
if handles.Model(md).Input.FlowBedLevel
    set(handles.GUIHandles.ToggleBathymetry,'Value',1);
    set(handles.GUIHandles.PushSelectMDFfile,'Enable','on');
    set(handles.GUIHandles.TextSelectMDFfile,'Enable','on');
end
if handles.Model(md).Input.FlowWaterLevel
    set(handles.GUIHandles.ToggleWaterLevel,'Value',1);
    set(handles.GUIHandles.PushSelectMDFfile,'Enable','on');
    set(handles.GUIHandles.TextSelectMDFfile,'Enable','on');    
end
if handles.Model(md).Input.FlowVelocity
    set(handles.GUIHandles.ToggleCurrent,'Value',1);
    set(handles.GUIHandles.PushSelectMDFfile,'Enable','on');
    set(handles.GUIHandles.TextSelectMDFfile,'Enable','on');    
end
if handles.Model(md).Input.FlowWind
    set(handles.GUIHandles.ToggleWind,'Value',1);
    set(handles.GUIHandles.PushSelectMDFfile,'Enable','on');
    set(handles.GUIHandles.TextSelectMDFfile,'Enable','on');    
end
if size(get(handles.GUIHandles.PushSelectMDFfile,'Enable'),2)==3
    handles.Model(md).Input.MDFFile='';
    handles.Model(md).Input.ItDate='';
    handles.Model(md).Input.AvailableFlowTimes='';
    handles.Model(md).Input.Timepoints='';
    set(handles.GUIHandles.TextSelectMDFfile,'String',['File : ' handles.Model(md).Input.MDFFile]);
end
setHandles(handles);


