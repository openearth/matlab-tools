function EditSwanOutputParameters

ddb_refreshScreen('Output Parameters');
handles=getHandles;

hp = uipanel('Title','Output Parameters','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.GUIHandles.TextTestOutput       = uicontrol(gcf,'Style','text','String','Level of ddb_test output : ','Position',[30 130 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditTestOutput       = uicontrol(gcf,'Style','edit', 'Position',[140 130 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditTestOutput,'string',handles.Model(md).Input.TestOutput);
set(handles.GUIHandles.EditTestOutput,       'CallBack',{@EditTestOutput_CallBack});

handles.GUIHandles.TextDebug       = uicontrol(gcf,'Style','text','String','Debug level : ','Position',[30 100 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditDebug       = uicontrol(gcf,'Style','edit', 'Position',[140 100 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditDebug,'string',handles.Model(md).Input.Debug);
set(handles.GUIHandles.EditDebug,       'CallBack',{@EditDebug_CallBack});

handles.GUIHandles.TextMode     = uicontrol(gcf,'Style','text','String','Computational mode :','Position',[220 130 120 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditMode     = uicontrol(gcf,'Style','popupmenu','String',' ','Position',[250 110 120 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditMode,'Max',1);
set(handles.GUIHandles.EditMode,'String',handles.Model(md).Input.Mode);
set(handles.GUIHandles.EditMode,'Value',handles.Model(md).Input.ModeIval);
set(handles.GUIHandles.EditMode,'CallBack',{@EditMode_CallBack});

handles.GUIHandles.TextCouplingInterval   = uicontrol(gcf,'Style','text','String','Coupling interval ','Position',[220 80 70 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextCouplingInterval   = uicontrol(gcf,'Style','text','String','10 ','Position',[290 80 70 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextCouplingInterval   = uicontrol(gcf,'Style','text','String','[m] ','Position',[360 80 70 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextTimeStepOutput       = uicontrol(gcf,'Style','text','String','Time step : ','Position',[220 50 70 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditTimeStepOutput       = uicontrol(gcf,'Style','edit', 'Position',[290 50 70 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextTimeStepOutputUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[360 50 70 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditTimeStepOutput,'string',handles.Model(md).Input.TimeStepOutput);
if handles.Model(md).Input.ModeIval==1
    set(handles.GUIHandles.EditTimeStepOutput,'enable','off');
else
    set(handles.GUIHandles.EditTimeStepOutput,'enable','on');
end
set(handles.GUIHandles.EditTimeStepOutput,       'CallBack',{@EditTimeStepOutput_CallBack});

handles.GUIHandles.ToggleHotstart      = uicontrol(gcf,'Style','checkbox','String','Write and use hot start file','Position',[420 130 180 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleHotstart,'Value',handles.Model(md).Input.Hotstart);
set(handles.GUIHandles.ToggleHotstart,  'CallBack',{@ToggleHotstart_CallBack});

handles.GUIHandles.ToggleVerify      = uicontrol(gcf,'Style','checkbox','String','Only verify input files','Position',[420 100 180 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleVerify,'Value',handles.Model(md).Input.Verify);
set(handles.GUIHandles.ToggleVerify,  'CallBack',{@ToggleVerify_CallBack});

handles.GUIHandles.ToggleOutputFlowGrid      = uicontrol(gcf,'Style','checkbox','String','Output for FLOW grid','Position',[420 70 180 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleOutputFlowGrid,'Value',handles.Model(md).Input.OutputFlowGrid);
set(handles.GUIHandles.ToggleOutputFlowGrid,  'CallBack',{@ToggleOutputFlowGrid_CallBack});

handles.GUIHandles.PushSelectOutputGrid     = uicontrol(gcf,'Style','pushbutton', 'String','Select grid File','Position',[560 70 90 20],'Tag','UIControl');
handles.GUIHandles.EditFileFlowGrid      = uicontrol(gcf,'Style','text','String',['Grid file : ' handles.Model(md).Input.OutputFlowGridFile],'Position',[420 40 350 15],'HorizontalAlignment','left','Tag','UIControl');
if handles.Model(md).Input.OutputFlowGrid==0
    set(handles.GUIHandles.PushSelectOutputGrid,'enable','off');
    set(handles.GUIHandles.EditFileFlowGrid,'enable','off');
    set(handles.GUIHandles.EditFileFlowGrid,'String','Grid file : ','HorizontalAlignment','left');
else
    set(handles.GUIHandles.EditFileFlowGrid,'enable','on');
    set(handles.GUIHandles.PushSelectOutputGrid,'enable','on');
    set(handles.GUIHandles.EditFileFlowGrid,'String',['Grid file : ' handles.Model(md).Input.OutputFlowGridFile],'HorizontalAlignment','left');
end
set(handles.GUIHandles.PushSelectOutputGrid,  'CallBack',{@PushSelectOutputGrid_CallBack});

handles.GUIHandles.TextComputationalgrids   = uicontrol(gcf,'Style','text','String','Outputs for computational grids : ','Position',[700 145 200 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextInterval       = uicontrol(gcf,'Style','text','String','Interval : ','Position',[700 115 70 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditInterval       = uicontrol(gcf,'Style','edit', 'Position',[750 115 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextIntervalUnit   = uicontrol(gcf,'Style','text','String','[min]','Position',[810 115 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditInterval,'string',handles.Model(md).Input.Interval);
set(handles.GUIHandles.EditInterval,       'CallBack',{@EditInterval_CallBack});

handles.GUIHandles.ToggleCompgrid1   = uicontrol(gcf,'Style','checkbox','String',handles.Model(md).Input.ComputationalGrids{1},'Position',[700 85 90 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleCompgrid1,'Value',handles.Model(md).Input.Compgrid1);
set(handles.GUIHandles.ToggleCompgrid1,  'CallBack',{@ToggleCompgrid1_CallBack});
    
if size(handles.Model(md).Input.ComputationalGrids,2)>=2
    handles.GUIHandles.ToggleCompgrid2   = uicontrol(gcf,'Style','checkbox','String',handles.Model(md).Input.ComputationalGrids{2},'Position',[800 85 90 15],'Tag','UIControl');
    set(handles.GUIHandles.ToggleCompgrid2,'Value',handles.Model(md).Input.Compgrid2);
    set(handles.GUIHandles.ToggleCompgrid2,  'CallBack',{@ToggleCompgrid2_CallBack});
end

if size(handles.Model(md).Input.ComputationalGrids,2)>=3
    handles.GUIHandles.ToggleCompgrid3   = uicontrol(gcf,'Style','checkbox','String',handles.Model(md).Input.ComputationalGrids{3},'Position',[900 85 90 15],'Tag','UIControl');
    set(handles.GUIHandles.ToggleCompgrid3,'Value',handles.Model(md).Input.Compgrid3);
    set(handles.GUIHandles.ToggleCompgrid3,  'CallBack',{@ToggleCompgrid3_CallBack});
end

handles.GUIHandles.ToggleOutputSpecific      = uicontrol(gcf,'Style','checkbox','String','Output for specific','Position',[700 50 180 15],'Tag','UIControl');
handles.GUIHandles.TextOutputSpecific      = uicontrol(gcf,'Style','text','String','locations','Position',[720 32 180 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.ToggleOutputSpecific,'Value',handles.Model(md).Input.OutputSpecific);
set(handles.GUIHandles.ToggleOutputSpecific,  'CallBack',{@ToggleOutputSpecific_CallBack});

handles.GUIHandles.ToggleTable      = uicontrol(gcf,'Style','checkbox','String','table','Position',[820 66 80 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleTable,'Value',handles.Model(md).Input.Table);
set(handles.GUIHandles.ToggleTable,  'CallBack',{@ToggleTable_CallBack});

handles.GUIHandles.Toggle1Dspectra      = uicontrol(gcf,'Style','checkbox','String','1D spectra','Position',[820 50 80 15],'Tag','UIControl');
set(handles.GUIHandles.Toggle1Dspectra,'Value',handles.Model(md).Input.oneDspectra);
set(handles.GUIHandles.Toggle1Dspectra,  'CallBack',{@Toggle1Dspectra_CallBack});

handles.GUIHandles.Toggle2Dspectra      = uicontrol(gcf,'Style','checkbox','String','2D spectra','Position',[820 32 80 15],'Tag','UIControl');
set(handles.GUIHandles.Toggle2Dspectra,'Value',handles.Model(md).Input.twoDspectra);
set(handles.GUIHandles.Toggle2Dspectra,  'CallBack',{@Toggle2Dspectra_CallBack});

handles.GUIHandles.Editlocations     = uicontrol(gcf,'Style','pushbutton', 'String','Edit locations','Position',[900 50 90 20],'Tag','UIControl');
set(handles.GUIHandles.Editlocations,  'CallBack',{@Editlocations_CallBack});
    
if handles.Model(md).Input.OutputSpecific==0
    set(handles.GUIHandles.ToggleTable,'Enable','off');
    set(handles.GUIHandles.Toggle1Dspectra,'Enable','off');
    set(handles.GUIHandles.Toggle2Dspectra,'Enable','off');
    set(handles.GUIHandles.Editlocations,'Enable','off');    
end 

setHandles(handles);


%%

function EditTestOutput_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.TestOutput=str2double(get(hObject,'string'));
setHandles(handles);

function EditDebug_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Debug=str2double(get(hObject,'string'));
setHandles(handles);

function EditMode_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.ModeIval=get(hObject,'value');
set(handles.GUIHandles.EditMode,'Value',handles.Model(md).Input.ModeIval);
setHandles(handles);

function EditTimeStepOutput_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.TimeStepOutput=str2double(get(hObject,'string'));
setHandles(handles);

function EditInterval_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Interval=str2double(get(hObject,'string'));
setHandles(handles);

function ToggleHotstart_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Hotstart=get(hObject,'Value');
setHandles(handles);

function ToggleVerify_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Verify=get(hObject,'Value');
setHandles(handles);

function ToggleOutputFlowGrid_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.OutputFlowGrid=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.EditFileFlowGrid,'enable','on');
    set(handles.GUIHandles.PushSelectOutputGrid,'enable','on');
    set(handles.GUIHandles.EditFileFlowGrid,'String',['Grid file : ' handles.Model(md).Input.OutputFlowGridFile],'HorizontalAlignment','left');
else
    set(handles.GUIHandles.EditFileFlowGrid,'enable','off');
    set(handles.GUIHandles.PushSelectOutputGrid,'enable','off');
    set(handles.GUIHandles.EditFileFlowGrid,'String','Grid file : ','HorizontalAlignment','left');
end
setHandles(handles);

function PushSelectOutputGrid_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.grd', 'Select grid File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input.OutputFlowGridFile=filename;
end
set(handles.GUIHandles.EditFileFlowGrid,'String',['Grid file : ' handles.Model(md).Input.OutputFlowGridFile],'HorizontalAlignment','left');
setHandles(handles);

function ToggleCompgrid1_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Compgrid1=get(hObject,'Value');
setHandles(handles);

function ToggleCompgrid2_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Compgrid2=get(hObject,'Value');
setHandles(handles);

function ToggleCompgrid3_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Compgrid3=get(hObject,'Value');
setHandles(handles);

function ToggleOutputSpecific_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.OutputSpecific=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleTable,'Enable','on');
    set(handles.GUIHandles.Toggle1Dspectra,'Enable','on');
    set(handles.GUIHandles.Toggle2Dspectra,'Enable','on');
    set(handles.GUIHandles.Editlocations,'Enable','on');
else
    set(handles.GUIHandles.ToggleTable,'Enable','off');
    set(handles.GUIHandles.Toggle1Dspectra,'Enable','off');
    set(handles.GUIHandles.Toggle2Dspectra,'Enable','off');
    set(handles.GUIHandles.Editlocations,'Enable','off');      
end
setHandles(handles);

function ToggleTable_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.table=get(hObject,'Value');
setHandles(handles);

function Toggle1Dspectra_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.oneDspectra=get(hObject,'Value');
setHandles(handles);

function Toggle2Dspectra_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.twoDspectra=get(hObject,'Value');
setHandles(handles);

function Editlocations_CallBack(hObject,eventdata)
handles=getHandles;
ddb_editDelft3DWAVELocations
setHandles(handles);






