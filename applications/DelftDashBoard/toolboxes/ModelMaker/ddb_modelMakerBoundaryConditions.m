function ddb_modelMakerBoundaryConditions

ddb_refreshScreen('Toolbox','Boundary Conditions');

handles=getHandles;

k=0;

handles.GUIData.NSalTem=0;

str{1}='none';
handles.GUIData.ConstName{1}=str{1};
handles.GUIData.ConstType{1}='none';
handles.GUIData.ConstNr(1)=0;

if handles.Model(md).Input(ad).Salinity.Include
    k=k+1;
    handles.GUIData.NSalTem=handles.GUIData.NSalTem+1;
    str{k}='Salinity';
    handles.GUIData.ConstName{k}=str{k};
    handles.GUIData.ConstType{k}='Salinity';
    handles.GUIData.ConstNr(k)=0;
end

if handles.Model(md).Input(ad).Temperature.Include
    k=k+1;
    handles.GUIData.NSalTem=handles.GUIData.NSalTem+1;
    str{k}='Temperature';
    handles.GUIData.ConstName{k}=str{k};
    handles.GUIData.ConstType{k}='Temperature';
    handles.GUIData.ConstNr(k)=0;
end

if handles.Model(md).Input(ad).Sediments
    for j=1:handles.Model(md).Input(ad).NrSediment
        k=k+1;
        str{k}=handles.Model(md).Input(ad).Sediment(j).Name;
        handles.GUIData.ConstName{k}=str{k};
        handles.GUIData.ConstType{k}='Sediment';
        handles.GUIData.ConstNr(k)=j;
    end
end

if handles.Model(md).Input(ad).Tracers
    for j=1:handles.Model(md).Input(ad).NrTracers
        k=k+1;
        str{k}=handles.Model(md).Input(ad).Tracer(j).Name;
        handles.GUIData.ConstName{k}=str{k};
        handles.GUIData.ConstType{k}='Tracer';
        handles.GUIData.ConstNr(k)=j;
    end
end
datsrc{1}='none';

handles.GUIHandles.SelectParameter   = uicontrol(gcf,'Style','popupmenu','String',str,'Value',1,   'Position',[ 40 120 100 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.SelectDataSource  = uicontrol(gcf,'Style','popupmenu','String',datsrc,'Value',1,'Position',[170 120 150 20],'BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextBCConst        = uicontrol(gcf,'Style','text','String','Value','Position',[350 117 50 20],'Tag','UIControl');
handles.GUIHandles.EditBCConst        = uicontrol(gcf,'Style','edit','String','ddb_test', 'Position',[410 120 60 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextDepth          = uicontrol(gcf,'Style','text','String','Depth','Position',[395 130 70 15],'HorizontalAlignment','center','Tag','UIControl');
handles.GUIHandles.TextValue          = uicontrol(gcf,'Style','text','String','Value','Position',[465 130 70 15],'HorizontalAlignment','center','Tag','UIControl');

handles.GUIHandles.PushGenerateBoundaryConditions  = uicontrol(gcf,'Style','pushbutton','String','Generate Boundary Conditions', 'Position',[40  30 170 20],'Tag','UIControl');
handles.GUIHandles.ToggleAllConstituents   = uicontrol(gcf,'Style','checkbox','String','Generate Boundary Conditions for All Constituents','Value',1,   'Position',[220 30 300 20],'Tag','UIControl');

set(handles.GUIHandles.SelectParameter, 'CallBack',   {@SelectParameter_Callback});
set(handles.GUIHandles.SelectDataSource,'CallBack',   {@SelectDataSource_Callback});
set(handles.GUIHandles.EditBCConst,     'CallBack',   {@EditBCConst_Callback});
set(handles.GUIHandles.PushGenerateBoundaryConditions,     'CallBack',   {@PushGenerateBoundaryConditions_Callback});

if k==0
    set(handles.GUIHandles.PushGenerateBoundaryConditions,'Enable','off');
end

SetUIBackgroundColors;

RefreshBoundaryConditions(handles);

setHandles(handles);

%%
function PushGenerateBoundaryConditions_Callback(hObject,eventdata)

handles=getHandles;

f=str2func(['GenerateTransportBoundaryConditions' handles.Model(md).Name]);
try
    handles=feval(f,handles,ad,'all','ddb_test');
catch
    GiveWarning('text',['Transport boundary condition generation not supported for ' handles.Model(md).LongName]);
    return
end

[filename, pathname, filterindex] = uiputfile('*.bcc', 'Select Transport Conditions File',handles.Model(md).Input(ad).BccFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    igenall=get(handles.GUIHandles.ToggleAllConstituents,'Value');
    if igenall==1
        par='all';
    else
        ii=get(handles.GUIHandles.SelectParameter,'Value');
        par=handles.GUIData.ConstName{ii};
    end
    handles.Model(md).Input(ad).BccFile=filename;
    handles=feval(f,handles,ad,par);
    setHandles(handles);
end

%%
function SelectParameter_Callback(hObject,eventdata)
handles=getHandles;
RefreshBoundaryConditions(handles);
setHandles(handles);

%%
function EditBCConst_Callback(hObject,eventdata)
handles=getHandles;
val=str2double(get(hObject,'String'));
ival=get(handles.GUIHandles.SelectParameter,'Value');

switch lower(handles.GUIData.ConstType{ival})
    case{'salinity'}
        handles.Model(md).Input(ad).Salinity.BCConst=val;
    case{'temperature'}
        handles.Model(md).Input(ad).Temperature.BCConst=val;
    case{'sediment'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Sediment(j).BCConst=val;
    case{'tracer'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Tracer(j).BCConst=val;
end
setHandles(handles);

%%
function SelectDataSource_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
str=get(hObject,'String');
ival=get(handles.GUIHandles.SelectParameter,'Value');

switch lower(handles.GUIData.ConstType{ival})
    case{'salinity'}
        handles.Model(md).Input(ad).Salinity.BCOpt=str{ii};
    case{'temperature'}
        handles.Model(md).Input(ad).Temperature.BCOpt=str{ii};
    case{'sediment'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Sediment(j).BCOpt=str{ii};
    case{'tracer'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Tracer(j).BCOpt=str{ii};
end
RefreshBoundaryConditions(handles);
setHandles(handles);

%%
function RefreshBoundaryConditions(handles)

ival=get(handles.GUIHandles.SelectParameter,'Value');

switch lower(handles.GUIData.ConstType{ival})
    case{'salinity'}
        str{1}='Constant';
        str{2}='Linear';
        str{3}='Block';
        str{4}='Per Layer';
        set(handles.GUIHandles.SelectDataSource,'Value',1);
        set(handles.GUIHandles.SelectDataSource,'String',str);
        ii=strmatch(lower(handles.Model(md).Input(ad).Salinity.BCOpt),lower(str),'exact');
        set(handles.GUIHandles.SelectDataSource,'Value',ii);
        bcpar=handles.Model(md).Input(ad).Salinity.BCPar;
        bcconst=handles.Model(md).Input(ad).Salinity.BCConst;
    case{'temperature'}
        str{1}='Constant';
        str{2}='Linear';
        str{3}='Block';
        str{4}='Per Layer';
        set(handles.GUIHandles.SelectDataSource,'Value',1);
        set(handles.GUIHandles.SelectDataSource,'String',str);
        ii=strmatch(lower(handles.Model(md).Input(ad).Temperature.BCOpt),lower(str),'exact');
        set(handles.GUIHandles.SelectDataSource,'Value',ii);
        bcpar=handles.Model(md).Input(ad).Temperature.BCPar;
        bcconst=handles.Model(md).Input(ad).Temperature.BCConst;
   case{'sediment'}
        str{1}='Constant';
        str{2}='Linear';
        str{3}='Block';
        str{4}='Per Layer';
        set(handles.GUIHandles.SelectDataSource,'Value',1);
        set(handles.GUIHandles.SelectDataSource,'String',str);
        j=handles.GUIData.ConstNr(ival);
        ii=strmatch(lower(handles.Model(md).Input(ad).Sediment(j).BCOpt),lower(str),'exact');
        set(handles.GUIHandles.SelectDataSource,'Value',ii);
        bcpar=handles.Model(md).Input(ad).Sediment(j).BCPar;
        bcconst=handles.Model(md).Input(ad).Sediment(j).BCConst;
    case{'tracer'}
        str{1}='Constant';
        str{2}='Linear';
        str{3}='Block';
        str{4}='Per Layer';
        set(handles.GUIHandles.SelectDataSource,'Value',1);
        set(handles.GUIHandles.SelectDataSource,'String',str);
        j=handles.GUIData.ConstNr(ival);
        ii=strmatch(lower(handles.Model(md).Input(ad).Tracer(j).BCOpt),lower(str),'exact');
        set(handles.GUIHandles.SelectDataSource,'Value',ii);
        bcpar=handles.Model(md).Input(ad).Tracer(j).BCPar;
        bcconst=handles.Model(md).Input(ad).Tracer(j).BCConst;
end

str=get(handles.GUIHandles.SelectDataSource,'String');
ii=get(handles.GUIHandles.SelectDataSource,'Value');
tp=str{ii};

table(gcf,'bctable','delete');
set(handles.GUIHandles.EditBCConst,'Visible','off');
set(handles.GUIHandles.TextBCConst,'Visible','off');
set(handles.GUIHandles.TextValue,'Visible','off');
set(handles.GUIHandles.TextDepth,'Visible','off');

switch lower(tp)
    case{'constant','logarithmic'}
        set(handles.GUIHandles.EditBCConst,'Visible','on');
        set(handles.GUIHandles.TextBCConst,'Visible','on');
        set(handles.GUIHandles.EditBCConst,'String',num2str(bcconst));
    case{'linear','block'}
        for i=1:size(bcpar,1)
            data{i,1}=bcpar(i,1);
            data{i,2}=bcpar(i,2);
        end
        callbacks={@ChangeBCTable,@ChangeBCTable};
        coltp={'editreal','editreal'};
        table(gcf,'bctable','create','position',[370 30],'nrrows',5,'columntypes',coltp,'width',[70 70],'data',data,'callbacks',callbacks,'includenumbers','includebuttons');
        set(handles.GUIHandles.TextValue,'Visible','on');
        set(handles.GUIHandles.TextDepth,'Visible','on');
    case{'per layer'}
        kmax=handles.Model(md).Input(ad).KMax;
        if size(bcpar,1)~=kmax
            bcpar=[];
            for i=1:kmax
                bcpar(i,1)=0;
                bcpar(i,2)=0;
            end
        end
        for i=1:kmax
            data{i,1}=bcpar(i,1);
        end
        callbacks={@ChangeBCTable};
        coltp={'editreal'};
        table(gcf,'bctable','create','position',[440 30],'nrrows',5,'columntypes',coltp,'width',70,'data',data,'callbacks',callbacks,'includenumbers');
        set(handles.GUIHandles.TextValue,'Visible','on');
    otherwise
end

%%
function ChangeBCTable

handles=getHandles;
data=table(gcf,'bctable','getdata');
bcpar=[];
for i=1:size(data,1)
    for j=1:size(data,2)
        bcpar(i,j)=data{i,j};
    end
    if size(data,2)==1
        bcpar(i,2)=0;
    end
end

ival=get(handles.GUIHandles.SelectParameter,'Value');


switch lower(handles.GUIData.ConstType{ival})
    case{'salinity'}
        handles.Model(md).Input(ad).Salinity.BCPar=bcpar;
    case{'temperature'}
        handles.Model(md).Input(ad).Temperature.BCPar=bcpar;
   case{'sediment'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Sediment(j).BCPar=bcpar;
    case{'tracer'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Tracer(j).BCPar=bcpar;
end

setHandles(handles);
