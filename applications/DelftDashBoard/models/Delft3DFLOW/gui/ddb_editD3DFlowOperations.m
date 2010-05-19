function ddb_editD3DFlowOperations

ddb_refreshScreen('Discharges');

handles=getHandles;

ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

uipanel('Title','Discharges','Units','pixels','Position',[50 20 900 150],'Tag','UIControl');

handles.GUIHandles.PushOpenSrc = uicontrol(gcf,'Style','pushbutton','String','Open Source File','Position',[60 120 130 20],'Tag','UIControl');
handles.GUIHandles.TextSrcFile = uicontrol(gcf,'Style','text',      'String',['File : ' handles.Model(md).Input(ad).SrcFile],'Position',[200 117  200 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.PushSaveSrc = uicontrol(gcf,'Style','pushbutton','String','Save Source File','Position',[60  95 130 20],'Tag','UIControl');

set(handles.PushOpenSrc,   'Callback',{@PushOpenSrc_Callback});
set(handles.PushSaveSrc,   'Callback',{@PushSaveSrc_Callback});

if handles.Model(md).Input(ad).NrDischarges>0
    ddb_plotFlowAttributes(handles,'Discharge','activate',ad,handles.GUIData.ActiveDischarge);
end

%handles=Refresh(handles);    

SetUIBackgroundColors;

setHandles(handles);

%%
function PushOpenSrc_Callback(hObject,eventdata)
handles=getHandles;
if ~isempty(handles.Model(md).Input(ad).GrdFile)
    [filename, pathname, filterindex] = uigetfile('*.src', 'Select source file');
    if ~pathname==0
        handles.Model(md).Input(ad).SrcFile=filename;
        handles=ddb_readSrcFile(handles,ad);
        set(handles.TextSrcFile,'String',['File : ' handles.Model(md).Input(ad).SrcFile]);
        setHandles(handles);
%        PlotFlowDischarges(handles,ad);
    end
else
    GiveWarning('Warning','First load a grid file');
end

%%
function PushSaveSrc_Callback(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.src', 'Select Source File',handles.Model(md).Input(ad).SrcFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).SrcFile=filename;
    ddb_saveSrcFile(handles,ad);
    set(handles.TextSrcFile,'String',['File : ' filename]);
%    handles.GUIData.DeleteSelectedThinDam=0;
    setHandles(handles);
end
