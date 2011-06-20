function EditTimeSeries

handles=[];

hm=guidata(findobj('Tag','MainWindow'));
m=hm.ActiveModel;

fig0=gcf;
fig=MakeNewWindow('Edit Time Series Plots',[800 400],'modal');

bckcol=get(gcf,'Color');

cltp={'editstring','editstring','checkbox','checkbox','popupmenu','checkbox','popupmenu'};
wdt=[250 100 20 20 100 20 100];
callbacks={@ChangeTable,@ChangeTable,@ChangeTable,@ChangeTable,@ChangeTable,@ChangeTable,@ChangeTable};

if hm.Models(m).NrStations>0
    for i=1:hm.Models(m).NrStations
        data{i,1}=hm.Models(m).Stations(i).Name2;
        data{i,2}=hm.Models(m).Stations(i).Name1;
        data{i,3}=hm.Models(m).Stations(i).Parameters(1).PlotCmp;
        data{i,4}=hm.Models(m).Stations(i).Parameters(1).PlotObs;
        data{i,5}=hm.Models(m).Stations(i).Parameters(1).ObsCode;
        data{i,6}=hm.Models(m).Stations(i).Parameters(1).PlotPrd;
        data{i,7}=hm.Models(m).Stations(i).Parameters(1).PrdCode;
    end
else
    data{1,1}='';
    data{1,2}='';
    data{1,3}=0;
    data{1,4}=0;
    data{1,5}='';
    data{1,6}=0;
    data{1,7}='';
end

nr=hm.NrStations;
k=0;
for i=1:nr
    if strcmpi(hm.Stations(i).Continent,hm.Models(m).Continent)
        k=k+1;
        for j=1:7
            popuptext{k,j}=hm.Stations(i).IDCode;
        end
    end
end
for j=1:7
    popuptext{k+1,j}='none';
end

table2(gcf,'table','create','position',[30 60],'nrrows',10,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'popuptext',popuptext);

for j=1:hm.NrParameters
    handles.Parameters{j}=hm.Parameters(j).LongName;
end
handles.SelectParameter= uicontrol(gcf,'Style','popupmenu','Position',[330 300 100 20],'String',handles.Parameters,'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.LoadObsFile = uicontrol(gcf,'Style','pushbutton','Position',[330 270  100 20],'String','Load Obs File','Tag','UIControl');

handles.PushOK     = uicontrol(gcf,'Style','pushbutton','Position',[400  30  70 20],'String','OK','Tag','UIControl');
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','Position',[320  30  70 20],'String','Cancel','Tag','UIControl');

set(handles.PushOK     ,'CallBack',{@PushOK_CallBack});
set(handles.PushCancel ,'CallBack',{@PushCancel_CallBack});
set(handles.LoadObsFile ,'CallBack',{@LoadObsFile_CallBack});
set(handles.SelectParameter ,'CallBack',{@SelectParameter_CallBack});

handles.Models=hm.Models(m);

guidata(gcf,handles);

RefreshAll(handles);

%%
function PushOK_CallBack(hObject,eventdata)
handles=guidata(gcf);
hm=guidata(findobj('Tag','MainWindow'));
hm.Models(hm.ActiveModel).NrStations=handles.Models.NrStations;
hm.Models(hm.ActiveModel).Stations=handles.Models.Stations;
guidata(findobj('Tag','MainWindow'),hm);
close(gcf);

%%
function PushCancel_CallBack(hObject,eventdata)
close(gcf);

%%
function LoadObsFile_CallBack(hObject,eventdata)

hm=guidata(findobj('Tag','MainWindow'));

handles=guidata(gcf);

[filename, pathname, filterindex] = uigetfile('*.obs', 'Select Observation Points File');

if pathname~=0

    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end

    m=[];
    n=[];
    name=[];

    [name,m,n] = textread(filename,'%21c%f%f');

    [filename, pathname, filterindex] = uigetfile('*.ann', 'Select Annotation File');
    annfile=[pathname filename];

    if pathname~=0

        fid=fopen(annfile);
        k=0;
        for j=1:1000
            tx0=fgets(fid);
            if and(ischar(tx0), size(tx0>0))
                v0=strread(tx0,'%q');
%                if ~strcmp(v0{1}(1),'#')
                    k=k+1;
                    x(k)=str2num(v0{2});
                    y(k)=str2num(v0{3});
%                end

            end
        end
        fclose(fid);

        handles.Models.Stations=[];
        handles.Models.NrStations=length(m);

        for i=1:length(m)
            handles.Models.Stations(i).Name1=deblank(name(i,:));
            handles.Models.Stations(i).Name2=deblank(name(i,:));
            handles.Models.Stations(i).M=m(i);
            handles.Models.Stations(i).N=n(i);
            handles.Models.Stations(i).Location(1)=x(i);
            handles.Models.Stations(i).Location(2)=y(i);

            for k=1:hm.NrParameters
                handles.Models.Stations(i).Parameters(k).PlotCmp=0;
                handles.Models.Stations(i).Parameters(k).PlotObs=0;
                handles.Models.Stations(i).Parameters(k).PlotPrd=0;
            end

        end
        guidata(gcf,handles);
        RefreshAll(handles);
    end
end

%%
function RefreshAll(handles)

hm=guidata(findobj('Tag','MainWindow'));
nr=hm.NrStations;

ii=get(handles.SelectParameter,'Value');

data{1,1}='';
data{1,2}=0;
data{1,3}=0;
data{1,4}=0;

for i=1:handles.Models.NrStations
    data{i,1}=handles.Models.Stations(i).Name2;
    data{i,2}=handles.Models.Stations(i).Name1;
    data{i,3}=handles.Models.Stations(i).Parameters(ii).PlotCmp;
    data{i,4}=handles.Models.Stations(i).Parameters(ii).PlotObs;
    data{i,5}=handles.Models.Stations(i).Parameters(ii).ObsCode;
    data{i,6}=handles.Models.Stations(i).Parameters(ii).PlotPrd;
    data{i,7}=handles.Models.Stations(i).Parameters(ii).PrdCode;
end

table2(gcf,'table','change','data',data);

%%
function ChangeTable

handles=guidata(gcf);

hm=guidata(findobj('Tag','MainWindow'));
nr=hm.NrStations;
for i=1:nr
    if strcmpi(hm.Stations(i).Continent,handles.Models.Continent)
        stations{i}=hm.Stations(i).IDCode;
    end
end

data=table2(gcf,'table','getdata');
ii=get(handles.SelectParameter,'Value');

for i=1:handles.Models.NrStations
    handles.Models.Stations(i).Name2=data{i,1};
    handles.Models.Stations(i).Name1=data{i,2};
    handles.Models.Stations(i).Parameters(ii).PlotCmp=data{i,3};
    handles.Models.Stations(i).Parameters(ii).PlotObs=data{i,4};
    handles.Models.Stations(i).Parameters(ii).ObsCode=data{i,5};
    handles.Models.Stations(i).Parameters(ii).PlotPrd=data{i,6};
    handles.Models.Stations(i).Parameters(ii).PrdCode=data{i,7};
end
guidata(gcf,handles);

%%
function SelectParameter_CallBack(hObject,eventdata)
handles=guidata(gcf);
RefreshAll(handles);
