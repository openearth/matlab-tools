function ddb_DDToolbox

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
for i=1:handles.GUIData.nrFlowDomains
    str{i}=handles.Model(md).Input(i).runid;
end
handles.GUIHandles.SelectFirstDomain=uicontrol(gcf,'Style','popupmenu','String',str,'Position',[140 125 80 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.SelectFirstDomain,'Value',handles.activeDomain);
handles.GUIHandles.TextFirstDomain=uicontrol(gcf,'Style','text','String','First Domain','Position',[35 121 100 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.EditSecondRunid=uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Input.newRunid,'Position',[140 100  80 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSecondRunid=uicontrol(gcf,'Style','text','String','Runid New Domain','Position',[35 96 100 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.EditMRefinement=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.mRefinement),'Position',[140 65  80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextMRefinement=uicontrol(gcf,'Style','text','String','M Refinement','Position',[35 61 100 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditNRefinement=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.nRefinement),'Position',[140 40  80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
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
set(handles.GUIHandles.SelectFirstDomain2,'Value',handles.activeDomain);
handles.GUIHandles.TextFirstDomain2=uicontrol(gcf,'Style','text','String','First Domain','Position',[405 121 80 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.SelectSecondDomain=uicontrol(gcf,'Style','popupmenu','String',str,'Position',[490 100 80 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.SelectSecondDomain,'Value',handles.activeDomain);
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

handles.Toolbox(tb).Input.newRunid=get(hObject,'String');
setHandles(handles);

%%
function EditMRefinement_CallBack(hObject,eventdata)

handles=getHandles;

handles.Toolbox(tb).Input.mRefinement=str2double(get(hObject,'String'));
RefreshDD(handles)
setHandles(handles);

%%
function EditNRefinement_CallBack(hObject,eventdata)

handles=getHandles;

handles.Toolbox(tb).Input.nRefinement=str2num(get(hObject,'String'));
RefreshDD(handles)
setHandles(handles);

%%
function EditM1_CallBack(hObject,eventdata)

handles=getHandles;

ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(md).Input(handles.activeDomain).gridX);
if ii<=sz(1)
    handles.Toolbox(tb).Input.firstCornerPointM=ii;
else
    handles.Toolbox(tb).Input.firstCornerPointM=sz(1);
end
RefreshDD(handles)
setHandles(handles);

%%
function EditM2_CallBack(hObject,eventdata)

handles=getHandles;

ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(md).Input(handles.activeDomain).gridX);
if ii<=sz(1)
    handles.Toolbox(tb).Input.secondCornerPointM=ii;
else
    handles.Toolbox(tb).Input.secondCornerPointM=sz(1);
end
RefreshDD(handles)
setHandles(handles);

%%
function EditN1_CallBack(hObject,eventdata)

handles=getHandles;

ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(md).Input(handles.activeDomain).gridX);
if ii<=sz(2)
    handles.Toolbox(tb).Input.firstCornerPointN=ii;
else
    handles.Toolbox(tb).Input.firstCornerPointN=sz(2);
end
RefreshDD(handles)
setHandles(handles);

%%
function EditN2_CallBack(hObject,eventdata)

handles=getHandles;

ii=str2num(get(hObject,'String'));
ii=max(ii,1);
sz=size(handles.Model(md).Input(handles.activeDomain).gridX);
if ii<=sz(2)
    handles.Toolbox(tb).Input.secondCornerPointN=ii;
else
    handles.Toolbox(tb).Input.secondCornerPointN=sz(2);
end
RefreshDD(handles)
setHandles(handles);

%%
function PushSelectCornerPoints_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
xg=handles.Model(md).Input(handles.activeDomain).gridX;
yg=handles.Model(md).Input(handles.activeDomain).gridY;
ClickPoint('cornerpoint','Grid',xg,yg,'Callback',@FirstCornerPoint,'single');
setHandles(handles);

%%
function PushGenerateDomain_CallBack(hObject,eventdata)

ddb_zoomOff;

handles=getHandles;


m1=handles.Toolbox(tb).Input.firstCornerPointM;
n1=handles.Toolbox(tb).Input.firstCornerPointN;
m2=handles.Toolbox(tb).Input.secondCornerPointM;
n2=handles.Toolbox(tb).Input.secondCornerPointN;
mmin=min(m1,m2);mmax=max(m1,m2);
nmin=min(n1,n2);nmax=max(n1,n2);

for i=1:handles.GUIData.nrFlowDomains
    str{i}=handles.Model(md).Input(i).runid;
end
ii=strmatch(lower(handles.Toolbox(tb).Input.newRunid),lower(str),'exact');
if ~isempty(ii)
    GiveWarning('Warning',['A domain with runid "' handles.Toolbox(tb).Input.newRunid '" already exists!']);
elseif mmax>mmin && nmax>nmin

    [handles,cancel]=ddb_makeDDModel(handles,handles.activeDomain,handles.GUIData.nrFlowDomains+1,handles.Toolbox(tb).Input.newRunid);

    if ~cancel
        handles.GUIData.nrFlowDomains=handles.GUIData.nrFlowDomains+1;
        h=findall(gca,'Tag','DDCornerPoint');
        if ~isempty(h)
            delete(h);
        end
        h=findall(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            delete(h);
        end
        handles.Toolbox(tb).Input.firstCornerPointM=NaN;
        handles.Toolbox(tb).Input.secondCornerPointM=NaN;
        handles.Toolbox(tb).Input.firstCornerPointN=NaN;
        handles.Toolbox(tb).Input.secondCornerPointN=NaN;

        setHandles(handles);

        for i=1:handles.GUIData.nrFlowDomains
            if i==handles.activeDomain
                ddb_plotDelft3DFLOW('plot','active',1);
            else
                ddb_plotDelft3DFLOW('plot','active',0);
            end
        end

        handles=getHandles;

        ddb_refreshFlowDomains;
    end

    for i=1:handles.GUIData.nrFlowDomains
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
runid1=handles.Model(md).Input(id1).runid;
runid2=handles.Model(md).Input(id2).runid;

[handles,ok]=ddb_getDDBoundaries(handles,id1,id2,runid1,runid2);

if ok

    % Adjusting bathymetry

    depfil=handles.Model(md).Input(id2).depFile;
    handles=ddb_makeDDModelNewAttributes(handles,id1,id2,runid1,runid2,depfil);

    % Write run batch file
    fid = fopen('rundd.bat','wt');
    for i=1:handles.GUIData.nrFlowDomains
        rid=handles.Model(md).Input(i).runid;
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

id=handles.activeDomain;
handles.Toolbox(tb).Input.firstCornerPointM=m;
handles.Toolbox(tb).Input.firstCornerPointN=n;
handles.Toolbox(tb).Input.secondCornerPointM=NaN;
handles.Toolbox(tb).Input.secondCornerPointN=NaN;
xg=handles.Model(md).Input(id).gridX;
yg=handles.Model(md).Input(id).gridY;
if ~isnan(m)
    ClickPoint('cornerpoint','Grid',xg,yg,'Callback',@SecondCornerPoint,'single');
end
RefreshDD(handles);
setHandles(handles);

%%
function SecondCornerPoint(m,n)

handles=getHandles;


if ~isnan(m)
    handles.Toolbox(tb).Input.secondCornerPointM=m;
    handles.Toolbox(tb).Input.secondCornerPointN=n;
    RefreshDD(handles);
    setHandles(handles);
    set(gcf, 'windowbuttondownfcn',[]);
end

%%
function RefreshDD(handles)



id=handles.activeDomain;

if isfield(handles.Model(md).Input(id),'gridX')

    xg=handles.Model(md).Input(id).gridX;
    yg=handles.Model(md).Input(id).gridY;

    m1=handles.Toolbox(tb).Input.firstCornerPointM;
    n1=handles.Toolbox(tb).Input.firstCornerPointN;
    m2=handles.Toolbox(tb).Input.secondCornerPointM;
    n2=handles.Toolbox(tb).Input.secondCornerPointN;
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
    set(handles.GUIHandles.EditMRefinement,'String',num2str(handles.Toolbox(tb).Input.mRefinement));
    set(handles.GUIHandles.EditNRefinement,'String',num2str(handles.Toolbox(tb).Input.nRefinement));

    if mm2>mm1 && nn2>nn1
        PlotTemporaryDDGrid(handles);
    end

end

if handles.GUIData.nrFlowDomains>1
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



xg=handles.Model(md).Input(handles.activeDomain).gridX;
yg=handles.Model(md).Input(handles.activeDomain).gridY;
m1=handles.Toolbox(tb).Input.firstCornerPointM;
n1=handles.Toolbox(tb).Input.firstCornerPointN;
m2=handles.Toolbox(tb).Input.secondCornerPointM;
n2=handles.Toolbox(tb).Input.secondCornerPointN;
mm1=min(m1,m2);mm2=max(m1,m2);
nn1=min(n1,n2);nn2=max(n1,n2);
xg=xg(mm1:mm2,nn1:nn2);
yg=yg(mm1:mm2,nn1:nn2);
mref=handles.Toolbox(tb).Input.mRefinement;
nref=handles.Toolbox(tb).Input.nRefinement;
[x2,y2]=ddb_refineD3DGrid(xg,yg,mref,nref);
z2=zeros(size(x2))+9000;
grd=mesh(x2,y2,z2);
set(grd,'FaceColor','none','EdgeColor','r','Tag','TemporaryDDGrid');

