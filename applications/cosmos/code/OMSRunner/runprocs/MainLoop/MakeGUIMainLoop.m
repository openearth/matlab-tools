function hm=MakeGUIMainLoop(hm)

%% Main Loop

uipanel('Title','Main Loop','Units','pixels','Position',[20 20 200 460]);

hm.PushStartMainLoop = uicontrol(gcf,'Style','pushbutton','Position',[140  30 70  25],'String','Start');
hm.PushStopMainLoop  = uicontrol(gcf,'Style','pushbutton','Position',[ 60  30 70  25],'String','Stop');

hm.TextCycle = uicontrol(gcf,'Style','text','Position',[30  426   70  25],'String','Cycle','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
hm.EditCycle = uicontrol(gcf,'Style','edit','Position',[105  430 105  25],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1]);
set(hm.EditCycle,'String',datestr(hm.Cycle,'yyyymmdd HHMMSS'));

hm.TextInterval = uicontrol(gcf,'Style','text','Position',[30  396  70  25],'String','Interval (h)','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
hm.EditInterval = uicontrol(gcf,'Style','edit','Position',[105  400 105  25],'String',num2str(hm.RunInterval),'HorizontalAlignment','right','BackgroundColor',[1 1 1]);

hm.TextRunTime = uicontrol(gcf,'Style','text','Position',[30  366  70  25],'String','Run Time (h)','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
hm.EditRunTime = uicontrol(gcf,'Style','edit','Position',[105  370 105  25],'String',num2str(hm.RunTime),'HorizontalAlignment','right','BackgroundColor',[1 1 1]);

hm.TextMode      = uicontrol(gcf,'Style','text','Position',[30  340  60  20],'String','Cycle Mode','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
hm.ToggleRunCont = uicontrol(gcf,'Style','radiobutton','Position',[90  340 105  25],'String','Continuous');
hm.ToggleRunOnce = uicontrol(gcf,'Style','radiobutton','Position',[170  340 47  25],'String','Once');
if strcmpi(hm.CycleMode,'continuous')
    set(hm.ToggleRunCont,'Value',1);
    set(hm.ToggleRunOnce,'Value',0);
else
    set(hm.ToggleRunCont,'Value',0);
    set(hm.ToggleRunOnce,'Value',1);
end


hm.ToggleGetMeteo = uicontrol(gcf,'Style','checkbox','Position',[30  300 180  25],'String','Get Meteo Data','BackgroundColor',[0.8 0.8 0.8]);
set(hm.ToggleGetMeteo,'Value',hm.GetMeteo);

hm.ToggleGetObservations = uicontrol(gcf,'Style','checkbox','Position',[30  275 180  25],'String','Get Observations','BackgroundColor',[0.8 0.8 0.8]);
set(hm.ToggleGetObservations,'Value',hm.GetObservations);

hm.ToggleGetOceanModelData = uicontrol(gcf,'Style','checkbox','Position',[30  250 180  25],'String','Get Ocean Model Data','BackgroundColor',[0.8 0.8 0.8]);
set(hm.ToggleGetOceanModelData,'Value',hm.GetOceanModel);

hm.TextMainLoopStatus = uicontrol(gcf,'Style','text','Position',[30  225  180  20],'String','Status : inactive','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);

set(hm.ToggleRunOnce,'CallBack',{@ToggleRunOnce_Callback});
set(hm.ToggleRunCont,'CallBack',{@ToggleRunCont_Callback});

set(hm.PushStartMainLoop,    'CallBack',{@PushStartMainLoop_Callback});
set(hm.PushStopMainLoop,     'CallBack',{@PushStopMainLoop_Callback});
set(hm.ToggleGetMeteo,       'CallBack',{@ToggleGetMeteo_Callback});
set(hm.ToggleGetObservations,'CallBack',{@ToggleGetObservations_Callback});
set(hm.ToggleGetOceanModelData ,'CallBack',{@ToggleGetOceanModelData_Callback});

set(hm.EditRunTime,          'CallBack',{@EditRunTime_Callback});
set(hm.EditInterval,         'CallBack',{@EditInterval_Callback});

set(hm.EditCycle,            'CallBack',{@EditCycle_Callback});

%%
function PushStartMainLoop_Callback(hObject,eventdata)

hm=guidata(findobj('Tag','OMSMain'));

StartMainLoop(hm);

%%
function PushStopMainLoop_Callback(hObject,eventdata)
t = timerfind('Tag', 'MainLoop');
delete(t);
t = timerfind('Tag', 'ModelLoop');
delete(t);
hm=guidata(findobj('Tag','OMSMain'));
hm.NCyc=0;
set(hm.TextMainLoopStatus,'String','Status : stopped');
set(hm.TextModelLoopStatus,'String','Status : inactive');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleRunCont_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
if get(hObject,'Value')==1
    set(hm.ToggleRunOnce,'Value',0);
    hm.CycleMode='continuous';
    guidata(findobj('Tag','OMSMain'),hm);
else
    set(hObject,'Value',0);
end

%%
function ToggleRunOnce_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
if get(hObject,'Value')==1
    set(hm.ToggleRunCont,'Value',0);
    hm.CycleMode='once';
    guidata(findobj('Tag','OMSMain'),hm);
else
    set(hObject,'Value',0);
end

%%
function ToggleGetObservations_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
ii=get(hObject,'Value');
hm.GetObservations=ii;
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleGetMeteo_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
ii=get(hObject,'Value');
hm.GetMeteo=ii;
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleGetOceanModelData_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
ii=get(hObject,'Value');
hm.GetOceanModel=ii;
guidata(findobj('Tag','OMSMain'),hm);

%%
function EditCycle_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
str=get(hObject,'String');
hm.Cycle=datenum(str,'yyyymmdd HHMMSS');
guidata(findobj('Tag','OMSMain'),hm);

%%
function EditRunTime_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
str=get(hObject,'String');
hm.RunTime=str2double(str);
guidata(findobj('Tag','OMSMain'),hm);

%%
function EditInterval_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
str=get(hObject,'String');
hm.RunInterval=str2double(str);
guidata(findobj('Tag','OMSMain'),hm);
