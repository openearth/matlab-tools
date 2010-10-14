function ddb_modelMakerInitialConditions

ddb_refreshScreen('Toolbox','Initial Conditions');

handles=getHandles;

str{1}='Water Level';
str{2}='Velocity';
handles.GUIData.ConstType{1}='Water Level';
handles.GUIData.ConstType{2}='Velocity';

k=2;

handles.GUIData.NSalTem=0;

if handles.Model(md).Input(ad).Salinity.Include
    k=k+1;
    handles.GUIData.NSalTem=handles.GUIData.NSalTem+1;
    str{k}='Salinity';
    handles.GUIData.ConstType{k}='Salinity';
end

if handles.Model(md).Input(ad).Temperature.Include
    k=k+1;
    handles.GUIData.NSalTem=handles.GUIData.NSalTem+1;
    str{k}='Temperature';
    handles.GUIData.ConstType{k}='Temperature';
end

if handles.Model(md).Input(ad).Sediments
    for j=1:handles.Model(md).Input(ad).NrSediment
        k=k+1;
        str{k}=handles.Model(md).Input(ad).Sediment(j).Name;
        handles.GUIData.ConstType{k}='Sediment';
        handles.GUIData.ConstNr(k)=j;
    end
end

if handles.Model(md).Input(ad).Tracers
    for j=1:handles.Model(md).Input(ad).NrTracers
        k=k+1;
        str{k}=handles.Model(md).Input(ad).Tracer(j).Name;
        handles.GUIData.ConstType{k}='Tracer';
        handles.GUIData.ConstNr(k)=j;
    end
end

handles.GUIHandles.SelectParameter   = uicontrol(gcf,'Style','popupmenu','String',str,'Value',1,   'Position',[ 40 120 100 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.SelectDataSource  = uicontrol(gcf,'Style','popupmenu','String','ddb_test','Value',1,'Position',[170 120 150 20],'BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextICConst        = uicontrol(gcf,'Style','text','String','Value','Position',[350 117 50 20],'Tag','UIControl');
handles.GUIHandles.EditICConst        = uicontrol(gcf,'Style','edit','String','ddb_test', 'Position',[410 120 60 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextDepth          = uicontrol(gcf,'Style','text','String','Depth','Position',[395 130 70 15],'HorizontalAlignment','center','Tag','UIControl');
handles.GUIHandles.TextValue          = uicontrol(gcf,'Style','text','String','Value','Position',[465 130 70 15],'HorizontalAlignment','center','Tag','UIControl');


handles.GUIHandles.PushGenerateInitialConditions  = uicontrol(gcf,'Style','pushbutton','String','Generate Initial Conditions', 'Position',[40  30 170 20],'Tag','UIControl');

set(handles.GUIHandles.SelectParameter, 'CallBack',   {@SelectParameter_CallBack});
set(handles.GUIHandles.SelectDataSource,'CallBack',   {@SelectDataSource_CallBack});
set(handles.GUIHandles.EditICConst,     'CallBack',   {@EditICConst_CallBack});
set(handles.GUIHandles.PushGenerateInitialConditions,     'CallBack',   {@PushGenerateInitialConditions_CallBack});

SetUIBackgroundColors;

RefreshInitialConditions(handles);

setHandles(handles);

%%
function PushGenerateInitialConditions_CallBack(hObject,eventdata)

handles=getHandles;

f=str2func(['ddb_generateInitialConditions' handles.Model(md).Name]);

try
    handles=feval(f,handles,ad,'ddb_test','ddb_test');
catch
    GiveWarning('text',['Initial conditions generation not supported for ' handles.Model(md).LongName]);
    return
end

[filename, pathname, filterindex] = uiputfile('*.ini', 'Select Ini File',handles.Model(md).Input(ad).IniFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).IniFile=filename;
    handles.Model(md).Input(ad).InitialConditions='ini';
    handles.Model(md).Input(ad).SmoothingTime=0.0;
    handles=feval(f,handles,ad,filename);
    setHandles(handles);
end

%%
function SelectParameter_CallBack(hObject,eventdata)
handles=getHandles;
RefreshInitialConditions(handles);
setHandles(handles);

%%
function EditICConst_CallBack(hObject,eventdata)
handles=getHandles;
val=str2double(get(hObject,'String'));
ival=get(handles.GUIHandles.SelectParameter,'Value');

switch lower(handles.GUIData.ConstType{ival})
    case{'water level'}
        handles.Model(md).Input(ad).WaterLevel.ICConst=val;
    case{'velocity'}
        handles.Model(md).Input(ad).Velocity.ICConst=val;
    case{'salinity'}
        handles.Model(md).Input(ad).Salinity.ICConst=val;
    case{'temperature'}
        handles.Model(md).Input(ad).Temperature.ICConst=val;
    case{'sediment'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Sediment(j).ICConst=val;
    case{'tracer'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Tracer(j).ICConst=val;
end
setHandles(handles);

%%
function SelectDataSource_CallBack(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
str=get(hObject,'String');
ival=get(handles.GUIHandles.SelectParameter,'Value');

switch lower(handles.GUIData.ConstType{ival})
    case{'water level'}
        handles.Model(md).Input(ad).WaterLevel.ICOpt=str{ii};
        handles.TideModels.ActiveTideModelIC=handles.TideModels.Name{ii};
    case{'velocity'}
        handles.Model(md).Input(ad).Velocity.ICOpt=str{ii};
    case{'salinity'}
        handles.Model(md).Input(ad).Salinity.ICOpt=str{ii};
    case{'temperature'}
        handles.Model(md).Input(ad).Temperature.ICOpt=str{ii};
    case{'sediment'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Sediment(j).ICOpt=str{ii};
    case{'tracer'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Tracer(j).ICOpt=str{ii};
end
RefreshInitialConditions(handles);
setHandles(handles);


%%
function RefreshInitialConditions(handles)

ival=get(handles.GUIHandles.SelectParameter,'Value');

switch lower(handles.GUIData.ConstType{ival})
    case{'water level'}
        set(handles.GUIHandles.SelectDataSource,'String',handles.TideModels.longName);
        ii=strmatch(lower(handles.Model(md).Input(ad).WaterLevel.ICOpt),lower(handles.TideModels.Name),'exact');
        set(handles.GUIHandles.SelectDataSource,'Value',ii);        
        icpar=handles.Model(md).Input(ad).WaterLevel.ICPar;
        icconst=handles.Model(md).Input(ad).WaterLevel.ICConst;
    case{'velocity'}
        str{1}='Constant';
        str{2}='Logarithmic';
        str{3}='Linear';
        str{4}='Block';
        str{4}='Per Layer';
        set(handles.GUIHandles.SelectDataSource,'Value',1);
        set(handles.GUIHandles.SelectDataSource,'String',str);
        ii=strmatch(lower(handles.Model(md).Input(ad).Velocity.ICOpt),lower(str),'exact');
        set(handles.GUIHandles.SelectDataSource,'Value',ii);
        icpar=handles.Model(md).Input(ad).Velocity.ICPar;
        icconst=handles.Model(md).Input(ad).Velocity.ICConst;
    case{'salinity'}
        str{1}='Constant';
        str{2}='Linear';
        str{3}='Block';
        str{4}='Per Layer';
        set(handles.GUIHandles.SelectDataSource,'Value',1);
        set(handles.GUIHandles.SelectDataSource,'String',str);
        ii=strmatch(lower(handles.Model(md).Input(ad).Salinity.ICOpt),lower(str),'exact');
        set(handles.GUIHandles.SelectDataSource,'Value',ii);
        icpar=handles.Model(md).Input(ad).Salinity.ICPar;
        icconst=handles.Model(md).Input(ad).Salinity.ICConst;
    case{'temperature'}
        str{1}='Constant';
        str{2}='Linear';
        str{3}='Block';
        str{4}='Per Layer';
        set(handles.GUIHandles.SelectDataSource,'Value',1);
        set(handles.GUIHandles.SelectDataSource,'String',str);
        ii=strmatch(lower(handles.Model(md).Input(ad).Temperature.ICOpt),lower(str),'exact');
        set(handles.GUIHandles.SelectDataSource,'Value',ii);
        icpar=handles.Model(md).Input(ad).Temperature.ICPar;
        icconst=handles.Model(md).Input(ad).Temperature.ICConst;
   case{'sediment'}
        str{1}='Constant';
        str{2}='Linear';
        str{3}='Block';
        str{4}='Per Layer';
        set(handles.GUIHandles.SelectDataSource,'Value',1);
        set(handles.GUIHandles.SelectDataSource,'String',str);
        j=handles.GUIData.ConstNr(ival);
        ii=strmatch(lower(handles.Model(md).Input(ad).Sediment(j).ICOpt),lower(str),'exact');
        set(handles.GUIHandles.SelectDataSource,'Value',ii);
        icpar=handles.Model(md).Input(ad).Sediment(j).ICPar;
        icconst=handles.Model(md).Input(ad).Sediment(j).ICConst;
    case{'tracer'}
        str{1}='Constant';
        str{2}='Linear';
        str{3}='Block';
        str{4}='Per Layer';
        set(handles.GUIHandles.SelectDataSource,'Value',1);
        set(handles.GUIHandles.SelectDataSource,'String',str);
        j=handles.GUIData.ConstNr(ival);
        ii=strmatch(lower(handles.Model(md).Input(ad).Tracer(j).ICOpt),lower(str),'exact');
        set(handles.GUIHandles.SelectDataSource,'Value',ii);
        icpar=handles.Model(md).Input(ad).Tracer(j).ICPar;
        icconst=handles.Model(md).Input(ad).Tracer(j).ICConst;
end

str=get(handles.GUIHandles.SelectDataSource,'String');
ii=get(handles.GUIHandles.SelectDataSource,'Value');
tp=str{ii};

table2(gcf,'ictable','delete');
set(handles.GUIHandles.EditICConst,'Visible','off');
set(handles.GUIHandles.TextICConst,'Visible','off');
set(handles.GUIHandles.TextValue,'Visible','off');
set(handles.GUIHandles.TextDepth,'Visible','off');

switch lower(tp)
    case{'constant','logarithmic'}
        set(handles.GUIHandles.EditICConst,'Visible','on');
        set(handles.GUIHandles.TextICConst,'Visible','on');
        set(handles.GUIHandles.EditICConst,'String',num2str(icconst));
    case{'linear','block'}
        for i=1:size(icpar,1)
            data{i,1}=icpar(i,1);
            data{i,2}=icpar(i,2);
        end
        callbacks={@ChangeICTable,@ChangeICTable};
        coltp={'editreal','editreal'};
        table2(gcf,'ictable','create','position',[370 30],'nrrows',5,'columntypes',coltp,'width',[70 70],'data',data,'callbacks',callbacks,'includenumbers','includebuttons');
        set(handles.GUIHandles.TextValue,'Visible','on');
        set(handles.GUIHandles.TextDepth,'Visible','on');
    case{'per layer'}
        kmax=handles.Model(md).Input(ad).KMax;
        if size(icpar,1)~=kmax
            icpar=[];
            for i=1:kmax
                icpar(i,1)=0;
                icpar(i,2)=0;
            end
        end
        for i=1:kmax
            data{i,1}=icpar(i,1);
        end
        callbacks={@ChangeICTable};
        coltp={'editreal'};
        table(gcf,'ictable','create','position',[440 30],'nrrows',5,'columntypes',coltp,'width',70,'data',data,'callbacks',callbacks,'includenumbers');
        set(handles.GUIHandles.TextValue,'Visible','on');
    otherwise
end

%%
function ChangeICTable

handles=getHandles;
data=table2(gcf,'ictable','getdata');
icpar=[];
for i=1:size(data,1)
    for j=1:size(data,2)
        icpar(i,j)=data{i,j};
    end
    if size(data,2)==1
        icpar(i,2)=0;
    end
end

ival=get(handles.GUIHandles.SelectParameter,'Value');

switch lower(handles.GUIData.ConstType{ival})
    case{'velocity'}
        handles.Model(md).Input(ad).Velocity.ICPar=icpar;
    case{'salinity'}
        handles.Model(md).Input(ad).Salinity.ICPar=icpar;
    case{'temperature'}
        handles.Model(md).Input(ad).Temperature.ICPar=icpar;
   case{'sediment'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Sediment(j).ICPar=icpar;
    case{'tracer'}
        j=handles.GUIData.ConstNr(ival);
        handles.Model(md).Input(ad).Tracer(j).ICPar=icpar;
end

setHandles(handles);
