function ddb_nestingToolbox1

ddb_refreshScreen('Toolbox','Nesting - Step 1');

handles=getHandles;

tb=strmatch('Nesting',{handles.Toolbox(:).Name},'exact');
ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

str={'Delft3D-FLOW','X-Beach'};

uipanel('Title','Overall Model','Units','pixels','Position',[60 30 205 125],'Tag','UIControl');

handles.TextOverallModel    = uicontrol(gcf,'Style','text',     'Position',[ 70 111  80 20],'String','Model','HorizontalAlignment','right','Tag','UIControl');
handles.TextOverallDomain   = uicontrol(gcf,'Style','text',     'Position',[ 70  86  80 20],'String','Domain','HorizontalAlignment','right','Tag','UIControl');
handles.TextOverallObs      = uicontrol(gcf,'Style','text',     'Position',[ 70  61  80 20],'String','Observation File','HorizontalAlignment','right','Tag','UIControl');
handles.SelectOverallModel  = uicontrol(gcf,'Style','popupmenu','Position',[155 115 100 20],'String',str,'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.SelectOverallDomain = uicontrol(gcf,'Style','popupmenu','Position',[155  90 100 20],'String','shite','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditOverallObs      = uicontrol(gcf,'Style','edit',     'Position',[155  65 100 20],'String','','BackgroundColor',[1 1 1],'HorizontalAlignment','left','Tag','UIControl');

set(handles.EditOverallObs,'Visible','off');
set(handles.TextOverallObs,'Visible','off');

uipanel('Title','Detailed Model','Units','pixels','Position',[280 30 165 125],'Tag','UIControl');

handles.TextDetailedModel    = uicontrol(gcf,'Style','text','Position',[290 111  40 20],'String','Model','HorizontalAlignment','right','Tag','UIControl');
handles.TextDetailedDomain   = uicontrol(gcf,'Style','text','Position',[290  86  40 20],'String','Domain','HorizontalAlignment','right','Tag','UIControl');
handles.SelectDetailedModel  = uicontrol(gcf,'Style','popupmenu','Position',[335 115 100 20],'String',str,'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.SelectDetailedDomain = uicontrol(gcf,'Style','popupmenu','Position',[335 90 100 20],'String','shite','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.EditAdminFile     = uicontrol(gcf,'Style','edit','Position',[740 60 100 20],'String',handles.Toolbox(tb).Input.AdminFile,'BackgroundColor',[1 1 1],'HorizontalAlignment','left','Tag','UIControl');
handles.PushStartNesting1 = uicontrol(gcf,'Style','pushbutton','Position',[740 30 100 20],'String','Start Nesting 1','Tag','UIControl');

clear str;
for id=1:handles.GUIData.NrFlowDomains
    str{id}=handles.Model(md).Input(id).Runid;
end
set(handles.SelectOverallDomain,'String',str);
set(handles.SelectDetailedDomain,'String',str);

handles=RefreshAll(handles);

set(handles.SelectOverallModel,   'CallBack',{@SelectOverallModel_CallBack});
set(handles.SelectDetailedModel,  'CallBack',{@SelectDetailedModel_CallBack});
set(handles.SelectOverallDomain,  'CallBack',{@SelectOverallDomain_CallBack});
set(handles.SelectDetailedDomain, 'CallBack',{@SelectDetailedDomain_CallBack});
set(handles.EditOverallObs,       'CallBack',{@EditOverallObs_CallBack});
set(handles.EditAdminFile,        'CallBack',{@EditAdminFile_CallBack});
set(handles.PushStartNesting1,    'CallBack',{@PushStartNesting1_CallBack});

SetUIBackgroundColors;

setHandles(handles);

%%
function SelectOverallModel_CallBack(hObject,eventdata)
handles=getHandles;
setHandles(handles);

%%
function SelectDetailedModel_CallBack(hObject,eventdata)
handles=getHandles;
setHandles(handles);

%%
function SelectOverallDomain_CallBack(hObject,eventdata)
handles=getHandles;
handles=RefreshAll(handles);
setHandles(handles);

%%
function SelectDetailedDomain_CallBack(hObject,eventdata)
handles=getHandles;
%handles=RefreshAll(handles);
setHandles(handles);

%%
function EditAdminFile_CallBack(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Input.AdminFile=get(hObject,'String');
setHandles(handles);

%%
function PushStartNesting1_CallBack(hObject,eventdata)
handles=getHandles;

id1=get(handles.SelectOverallDomain,'Value');
id2=get(handles.SelectDetailedDomain,'Value');

fid=fopen('nesting1.tmp','w');

fprintf(fid,'%s\n',[handles.Model(md).Input(id1).GrdFile]);
fprintf(fid,'%s\n',[handles.Model(md).Input(id1).EncFile]);
fprintf(fid,'%s\n',[handles.Model(md).Input(id2).GrdFile]);
fprintf(fid,'%s\n',[handles.Model(md).Input(id2).EncFile]);
fprintf(fid,'%s\n',[handles.Model(md).Input(id2).BndFile]);
fprintf(fid,'%s\n',[handles.Toolbox(tb).Input.AdminFile]);
fprintf(fid,'%s\n','nesttmp.obs');

fclose(fid);

d3dpath=[getenv('D3D_HOME') '\' getenv('ARCH') '\'];

evaltxt=['! ' d3dpath '\flow\bin\nesthd1 < nesting1.tmp'];
eval(evaltxt);

m=[];
n=[];
name=[];
[name,m,n] = textread('nesttmp.obs','%21c%f%f');
nrnewobs=length(m);
nrobs0=handles.Model(md).Input(id1).NrObservationPoints;
handles.Model(md).Input(id1).ObservationPoints.M(nrobs0+1:nrobs0+nrnewobs)=m;
handles.Model(md).Input(id1).ObservationPoints.N(nrobs0+1:nrobs0+nrnewobs)=n;
for i=1:length(m)
    handles.Model(md).Input(id1).ObservationPoints.Name{i+nrobs0}=deblank(name(i,:));
end
handles.Model(md).Input(id1).NrObservationPoints=nrobs0+nrnewobs;
setHandles(handles);
PlotObservationPoints(handles,'all',id1,'inactive');

%%

function handles=RefreshAll(handles)

id1=get(handles.SelectOverallDomain,'Value');
id2=get(handles.SelectDetailedDomain,'Value');
set(handles.EditOverallObs,'String',handles.Model(md).Input(id1).ObsFile);


