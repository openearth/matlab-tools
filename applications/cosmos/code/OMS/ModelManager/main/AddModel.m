function AddModel


fig0=gcf;
fig=MakeNewWindow('Add Model',[210 170],'modal');

bckcol=get(gcf,'Color');

handles.TextMDF  = uicontrol(gcf,'Style','text','Position',[30 130 150 30],'String','','HorizontalAlignment','left','BackgroundColor',bckcol,'Tag','UIControl');
handles.TextName = uicontrol(gcf,'Style','text','Position',[10 66  45 20],'String','Name','HorizontalAlignment','right','BackgroundColor',bckcol,'Tag','UIControl');
handles.EditName = uicontrol(gcf,'Style','edit','Position',[60 70 120 20],'String','','HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.SelectMDF  = uicontrol(gcf,'Style','pushbutton','Position',[ 30 105 150 20],'String','Select File','Tag','UIControl');
handles.PushOK     = uicontrol(gcf,'Style','pushbutton','Position',[110  30  70 20],'String','OK','Tag','UIControl');
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','Position',[ 30  30  70 20],'String','Cancel','Tag','UIControl');

set(handles.PushOK     ,'CallBack',{@PushOK_CallBack});
set(handles.PushCancel ,'CallBack',{@PushCancel_CallBack});
set(handles.SelectMDF  ,'CallBack',{@SelectMDF_CallBack});

handles.MDFFile='';

guidata(gcf,handles);

%%
function PushOK_CallBack(hObject,eventdata)
handles=guidata(gcf);
name=get(handles.EditName,'String');
if isempty(handles.MDFFile)
    GiveWarning('warning','First select mdf file')
elseif isempty(deblank(name))
    GiveWarning('warning','First give a model name')
else
    hm=guidata(findobj('Tag','MainWindow'));
    hm.NrModels=hm.NrModels+1;
    i=hm.NrModels;
    hm=InitializeModel(hm,i);
    hm.Models(i).Name=name;
    k=hm.ActiveContinent;
    hm.Models(i).Continent=hm.ContinentAbbrs{k};
    hm.ModelNames{i}=name;
    hm=DetermineModelsInContinent(hm);
    guidata(findobj('Tag','MainWindow'),hm);
    close(gcf);
    RefreshScreen;
end

%%
function PushCancel_CallBack(hObject,eventdata)
close(gcf);

%%
function SelectMDF_CallBack(hObject,eventdata)
handles=guidata(gcf);
[filename, pathname, filterindex] = uigetfile('*.mdf', 'Select mdf file');
if pathname~=0
    handles.MDFFile=filename;
    handles.MDFPath=pathname;
    set(handles.TextMDF,'String',[pathname filename]);
    guidata(gcf,handles);
end






