function ddb_TilingBathymetry

ddb_refreshScreen('Toolbox','Bathymetry');

handles=getHandles;

ddb_plotTiling(handles,'activate');

handles.GUIHandles.pushSelectFile = uicontrol(gcf,'Style','pushbutton','String','Select ArcInfo File','Position',   [60 120 100  20],'Tag','UIControl');
handles.GUIHandles.textFile=uicontrol(gcf,'Style','text','String',['File : ' handles.Toolbox(tb).fileName], 'Position',  [170 116 750  20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.editX0=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).x0), 'Position',  [60 95 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editY0=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).y0), 'Position',  [130 95 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editNX=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).nx), 'Position',  [60 70 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editNY=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).ny), 'Position',  [130 70 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editNrZoom=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).nrZoom), 'Position',  [60 45 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.editDataName=uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).dataName, 'Position',  [200 95 100  20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.editDataDir =uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).dataDir,  'Position',  [200 70 400  20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.pushGenerateTiles = uicontrol(gcf,'Style','pushbutton','String','Generate Tiles','Position',   [850 30 100  20],'Tag','UIControl');

set(handles.GUIHandles.editNX,'Callback',{@editNX_Callback});
set(handles.GUIHandles.editNY,'Callback',{@editNY_Callback});
set(handles.GUIHandles.editX0,'Callback',{@editX0_Callback});
set(handles.GUIHandles.editY0,'Callback',{@editY0_Callback});
set(handles.GUIHandles.editNrZoom,'Callback',{@editNrZoom_Callback});

set(handles.GUIHandles.editDataName,'Callback',{@editDataName_Callback});
set(handles.GUIHandles.editDataDir,'Callback',{@editDataDir_Callback});

set(handles.GUIHandles.pushSelectFile,'Callback',{@pushSelectFile_Callback});
set(handles.GUIHandles.pushGenerateTiles,'Callback',{@pushGenerateTiles_Callback});

SetUIBackgroundColors;

setHandles(handles);

%%
function pushSelectFile_Callback(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.*', 'Select ArcInfo Bathymetry File');
if ~pathname==0
    handles.Toolbox(tb).fileName=[pathname filename];
    [ncols,nrows,x0,y0,cellsz]=readArcInfo([pathname filename],'info');

    handles.Toolbox(tb).x0=x0;
    handles.Toolbox(tb).y0=y0;
    
    set(handles.GUIHandles.editX0,'String',num2str(x0));
    set(handles.GUIHandles.editY0,'String',num2str(y0));

    if ncols>500 && nrows>500
        handles.Toolbox(tb).nx=300;
        handles.Toolbox(tb).ny=300;
        zm=1:50;
        nnx=ncols./(handles.Toolbox(tb).nx.*2.^(zm-1));
        nny=nrows./(handles.Toolbox(tb).ny.*2.^(zm-1));
        iix=find(nnx>1,1,'last');
        iiy=find(nny>1,1,'last');
        handles.Toolbox(tb).nrZoom=max(iix,iiy);
    else
        handles.Toolbox(tb).nx=ncols;
        handles.Toolbox(tb).ny=nrows;
        handles.Toolbox(tb).nrZoom=1;
    end

    set(handles.GUIHandles.editNX,'String',num2str(handles.Toolbox(tb).nx));
    set(handles.GUIHandles.editNY,'String',num2str(handles.Toolbox(tb).ny));
    set(handles.GUIHandles.editNrZoom,'String',num2str(handles.Toolbox(tb).nrZoom));
    set(handles.GUIHandles.textFile,'String',['File : ' pathname filename]);
end
setHandles(handles);

%%
function pushGenerateTiles_Callback(hObject,eventdata)
handles=getHandles;

OPT.EPSGcode                     = 32604;
OPT.EPSGname                     = 'WGS 84 / UTM zone 4N';
OPT.EPSGtype                     = 'projected';
OPT.VertCoordName                = 'NAVD88';
OPT.VertCoordLevel               = 0.0;
OPT.Conventions                  = 'CF-1.4';
OPT.CF_featureType               = 'grid';
OPT.title                        = 'Hawaii';
OPT.institution                  = 'USGS';
OPT.source                       = 'Curt Storlazzi';
OPT.history                      = 'created by Maarten van Ormondt (18-Jul-2010)';
OPT.references                   = 'No reference material available';
OPT.comment                      = 'none';
OPT.email                        = 'Maarten.vanOrmondt@deltares.nl';
OPT.version                      = '1.0';
OPT.terms_for_use                = 'Use as you like';
OPT.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
OPT.nc_library                   = 'matlab';
OPT.coordsystype='geo';
OPT.tp='float';

fname=handles.Toolbox(tb).fileName;
dr=[handles.Toolbox(tb).dataDir filesep handles.Toolbox(tb).dataName filesep];
dataname=handles.Toolbox(tb).dataName;
nrzoom=handles.Toolbox(tb).nrZoom;
nx=handles.Toolbox(tb).nx;
ny=handles.Toolbox(tb).ny;

wb = waitbox('Generating Tiles ...'); 
makeNCBathyTiles(fname,dr,dataname,nrzoom,nx,ny,OPT);
close(wb);

%%
function PushLoadModel_Callback(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.xml', 'Select model XML file');
if ~pathname==0
    fname=[pathname filename];
    handles=ddb_readOMSModelData(handles,fname);
    ddb_plotOMSStations(handles);
    PlotModelLimits(handles);
    Refresh(handles);
end
setHandles(handles);

%%
function SelectContinent_Callback(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
ii=get(hObject,'Value');
handles.Toolbox(tb).Continent=str{ii};
setHandles(handles);

%%
function EditXLim1_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).XLim(1)=str2double(get(hObject,'String'));
PlotModelLimits(handles);
setHandles(handles);

%%
function editX0_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).x0=str2double(get(hObject,'String'));
setHandles(handles);

%%
function editY0_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).y0=str2double(get(hObject,'String'));
setHandles(handles);

%%
function editNX_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).nx=str2double(get(hObject,'String'));
setHandles(handles);

%%
function editNY_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).ny=str2double(get(hObject,'String'));
setHandles(handles);

%%
function editNrZoom_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).nrZoom=str2double(get(hObject,'String'));
setHandles(handles);

%%
function editDataName_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).dataName=get(hObject,'String');
setHandles(handles);

%%
function editDataDir_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).dataDir=get(hObject,'String');
setHandles(handles);

