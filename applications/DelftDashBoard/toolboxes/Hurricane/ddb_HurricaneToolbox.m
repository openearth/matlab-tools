function ddb_hurricaneToolbox

handles=getHandles;

ddb_plotDD(handles,'activate');

h=findall(gca,'Tag','HurricaneTrack');
if ~isempty(h)
    set(h,'Visible','on');
end

uipanel('Title','Hurricane','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');
uipanel('Title','Options','Units','pixels','Position',[30 30 155 135],'Tag','UIControl');
uipanel('Title','Detailed Hurricane Track data in UTC','Units','pixels','Position',[195 30 505 135],'Tag','UIControl');

InputOption{1}= 'Speed and Pressure';
InputOption{2}= 'Holland Par. A & B';

handles.EditInitSpeed     = uicontrol(gcf,'Style','edit','String','','Position',[145 125  30 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditInitDir       = uicontrol(gcf,'Style','edit','String','','Position',[145 100  30 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextInput         = uicontrol(gcf,'Style','text','String','Input'         ,'Position',[45  78 130 15],'HorizontalAlignment','center','Tag','UIControl');
handles.SelectInputOption = uicontrol(gcf,'Style','popupmenu','String',InputOption,'Position',[45  60 130 18],'BackgroundColor',[1 1 1],'Tag','UIControl');

handles.TextSpeed         = uicontrol(gcf,'Style','text','String','Initial Speed (knots)'          ,'Position',[40  122 100 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextDirection     = uicontrol(gcf,'Style','text','String','Initial Direction (deg.)'       ,'Position',[40   97 100 20],'HorizontalAlignment','right','Tag','UIControl');

handles.ToggleShowDetails = uicontrol(gcf,'Style','checkbox','String','Show Details','Position',[45  35 130 18],'Tag','UIControl');

handles.TextDate = uicontrol(gcf,'Style','text','String','Date (dd mm yyyy)','Position',[230 119  80 30],'HorizontalAlignment','center','Tag','UIControl');
handles.TextHour = uicontrol(gcf,'Style','text','String','Hour (HH)'         ,'Position',[310 119  30 30],'HorizontalAlignment','center','Tag','UIControl');
handles.TextLat  = uicontrol(gcf,'Style','text','String','Lat.    (deg.)'    ,'Position',[340 119  50 30],'HorizontalAlignment','center','Tag','UIControl');
handles.TextLon  = uicontrol(gcf,'Style','text','String','Lon.    (deg.)'    ,'Position',[395 119  50 30],'HorizontalAlignment','center','Tag','UIControl');
handles.TextVmax = uicontrol(gcf,'Style','text','String','A parameter'  ,'Position',[450 119  55 28],'HorizontalAlignment','center','Tag','UIControl');
handles.TextPdrop= uicontrol(gcf,'Style','text','String','B parameter'  ,'Position',[510 119  50 28],'HorizontalAlignment','center','Tag','UIControl');

handles.PushDrawTrack   = uicontrol(gcf,'Style','pushbutton','String','Draw Track','Position',    [590 115 100 20],'Tag','UIControl');
handles.PushDeletePoint = uicontrol(gcf,'Style','pushbutton','String','Delete Point','Position',  [590  90 100 20],'Tag','UIControl','Enable','Off');
handles.PushAddPoint    = uicontrol(gcf,'Style','pushbutton','String','Add Point','Position',     [590  65 100 20],'Tag','UIControl');
%handles.PushInsertPoint = uicontrol(gcf,'Style','pushbutton','String','Insert Point','Position',  [590  40 100 20],'Tag','UIControl','Enable','Off');

handles.Pushddb_computeHurricane = uicontrol(gcf,'Style','pushbutton','String','Compute Hurricane','Position',[860 55 130 20],'Tag','UIControl');
handles.PushViewHurricane    = uicontrol(gcf,'Style','pushbutton','String','View Hurricane','Position',[860 30 130 20],'Tag','UIControl','Enable','Off');

handles.PushOpen   = uicontrol(gcf,'Style','pushbutton','String','Open','Position',      [860 135 60 20],'Tag','UIControl');
handles.PushSave   = uicontrol(gcf,'Style','pushbutton','String','Save','Position',      [860 110 60 20],'Enable','off','Tag','UIControl');
handles.PushImport = uicontrol(gcf,'Style','pushbutton','String','Import ...','Position',[930 135 60 20],'Tag','UIControl');
handles.PushExport = uicontrol(gcf,'Style','pushbutton','String','Export ...','Position',[930 110 60 20],'Enable','off','Tag','UIControl');
handles.PushUnisysWebsite    = uicontrol(gcf,'Style','pushbutton','String','Unisys Weather','Position',[860 85 130 20],'Tag','UIControl');

set(handles.EditInitSpeed,    'CallBack',{@EditInitSpeed_CallBack});
set(handles.EditInitDir,      'CallBack',{@EditInitDir_CallBack});
set(handles.SelectInputOption,'CallBack',{@SelectInputOption_CallBack});
set(handles.ToggleShowDetails,'CallBack',{@ToggleShowDetails_CallBack});
set(handles.PushDrawTrack,    'CallBack',{@PushDrawTrack_CallBack});
set(handles.PushAddPoint,     'CallBack',{@PushAddPoint_CallBack});
set(handles.PushSave,'CallBack',{@PushSaveFile_CallBack});
set(handles.PushOpen,'CallBack',{@PushOpenFile_CallBack});
set(handles.Pushddb_computeHurricane,'CallBack',{@Push_computeHurricane_CallBack});
set(handles.PushViewHurricane,   'CallBack',{@PushViewHurricane_CallBack});
set(handles.PushUnisysWebsite,   'CallBack',{@PushUnisysWebsite_CallBack});
set(handles.PushImport,'CallBack',{@PushImport_CallBack});

cltp={'editstring','editreal','editreal','editreal','editreal','editreal'};
wdt=[85 30 50 50 55 60];
callbacks={@UpdateTrack,@UpdateTrack,@UpdateTrack,@UpdateTrack,@UpdateTrack,@UpdateTrack,};
fmt={'%s','%2.0f','%4.2f','%4.2f','%5.1f','%10.1f'};
enab=zeros(4,6)+1;

handles.GUIHandles.hurricaneTable=table(gcf,'create','tag','table','position',[200 40],'nrrows',4,'columntypes',cltp,'width',wdt,'callbacks',callbacks,'format',fmt,'enable',enab,'includenumbers',1);

handles=RefreshAllHurricane(handles);


SetUIBackgroundColors;

setHandles(handles);

%%
function EditInitSpeed_CallBack(hObject,eventdata)

handles=getHandles;

ispeed = str2double(get(hObject,'String'));
if ispeed > 25
   GiveWarning('text','Usually the storm centre moves slower than 25 kts. Are you sure?');
end   
handles.Toolbox(tb).Input.initSpeed=ispeed;
handles=RefreshAllHurricane(handles);
setHandles(handles);

%%
function EditInitDir_CallBack(hObject,eventdata)

handles=getHandles;

idir = str2double(get(hObject,'String'));
if idir < 0
   idir = idir + 360.;
   GiveWarning('text','Adjusting the value between 0 and 360 degrees');
elseif idir > 360.
   idir = rem(idir,360.);
   GiveWarning('text','Adjusting the value between 0 and 360 degrees');
end   
handles.Toolbox(tb).Input.initDir=idir;
handles=RefreshAllHurricane(handles);
setHandles(handles); 

%%
function SelectInputOption_CallBack(hObject,eventdata)

handles=getHandles;

ii=get(hObject,'Value');
if ii==2
    handles.Toolbox(tb).Input.holland=1;
else
    handles.Toolbox(tb).Input.holland=0;
end
handles=RefreshAllHurricane(handles);
setHandles(handles);

%%
function ToggleShowDetails_CallBack(hObject,eventdata)

handles=getHandles;

ii=get(hObject,'Value');
if ii==1
    handles.Toolbox(tb).Input.showDetails=1;
else
    handles.Toolbox(tb).Input.showDetails=0;
end
DrawHurricaneTrack(handles);
setHandles(handles);

%%
function PushSaveFile_CallBack(hObject,eventdata)

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.hur', 'Select Hurricane File','');
if filename==0
    return
end
filename1=[pathname filename];
filename2=[pathname 'wes_old.trk'];
handles.Toolbox(tb).Input.trk_file = filename1;
ddb_saveHurricaneFile(handles,filename1,filename2);
setHandles(handles);

%%
function Push_computeHurricane_CallBack(hObject,eventdata)

handles=getHandles;
handles=ddb_computeHurricane(handles);
setHandles(handles);


%%
function PushViewHurricane_CallBack(hObject,eventdata)
handles=getHandles;
if ~isempty(handles.Model(md).Input(ad).spwFile)
    if exist(handles.Model(md).Input(ad).spwFile,'file')
        ddb_plotSpiderweb(handles.Model(md).Input(ad).spwFile,handles.GUIData.x,handles.GUIData.y,handles.GUIData.z,handles.GUIData.WorldCoastLine5000000(:,1),handles.GUIData.WorldCoastLine5000000(:,2),handles);
    end
end

%%
function PushOpenFile_CallBack(hObject,eventdata)

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.hur', 'Select Hurricane File','');
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
    
end
handles.Toolbox(tb).Input=[];
handles=ddb_readHurricaneFile(handles,filename);
h=findall(gcf,'Tag','HurricaneTrack');
if ~isempty(h)
    delete(h);
end
%set(handles.Pushddb_computeHurricane,'Enable','off');
handles=RefreshAllHurricane(handles);
setHandles(handles);

%%
function PushImport_CallBack(hObject,eventdata)

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.dat', 'Select Track File (Unisys format)','');
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
handles=ddb_readHurricaneFileUnisys(handles,filename);
h=findall(gcf,'Tag','HurricaneTrack');
if ~isempty(h)
    delete(h);
end
%set(handles.Pushddb_computeHurricane,'Enable','off');
handles=RefreshAllHurricane(handles);

setHandles(handles);

%%
function PushDrawTrack_CallBack(hObject,eventdata)

handles=getHandles;

ddb_zoomOff;
h=findobj(gcf,'Tag','HurricaneTrack');
set(h,'HitTest','off');

hnd.t0=floor(now);
hnd.dt=6;
hnd.vmax=20;
hnd.pdrop=1000;

hnd.t0=handles.Toolbox(tb).Input.startTime;
hnd.dt=handles.Toolbox(tb).Input.timeStep;
hnd.vmax=handles.Toolbox(tb).Input.vMax;
hnd.pdrop=handles.Toolbox(tb).Input.pDrop;
hnd.para=handles.Toolbox(tb).Input.parA;
hnd.parb=handles.Toolbox(tb).Input.parB;
hnd.hol=handles.Toolbox(tb).Input.holland;

hnd=ddb_getInitialHurricaneTrackParameters(hnd);

if hnd.ok

    [x,y,h]=UIPolyline(gca,'draw','Tag','HurricaneTrack','Marker','o','Callback',@changeHurricanePolygon,'closed',0);

    [x,y]=DrawPolyline('g',1.5,'o','r');
    if ~isempty(h)
        delete(h);
    end
    if ~isempty(x)

        %     hnd.t0=floor(now);
        %     hnd.dt=6;
        %     hnd.vmax=20;
        %     hnd.pdrop=1000;
        %
        %     hnd.t0=handles.Toolbox(tb).Input.startTime;
        %     hnd.dt=handles.Toolbox(tb).Input.timeStep;
        %     hnd.vmax=handles.Toolbox(tb).Input.vMax;
        %     hnd.pdrop=handles.Toolbox(tb).Input.pDrop;
        %     hnd.para=handles.Toolbox(tb).Input.parA;
        %     hnd.parb=handles.Toolbox(tb).Input.parB;
        %     hnd.hol=handles.Toolbox(tb).Input.holland;
        %
        %     hnd=ddb_getInitialHurricaneTrackParameters(hnd);

        %     if hnd.ok

        handles.Toolbox(tb).Input.startTime=hnd.t0;
        handles.Toolbox(tb).Input.timeStep=hnd.dt;
        handles.Toolbox(tb).Input.vMax=hnd.vmax;
        handles.Toolbox(tb).Input.pDrop=hnd.pdrop;
        handles.Toolbox(tb).Input.parA=hnd.para;
        handles.Toolbox(tb).Input.parB=hnd.parb;

        handles.Toolbox(tb).Input.nrPoint=length(x);
        handles.Toolbox(tb).Input.trX=x;
        handles.Toolbox(tb).Input.trY=y;

        for i=1:handles.Toolbox(tb).Input.nrPoint
            handles.Toolbox(tb).Input.date(i)=hnd.t0+(i-1)*hnd.dt/24;
            if hnd.hol
                handles.Toolbox(tb).Input.par1(i)=vmax;
                handles.Toolbox(tb).Input.par2(i)=pdrop;
            else
                handles.Toolbox(tb).Input.par1(i)=hnd.para;
                handles.Toolbox(tb).Input.par2(i)=hnd.parb;
            end
        end

        DrawHurricaneTrack(handles);

        handles=RefreshAllHurricane(handles);

        setHandles(handles);

    end
end

%%
function PushAddPoint_CallBack(hObject,eventdata)

set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});

%%
function AddPoint(x,y)

ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;

if ~isempty(x)

    handles=getHandles;
    

    handles.Toolbox(tb).Input.nrPoint=handles.Toolbox(tb).Input.nrPoint+1;
    np=handles.Toolbox(tb).Input.nrPoint;

    handles.Toolbox(tb).Input.date(np)=handles.Toolbox(tb).Input.date(np-1)+(handles.Toolbox(tb).Input.date(np-1)-handles.Toolbox(tb).Input.date(np-2));
    handles.Toolbox(tb).Input.trX(np)=x;
    handles.Toolbox(tb).Input.trY(np)=y;
    handles.Toolbox(tb).Input.par1(np)=handles.Toolbox(tb).Input.par1(np-1);
    handles.Toolbox(tb).Input.par2(np)=handles.Toolbox(tb).Input.par2(np-1);

    handles=RefreshAllHurricane(handles);

    setHandles(handles);

end

%%
function RefreshDetailTrack(handles)

npoi=handles.Toolbox(tb).Input.nrPoint;
data=[]
for i=1:npoi
    dat=datestr(handles.Toolbox(tb).Input.date(i),'dd mm yyyy');
    tim=str2double(datestr(handles.Toolbox(tb).Input.date(i),'HH'));
    data{i,1}=dat;
    data{i,2}=tim;
    data{i,3}=handles.Toolbox(tb).Input.trX(i);
    data{i,4}=handles.Toolbox(tb).Input.trY(i);
    data{i,5}=handles.Toolbox(tb).Input.par1(i);
    data{i,6}=handles.Toolbox(tb).Input.par2(i);
end

table(handles.GUIHandles.hurricaneTable,'setdata',data);

DrawHurricaneTrack(handles);

%%
function UpdateTrack

handles=getHandles;

data=table(handles.GUIHandles.hurricaneTable,'getdata');

handles.Toolbox(tb).Input.date=[];
handles.Toolbox(tb).Input.time=[];
handles.Toolbox(tb).Input.lat=[];
handles.Toolbox(tb).Input.lon=[];
handles.Toolbox(tb).Input.par1=[];
handles.Toolbox(tb).Input.par2=[];
for i=1:size(data,1)
    str1=data{i,1};
    str2=data{i,2};
%    handles.Toolbox(tb).Input.date(i)=datenum(str1,'dd mm yyyy')+str2double(str2)/24;
    handles.Toolbox(tb).Input.date(i)=datenum(str1,'dd mm yyyy')+str2/24;
    handles.Toolbox(tb).Input.trX(i) =data{i,3};
    handles.Toolbox(tb).Input.trY(i) =data{i,4};
    handles.Toolbox(tb).Input.par1(i)=data{i,5};
    handles.Toolbox(tb).Input.par2(i)=data{i,6};
end

%set(handles.Pushddb_computeHurricane,'enable','off');
DrawHurricaneTrack(handles);
setHandles(handles);

%%
function handles=RefreshAllHurricane(handles)

set(handles.SelectInputOption,'Value',handles.Toolbox(tb).Input.holland+1);
if handles.Toolbox(tb).Input.holland == 0
    set(handles.TextVmax,'String','max.speed (kts)');
    set(handles.TextPdrop,'String','Pr.drop  (Pa)');
else
    set(handles.TextVmax,'String','A parameter');
    set(handles.TextPdrop,'String','B parameter');
end

npoi = handles.Toolbox(tb).Input.nrPoint;
if npoi > 0
   set(handles.PushSave  ,'Enable','on');
else
   set(handles.PushSave  ,'Enable','off');
end

RefreshDetailTrack(handles);

% if npoi > 0
%    handles.Toolbox(tb).Input.D3d_start = datestr(handles.Toolbox(tb).Input.date{1},'yyyymmdd');
%    handles.Toolbox(tb).Input.D3d_sttime= handles.Toolbox(tb).Input.time{1}*60.;
%    ndate_start = datenum(handles.Toolbox(tb).Input.date{1});
%    ndate_stop  = datenum(handles.Toolbox(tb).Input.date{npoi});
%    handles.Toolbox(tb).Input.D3d_simper= ((ndate_stop - ndate_start)*24. + handles.Toolbox(tb).Input.time{npoi}) * 60. ;
%    
% else
%    handles.Toolbox(tb).Input.D3d_start = ' ';
%    handles.Toolbox(tb).Input.D3d_sttime= 0.;
%    handles.Toolbox(tb).Input.D3d_simper= 0. ;
% end

set(handles.EditInitSpeed,'String',num2str(handles.Toolbox(tb).Input.initSpeed));
set(handles.EditInitDir  ,'String',num2str(handles.Toolbox(tb).Input.initDir));

set(handles.ToggleShowDetails  ,'Value',handles.Toolbox(tb).Input.showDetails);

%%
function DrawHurricaneTrack(handles)

h=findall(gcf,'Tag','HurricaneTrack');
if ~isempty(h)
    delete(h);
end

if handles.Toolbox(tb).Input.nrPoint>0
    z = zeros(handles.Toolbox(tb).Input.nrPoint,1);
    h=plot3(handles.Toolbox(tb).Input.trX,handles.Toolbox(tb).Input.trY,z,'g');
    set(h,'LineWidth',1.5);
    set(h,'Tag','HurricaneTrack');
    set(h,'HitTest','off');
    for i=1:handles.Toolbox(tb).Input.nrPoint
        h=plot3(handles.Toolbox(tb).Input.trX(i),handles.Toolbox(tb).Input.trY(i),200,'ro');
        set(h,'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4);
        set(h,'Tag','HurricaneTrack');
        set(h,'ButtonDownFcn',{@MoveVertex});
        set(h,'UserData',i);
        if handles.Toolbox(tb).Input.showDetails
            tx1=datestr(handles.Toolbox(tb).Input.date(i),'ddmmm');
            tx2=datestr(handles.Toolbox(tb).Input.date(i),'HH');
            tx=[' ' tx1 tx2 '00'];
            tx3=['Vmax ' num2str(handles.Toolbox(tb).Input.par1(i)) 'kt'];
            tx4=['Pdrop ' num2str(handles.Toolbox(tb).Input.par2(i)) 'Pa'];
            tx=strvcat(tx,tx3,tx4);
            txt=text(handles.Toolbox(tb).Input.trX(i),handles.Toolbox(tb).Input.trY(i),tx);
            set(txt,'FontSize',8);
            set(txt,'UserData',i);
            set(txt,'Tag','HurricaneTrack');
            set(txt,'Clipping','on');
        end
    end
end

%%
function MoveVertex(imagefig, varargins)
set(gcf, 'windowbuttonmotionfcn', {@FollowTrack});
set(gcf, 'windowbuttonupfcn',     {@StopTrack});
h=get(gcf,'CurrentObject');
ii=get(h,'UserData');
set(0,'UserData',ii);

%%
function FollowTrack(imagefig, varargins)
handles=getHandles;


pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);
ii=get(0,'UserData');
handles.Toolbox(tb).Input.trX(ii)=xi;
handles.Toolbox(tb).Input.trY(ii)=yi;
DrawHurricaneTrack(handles);
setHandles(handles);
ddb_updateCoordinateText('arrow');

%%
function StopTrack(imagefig, varargins)
ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;
set(0,'UserData',[]);
handles=getHandles;
RefreshDetailTrack(handles);
setHandles(handles);

%%
function MoveMouse(imagefig, varargins)

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(gca,'xlim');
ylim=get(gca,'ylim');
if posx<=xlim(1) || posx>=xlim(2) || posy<=ylim(1) || posy>=ylim(2)
    set(gcf,'WindowButtonDownFcn',[]);
    set(gcf, 'Pointer','arrow');
else
    ClickPoint('xy','Callback',@AddPoint,'single');
end
ddb_updateCoordinateText('arrow');

%%
function PushUnisysWebsite_CallBack(hObject,eventdata)
web http://weather.unisys.com/hurricane -browser
