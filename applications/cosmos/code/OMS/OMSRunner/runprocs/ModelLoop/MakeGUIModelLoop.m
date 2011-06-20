function hm=MakeGUIModelLoop(hm)

%% Model Loop

uipanel('Title','Model Loop','Units','pixels','Position',[230 20 500 460]);

hm.ToggleRunSimulation = uicontrol(gcf,'Style','checkbox','Position',[240  180 120  25],'String','Run Simulation','backgroundColor',[0.8 0.8 0.8]);
set(hm.ToggleRunSimulation,'Value',hm.RunSimulation);

hm.ToggleExtractData = uicontrol(gcf,'Style','checkbox','Position',[240  160 120  25],'String','Extract Data','backgroundColor',[0.8 0.8 0.8]);
set(hm.ToggleExtractData,'Value',hm.ExtractData);

hm.ToggleDetermineHazards = uicontrol(gcf,'Style','checkbox','Position',[240  140 120  25],'String','Determine Hazards','backgroundColor',[0.8 0.8 0.8]);
set(hm.ToggleDetermineHazards,'Value',hm.DetermineHazards);

hm.ToggleRunPost = uicontrol(gcf,'Style','checkbox','Position',[240  120 120  25],'String','Run Post-Processing','backgroundColor',[0.8 0.8 0.8]);
set(hm.ToggleRunPost,'Value',hm.RunPost);

hm.ToggleMakeWebsite = uicontrol(gcf,'Style','checkbox','Position',[240 100 120  25],'String','Make Website','backgroundColor',[0.8 0.8 0.8]);
set(hm.ToggleMakeWebsite,'Value',hm.MakeWebsite);

hm.ToggleUploadFTP = uicontrol(gcf,'Style','checkbox','Position',[240  80 120  25],'String','Upload FTP','backgroundColor',[0.8 0.8 0.8]);
set(hm.ToggleUploadFTP,'Value',hm.UploadFTP);

hm.ToggleArchiveInput = uicontrol(gcf,'Style','checkbox','Position',[240  60 120  25],'String','Archive Input','backgroundColor',[0.8 0.8 0.8]);
set(hm.ToggleArchiveInput,'Value',hm.ArchiveInput);

hm.PushStartModelLoop = uicontrol(gcf,'Style','pushbutton','Position',[650  30 70  25],'String','Start','enable','off');
hm.PushStopModelLoop  = uicontrol(gcf,'Style','pushbutton','Position',[570  30 70  25],'String','Stop','enable','off');

hm.TextModelLoopStatus = uicontrol(gcf,'Style','text','Position',[240  30  300  20],'String','Status : inactive','HorizontalAlignment','left','backgroundColor',[0.8 0.8 0.8]);

set(hm.PushStartModelLoop,  'Callback',{@PushStartModelLoop_Callback});
set(hm.PushStopModelLoop,   'Callback',{@PushStopModelLoop_Callback});

set(hm.ToggleRunSimulation,  'Callback',{@ToggleRunSimulation_Callback});
set(hm.ToggleExtractData,    'Callback',{@ToggleExtractData_Callback});
set(hm.ToggleDetermineHazards,    'Callback',{@ToggleDetermineHazards_Callback});
set(hm.ToggleRunPost,        'Callback',{@ToggleRunPost_Callback});
set(hm.ToggleMakeWebsite,    'Callback',{@ToggleMakeWebsite_Callback});
set(hm.ToggleUploadFTP,      'Callback',{@ToggleUploadFTP_Callback});
set(hm.ToggleArchiveInput,   'Callback',{@ToggleArchiveInput_Callback});

guidata(hm.MainWindow,hm);

%%
function PushStartModelLoop_Callback(hObject,eventdata)

hm=guidata(findobj('Tag','OMSMain'));

StartModelLoop(hm);

%%
function PushStopModelLoop_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
t = timerfind('Tag', 'ModelLoop');
delete(t);
set(hm.TextModelLoopStatus,'String','Status : inactive');drawnow;

%%
function ToggleRunSimulation_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.RunSimulation=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleExtractData_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.ExtractData=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleDetermineHazards_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.DetermineHazards=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleRunPost_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.RunPost=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleMakeWebsite_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.MakeWebsite=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleUploadFTP_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.UploadFTP=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleArchiveInput_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.ArchiveInput=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);
