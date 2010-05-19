function ddb_dDToolbox

handles=getHandles;

tb=strmatch('DD',{handles.Toolbox(:).Name},'exact');
ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

h=findall(gca,'Tag','TemporaryDDGrid');
if ~isempty(h)
    set(h,'Visible','on');
end
h=findall(gca,'Tag','DDCornerPoint');
if ~isempty(h)
    set(h,'Visible','on');
end

hp = uipanel('Title','Domain Decomposition','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

hp = uipanel('Title','','Units','pixels','Position',[30 30 360 130],'Tag','UIControl');
for i=1:handles.GUIData.NrFlowDomains
    str{i}=handles.Model(handles.ActiveModel.Nr).Input(i).Runid;
end
handles.SelectFirstDomain=uicontrol(gcf,'Style','popupmenu','String',str,'Position',[140 125 80 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.SelectFirstDomain,'Value',handles.ActiveDomain);
handles.TextFirstDomain=uicontrol(gcf,'Style','text','String','First Domain','Position',[35 121 100 20],'HorizontalAlignment','right','Tag','UIControl');

handles.EditSecondRunid=uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Input.NewRunid,'Position',[140 100  80 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextSecondRunid=uicontrol(gcf,'Style','text','String','Runid New Domain','Position',[35 96 100 20],'HorizontalAlignment','right','Tag','UIControl');

handles.EditMRefinement=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.MRefinement),'Position',[140 65  80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextMRefinement=uicontrol(gcf,'Style','text','String','M Refinement','Position',[35 61 100 20],'HorizontalAlignment','right','Tag','UIControl');
handles.EditNRefinement=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.NRefinement),'Position',[140 40  80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextNRefinement=uicontrol(gcf,'Style','text','String','N Refinement','Position',[35 36 100 20],'HorizontalAlignment','right','Tag','UIControl');

handles.EditM1    = uicontrol(gcf,'Style','edit','Position',[250  65  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditM2    = uicontrol(gcf,'Style','edit','Position',[330  65  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditN1    = uicontrol(gcf,'Style','edit','Position',[250  40  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditN2    = uicontrol(gcf,'Style','edit','Position',[330  40  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.TextM1    = uicontrol(gcf,'Style','text','String','M1',      'Position',[225  61 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextM2    = uicontrol(gcf,'Style','text','String','M2',      'Position',[305  61 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextN1    = uicontrol(gcf,'Style','text','String','N1',      'Position',[225  36 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextN2    = uicontrol(gcf,'Style','text','String','N2',      'Position',[305  36 20 20],'HorizontalAlignment','right','Tag','UIControl');


handles.PushSelectCornerPoints=uicontrol(gcf,'Style','pushbutton','String','Select Corner Points','Position',[250 125 130 20],'Tag','UIControl');
handles.PushGenerateDomain    =uicontrol(gcf,'Style','pushbutton','String','Generate New Domain','Position', [410 125 130 20],'Tag','UIControl');

set(handles.PushSelectCornerPoints,'CallBack',{@PushSelectCornerPoints_CallBack});
set(handles.PushGenerateDomain,    'CallBack',{@PushGenerateDomain_CallBack});
set(handles.EditMRefinement,    'CallBack',{@EditMRefinement_CallBack});
set(handles.EditNRefinement,    'CallBack',{@EditNRefinement_CallBack});
set(handles.EditM1,     'CallBack',{@EditM1_CallBack});
set(handles.EditN1,     'CallBack',{@EditN1_CallBack});
set(handles.EditM2,     'CallBack',{@EditM2_CallBack});
set(handles.EditN2,     'CallBack',{@EditN2_CallBack});
set(handles.EditSecondRunid,'CallBack',{@EditSecondRunid_CallBack});

RefreshDD(handles);

SetUIBackgroundColors;

setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditSecondRunid_CallBack(hObject,eventdata)
handles=getHandles;
handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.NewRunid=get(hObject,'String');
setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditMRefinement_CallBack(hObject,eventdata)
handles=getHandles;
handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.MRefinement=str2num(get(hObject,'String'));
RefreshDD(handles)
setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditNRefinement_CallBack(hObject,eventdata)
handles=getHandles;
handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.NRefinement=str2num(get(hObject,'String'));
RefreshDD(handles)
setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditM1_CallBack(hObject,eventdata)
handles=getHandles;
ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(handles.ActiveModel.Nr).Input(handles.ActiveDomain).GridX);
if ii<=sz(1)
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointM=ii;
else
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointM=sz(1);
end    
RefreshDD(handles)
setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditM2_CallBack(hObject,eventdata)
handles=getHandles;
ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(handles.ActiveModel.Nr).Input(handles.ActiveDomain).GridX);
if ii<=sz(1)
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointM=ii;
else
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointM=sz(1);
end    
RefreshDD(handles)
setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditN1_CallBack(hObject,eventdata)
handles=getHandles;
ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(handles.ActiveModel.Nr).Input(handles.ActiveDomain).GridX);
if ii<=sz(2)
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointN=ii;
else
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointN=sz(2);
end    
RefreshDD(handles)
setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditN2_CallBack(hObject,eventdata)
handles=getHandles;
ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(handles.ActiveModel.Nr).Input(handles.ActiveDomain).GridX);
if ii<=sz(2)
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointN=ii;
else
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointN=sz(2);
end    
RefreshDD(handles)
setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PushSelectCornerPoints_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
xg=handles.Model(handles.ActiveModel.Nr).Input(handles.ActiveDomain).GridX;
yg=handles.Model(handles.ActiveModel.Nr).Input(handles.ActiveDomain).GridY;
set(gcf, 'windowbuttondownfcn',   {@ClickPoint,@FirstCornerPoint,'cornerpoint',xg,yg});
setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PushGenerateDomain_CallBack(hObject,eventdata)

ddb_zoomOff;

handles=getHandles;
m1=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointM;
n1=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointN;
m2=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointM;
n2=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointN;
mmin=min(m1,m2);mmax=max(m1,m2);
nmin=min(n1,n2);nmax=max(n1,n2);

for i=1:handles.GUIData.NrFlowDomains
    str{i}=handles.Model(handles.ActiveModel.Nr).Input(i).Runid;
end
ii=strmatch(lower(handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.NewRunid),lower(str),'exact');
if ~isempty(ii)
    GiveWarning('Warning',['A domain with runid "' handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.NewRunid '" already exists!']);
elseif mmax>mmin && nmax>nmin

    handles=MakeDDGUIData.NrFlowDomains+1,handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.NewRunid);

    handles.GUIData.NrFlowDomains+1;
    h=findall(gca,'Tag','DDCornerPoint');
    if ~isempty(h)
        delete(h);
    end
    h=findall(gca,'Tag','TemporaryDDGrid');
    if ~isempty(h)
        delete(h);
    end
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointM=NaN;
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointM=NaN;
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointN=NaN;
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointN=NaN;
    setHandles(handles);

    ddb_plotFlowAttributes(handles.ActiveDomain);
    ddb_plotFlowAttributes(handles.GUIData.NrFlowDomains);

    handles=getHandles;

    RefreshDomains(handles);
else
    GiveWarning('Warning','First select corner points!'); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function FirstCornerPoint(m,n)
handles=getHandles;
id=handles.ActiveDomain;
handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointM=m;
handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointN=n;
handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointM=NaN;
handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointN=NaN;
xg=handles.Model(handles.ActiveModel.Nr).Input(id).GridX;
yg=handles.Model(handles.ActiveModel.Nr).Input(id).GridY;
if ~isnan(m)
    set(gcf, 'windowbuttondownfcn',   {@ClickPoint,@SecondCornerPoint,'cornerpoint',xg,yg});
end
RefreshDD(handles);
setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SecondCornerPoint(m,n)
handles=getHandles;
if ~isnan(m)
    id=handles.ActiveDomain;
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointM=m;
    handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointN=n;
    RefreshDD(handles);
    setHandles(handles);
    set(gcf, 'windowbuttondownfcn',[]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RefreshDD(handles)

id=handles.ActiveDomain;

if isfield(handles.Model(handles.ActiveModel.Nr).Input(id),'GridX')
    
    xg=handles.Model(handles.ActiveModel.Nr).Input(id).GridX;
    yg=handles.Model(handles.ActiveModel.Nr).Input(id).GridY;

    m1=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointM;
    n1=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointN;
    m2=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointM;
    n2=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointN;
    mm1=min(m1,m2);mm2=max(m1,m2);
    nn1=min(n1,n2);nn2=max(n1,n2);

    h=findall(gca,'Tag','DDCornerPoint');
    if ~isempty(h)
        delete(h);
    end
    h=findall(gca,'Tag','TemporaryDDGrid');
    if ~isempty(h)
        delete(h);
    end

    if ~isnan(m1) && ~isnan(n1)
        set(handles.EditM1,'String',num2str(m1));
        set(handles.EditN1,'String',num2str(n1));
        plt=plot3(xg(m1,n1),yg(m1,n1),9000,'go');
        set(plt,'MarkerEdgeColor','k','MarkerFaceColor','y');
        set(plt,'Tag','DDCornerPoint');
    else
        set(handles.EditM1,'String','');
        set(handles.EditN1,'String','');
    end
    if ~isnan(m2) && ~isnan(n2)
        set(handles.EditM2,'String',num2str(m2));
        set(handles.EditN2,'String',num2str(n2));
        plt=plot3(xg(m2,n2),yg(m2,n2),9000,'go');
        set(plt,'MarkerEdgeColor','k','MarkerFaceColor','y');
        set(plt,'Tag','DDCornerPoint');
    else
        set(handles.EditM2,'String','');
        set(handles.EditN2,'String','');
    end
    set(handles.EditMRefinement,'String',num2str(handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.MRefinement));
    set(handles.EditNRefinement,'String',num2str(handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.NRefinement));

    if mm2>mm1 && nn2>nn1
        PlotTemporaryDDGrid(handles);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlotTemporaryDDGrid(handles)
xg=handles.Model(handles.ActiveModel.Nr).Input(handles.ActiveDomain).GridX;
yg=handles.Model(handles.ActiveModel.Nr).Input(handles.ActiveDomain).GridY;
m1=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointM;
n1=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.FirstCornerPointN;
m2=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointM;
n2=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.SecondCornerPointN;
mm1=min(m1,m2);mm2=max(m1,m2);
nn1=min(n1,n2);nn2=max(n1,n2);
xg=xg(mm1:mm2,nn1:nn2);
yg=yg(mm1:mm2,nn1:nn2);
mref=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.MRefinement;
nref=handles.Toolbox(strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact')).Input.NRefinement;
[x2,y2]=ddb_refineD3DGrid(xg,yg,mref,nref);
z2=zeros(size(x2))+9000;
grd=mesh(x2,y2,z2);
set(grd,'FaceColor','none','EdgeColor','r','Tag','TemporaryDDGrid');

