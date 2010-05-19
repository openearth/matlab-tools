function ddb_dDToolbox

handles=getHandles;

ddb_plotDD(handles,'activate');

h=findall(gca,'Tag','TemporaryDDGrid');
if ~isempty(h)
    set(h,'Visible','on');
end
h=findall(gca,'Tag','DDCornerPoint');
if ~isempty(h)
    set(h,'Visible','on');
end

uipanel('Title','Domain Decomposition','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

uipanel('Title','New Domain','Units','pixels','Position',[30 30 360 135],'Tag','UIControl');
for i=1:handles.GUIData.NrFlowDomains
    str{i}=handles.Model(md).Input(i).Runid;
end
handles.GUIHandles.SelectFirstDomain=uicontrol(gcf,'Style','popupmenu','String',str,'Position',[140 125 80 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.SelectFirstDomain,'Value',handles.ActiveDomain);
handles.GUIHandles.TextFirstDomain=uicontrol(gcf,'Style','text','String','First Domain','Position',[35 121 100 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.EditSecondRunid=uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Input.NewRunid,'Position',[140 100  80 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSecondRunid=uicontrol(gcf,'Style','text','String','Runid New Domain','Position',[35 96 100 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.EditMRefinement=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.MRefinement),'Position',[140 65  80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextMRefinement=uicontrol(gcf,'Style','text','String','M Refinement','Position',[35 61 100 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditNRefinement=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.NRefinement),'Position',[140 40  80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextNRefinement=uicontrol(gcf,'Style','text','String','N Refinement','Position',[35 36 100 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.EditM1    = uicontrol(gcf,'Style','edit','Position',[250  65  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditM2    = uicontrol(gcf,'Style','edit','Position',[330  65  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditN1    = uicontrol(gcf,'Style','edit','Position',[250  40  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditN2    = uicontrol(gcf,'Style','edit','Position',[330  40  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextM1    = uicontrol(gcf,'Style','text','String','M1',      'Position',[225  61 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextM2    = uicontrol(gcf,'Style','text','String','M2',      'Position',[305  61 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN1    = uicontrol(gcf,'Style','text','String','N1',      'Position',[225  36 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN2    = uicontrol(gcf,'Style','text','String','N2',      'Position',[305  36 20 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.PushSelectCornerPoints=uicontrol(gcf,'Style','pushbutton','String','Select Corner Points','Position',[250 125 130 20],'Tag','UIControl');
handles.GUIHandles.PushGenerateDomain    =uicontrol(gcf,'Style','pushbutton','String','Generate New Domain','Position', [250 100 130 20],'Tag','UIControl');


uipanel('Title','Make DD Boundaries','Units','pixels','Position',[400 30 360 135],'Tag','UIControl');

handles.GUIHandles.SelectFirstDomain2=uicontrol(gcf,'Style','popupmenu','String',str,'Position',[490 125 80 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.SelectFirstDomain2,'Value',handles.ActiveDomain);
handles.GUIHandles.TextFirstDomain2=uicontrol(gcf,'Style','text','String','First Domain','Position',[405 121 80 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.SelectSecondDomain=uicontrol(gcf,'Style','popupmenu','String',str,'Position',[490 100 80 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.SelectSecondDomain,'Value',handles.ActiveDomain);
handles.GUIHandles.TextSecondDomain=uicontrol(gcf,'Style','text','String','Second Domain','Position',[405 96 80 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.PushGenerateDDBoundaries = uicontrol(gcf,'Style','pushbutton','String','Generate DD Boundaries','Position', [590 125 135 20],'Tag','UIControl');

set(handles.GUIHandles.PushSelectCornerPoints,  'CallBack',{@PushSelectCornerPoints_CallBack});
set(handles.GUIHandles.PushGenerateDomain,      'CallBack',{@PushGenerateDomain_CallBack});
set(handles.GUIHandles.PushGenerateDDBoundaries,'CallBack',{@PushGenerateDDBoundaries_CallBack});
set(handles.GUIHandles.EditMRefinement,         'CallBack',{@EditMRefinement_CallBack});
set(handles.GUIHandles.EditNRefinement,         'CallBack',{@EditNRefinement_CallBack});
set(handles.GUIHandles.EditM1,                  'CallBack',{@EditM1_CallBack});
set(handles.GUIHandles.EditN1,                  'CallBack',{@EditN1_CallBack});
set(handles.GUIHandles.EditM2,                  'CallBack',{@EditM2_CallBack});
set(handles.GUIHandles.EditN2,                  'CallBack',{@EditN2_CallBack});
set(handles.GUIHandles.EditSecondRunid,         'CallBack',{@EditSecondRunid_CallBack});

RefreshDD(handles);

SetUIBackgroundColors;

setHandles(handles);

%%
function EditSecondRunid_CallBack(hObject,eventdata)

handles=getHandles;

handles.Toolbox(tb).Input.NewRunid=get(hObject,'String');
setHandles(handles);

%%
function EditMRefinement_CallBack(hObject,eventdata)

handles=getHandles;

handles.Toolbox(tb).Input.MRefinement=str2double(get(hObject,'String'));
RefreshDD(handles)
setHandles(handles);

%%
function EditNRefinement_CallBack(hObject,eventdata)

handles=getHandles;

handles.Toolbox(tb).Input.NRefinement=str2num(get(hObject,'String'));
RefreshDD(handles)
setHandles(handles);

%%
function EditM1_CallBack(hObject,eventdata)

handles=getHandles;

ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(md).Input(handles.ActiveDomain).GridX);
if ii<=sz(1)
    handles.Toolbox(tb).Input.FirstCornerPointM=ii;
else
    handles.Toolbox(tb).Input.FirstCornerPointM=sz(1);
end
RefreshDD(handles)
setHandles(handles);

%%
function EditM2_CallBack(hObject,eventdata)

handles=getHandles;

ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(md).Input(handles.ActiveDomain).GridX);
if ii<=sz(1)
    handles.Toolbox(tb).Input.SecondCornerPointM=ii;
else
    handles.Toolbox(tb).Input.SecondCornerPointM=sz(1);
end
RefreshDD(handles)
setHandles(handles);

%%
function EditN1_CallBack(hObject,eventdata)

handles=getHandles;

ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(md).Input(handles.ActiveDomain).GridX);
if ii<=sz(2)
    handles.Toolbox(tb).Input.FirstCornerPointN=ii;
else
    handles.Toolbox(tb).Input.FirstCornerPointN=sz(2);
end
RefreshDD(handles)
setHandles(handles);

%%
function EditN2_CallBack(hObject,eventdata)

handles=getHandles;

ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(md).Input(handles.ActiveDomain).GridX);
if ii<=sz(2)
    handles.Toolbox(tb).Input.SecondCornerPointN=ii;
else
    handles.Toolbox(tb).Input.SecondCornerPointN=sz(2);
end
RefreshDD(handles)
setHandles(handles);

%%
function PushSelectCornerPoints_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
xg=handles.Model(md).Input(handles.ActiveDomain).GridX;
yg=handles.Model(md).Input(handles.ActiveDomain).GridY;
ClickPoint('cornerpoint','Grid',xg,yg,'Callback',@FirstCornerPoint,'single');
setHandles(handles);

%%
function PushGenerateDomain_CallBack(hObject,eventdata)

ddb_zoomOff;

handles=getHandles;


m1=handles.Toolbox(tb).Input.FirstCornerPointM;
n1=handles.Toolbox(tb).Input.FirstCornerPointN;
m2=handles.Toolbox(tb).Input.SecondCornerPointM;
n2=handles.Toolbox(tb).Input.SecondCornerPointN;
mmin=min(m1,m2);mmax=max(m1,m2);
nmin=min(n1,n2);nmax=max(n1,n2);

for i=1:handles.GUIData.NrFlowDomains
    str{i}=handles.Model(md).Input(i).Runid;
end
ii=strmatch(lower(handles.Toolbox(tb).Input.NewRunid),lower(str),'exact');
if ~isempty(ii)
    GiveWarning('Warning',['A domain with runid "' handles.Toolbox(tb).Input.NewRunid '" already exists!']);
elseif mmax>mmin && nmax>nmin

    [handles,cancel]=ddb_makeDDModel(handles,handles.ActiveDomain,handles.GUIData.NrFlowDomains+1,handles.Toolbox(tb).Input.NewRunid);

    if ~cancel
        handles.GUIData.NrFlowDomains=handles.GUIData.NrFlowDomains+1;
        h=findall(gca,'Tag','DDCornerPoint');
        if ~isempty(h)
            delete(h);
        end
        h=findall(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            delete(h);
        end
        handles.Toolbox(tb).Input.FirstCornerPointM=NaN;
        handles.Toolbox(tb).Input.SecondCornerPointM=NaN;
        handles.Toolbox(tb).Input.FirstCornerPointN=NaN;
        handles.Toolbox(tb).Input.SecondCornerPointN=NaN;

        setHandles(handles);

        ddb_plotDelft3DFLOW(handles,'plot');
        for i=1:handles.GUIData.NrFlowDomains
            if i==handles.ActiveDomain
                ddb_plotDelft3DFLOW(handles,'activate',i);
            else
                ddb_plotDelft3DFLOW(handles,'deactivate',i);
            end
        end

        handles=getHandles;

        ddb_refreshFlowDomains(handles);
    end

    for i=1:handles.GUIData.NrFlowDomains
        ddb_saveMDF(handles,i);
    end

else
    GiveWarning('Warning','First select corner points!');
end

%%
function PushGenerateDDBoundaries_CallBack(hObject,eventdata)

handles=getHandles;

id1=get(handles.GUIHandles.SelectFirstDomain2,'Value');
id2=get(handles.GUIHandles.SelectSecondDomain,'Value');
runid1=handles.Model(md).Input(id1).Runid;
runid2=handles.Model(md).Input(id2).Runid;

[handles,ok]=ddb_getDDBoundaries(handles,id1,id2,runid1,runid2);

if ok

    % Adjusting bathymetry

    depfil=handles.Model(md).Input(id2).DepFile;
    handles=ddb_makeDDModelNewAttributes(handles,id1,id2,runid1,runid2,depfil);

    % Write run batch file
    fid = fopen('rundd.bat','wt');
    for i=1:handles.GUIData.NrFlowDomains
        rid=handles.Model(md).Input(i).Runid;
        fprintf(fid,'%s\n',['echo ',rid,' > runid']);
        fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\tdatom.exe');
    end

    fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\trisim.exe ddbound');
    fclose(fid);

    setHandles(handles);
else
    GiveWarning('text','No DD Boundaries Found!');
end

%%
function FirstCornerPoint(m,n)

handles=getHandles;

id=handles.ActiveDomain;
handles.Toolbox(tb).Input.FirstCornerPointM=m;
handles.Toolbox(tb).Input.FirstCornerPointN=n;
handles.Toolbox(tb).Input.SecondCornerPointM=NaN;
handles.Toolbox(tb).Input.SecondCornerPointN=NaN;
xg=handles.Model(md).Input(id).GridX;
yg=handles.Model(md).Input(id).GridY;
if ~isnan(m)
    ClickPoint('cornerpoint','Grid',xg,yg,'Callback',@SecondCornerPoint,'single');
end
RefreshDD(handles);
setHandles(handles);

%%
function SecondCornerPoint(m,n)

handles=getHandles;


if ~isnan(m)
    handles.Toolbox(tb).Input.SecondCornerPointM=m;
    handles.Toolbox(tb).Input.SecondCornerPointN=n;
    RefreshDD(handles);
    setHandles(handles);
    set(gcf, 'windowbuttondownfcn',[]);
end

%%
function RefreshDD(handles)



id=handles.ActiveDomain;

if isfield(handles.Model(md).Input(id),'GridX')

    xg=handles.Model(md).Input(id).GridX;
    yg=handles.Model(md).Input(id).GridY;

    m1=handles.Toolbox(tb).Input.FirstCornerPointM;
    n1=handles.Toolbox(tb).Input.FirstCornerPointN;
    m2=handles.Toolbox(tb).Input.SecondCornerPointM;
    n2=handles.Toolbox(tb).Input.SecondCornerPointN;
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
        set(handles.GUIHandles.EditM1,'String',num2str(m1));
        set(handles.GUIHandles.EditN1,'String',num2str(n1));
        plt=plot3(xg(m1,n1),yg(m1,n1),9000,'go');
        set(plt,'MarkerEdgeColor','k','MarkerFaceColor','y');
        set(plt,'Tag','DDCornerPoint');
    else
        set(handles.GUIHandles.EditM1,'String','');
        set(handles.GUIHandles.EditN1,'String','');
    end
    if ~isnan(m2) && ~isnan(n2)
        set(handles.GUIHandles.EditM2,'String',num2str(m2));
        set(handles.GUIHandles.EditN2,'String',num2str(n2));
        plt=plot3(xg(m2,n2),yg(m2,n2),9000,'go');
        set(plt,'MarkerEdgeColor','k','MarkerFaceColor','y');
        set(plt,'Tag','DDCornerPoint');
    else
        set(handles.GUIHandles.EditM2,'String','');
        set(handles.GUIHandles.EditN2,'String','');
    end
    set(handles.GUIHandles.EditMRefinement,'String',num2str(handles.Toolbox(tb).Input.MRefinement));
    set(handles.GUIHandles.EditNRefinement,'String',num2str(handles.Toolbox(tb).Input.NRefinement));

    if mm2>mm1 && nn2>nn1
        PlotTemporaryDDGrid(handles);
    end

end

if handles.GUIData.NrFlowDomains>1
    set(handles.GUIHandles.SelectFirstDomain2,'Enable','on');
    set(handles.GUIHandles.TextFirstDomain2,'Enable','on');
    set(handles.GUIHandles.SelectFirstDomain2,'Value',1);
    set(handles.GUIHandles.SelectSecondDomain,'Enable','on');
    set(handles.GUIHandles.SelectSecondDomain,'Value',2);
    set(handles.GUIHandles.TextSecondDomain,'Enable','on');
    set(handles.GUIHandles.PushGenerateDDBoundaries,'Enable','on');
else
    set(handles.GUIHandles.SelectFirstDomain2,'Enable','off');
    set(handles.GUIHandles.TextFirstDomain2,'Enable','off');
    set(handles.GUIHandles.SelectSecondDomain,'Enable','off');
    set(handles.GUIHandles.TextSecondDomain,'Enable','off');
    set(handles.GUIHandles.PushGenerateDDBoundaries,'Enable','off');
end

%%
function PlotTemporaryDDGrid(handles)



xg=handles.Model(md).Input(handles.ActiveDomain).GridX;
yg=handles.Model(md).Input(handles.ActiveDomain).GridY;
m1=handles.Toolbox(tb).Input.FirstCornerPointM;
n1=handles.Toolbox(tb).Input.FirstCornerPointN;
m2=handles.Toolbox(tb).Input.SecondCornerPointM;
n2=handles.Toolbox(tb).Input.SecondCornerPointN;
mm1=min(m1,m2);mm2=max(m1,m2);
nn1=min(n1,n2);nn2=max(n1,n2);
xg=xg(mm1:mm2,nn1:nn2);
yg=yg(mm1:mm2,nn1:nn2);
mref=handles.Toolbox(tb).Input.MRefinement;
nref=handles.Toolbox(tb).Input.NRefinement;
[x2,y2]=ddb_refineD3DGrid(xg,yg,mref,nref);
z2=zeros(size(x2))+9000;
grd=mesh(x2,y2,z2);
set(grd,'FaceColor','none','EdgeColor','r','Tag','TemporaryDDGrid');

