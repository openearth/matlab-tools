function muppet_gui(varargin)

if isempty(varargin)
    newSession('firsttime');
    handles=getHandles;
    gui_newWindow(handles,'xmldir',handles.xmldir,'xmlfile','muppetgui.xml','modal',0, ...
        'getfcn',@getHandles,'setfcn',@setHandles,'tag','muppetgui','Color',[0.941176 0.941176 0.941176]);
    muppet_refreshColorMap(handles);
    muppet_updateGUI;
else
    opt=lower(varargin{1});
    switch opt
        case{'newsession'}
            newSession;
        case{'opensession'}
            openSession;
        case{'savesession'}
            saveSession;
        case{'savesessionas'}
            saveSessionAs;
        case{'adddatasetfromurl'}
            addDatasetfromURL;
        case{'importlayout'}
            importLayout;
        case{'savelayout'}            
            exportLayout;
        case{'exit'}
            close(gcf);
        case{'reloadxml'}
            reloadXmlFiles;
        case{'selectdataset'}
            selectDataset;
        case{'adddataset'}
            addDataset;
        case{'deletedataset'}
            deleteDataset;
        case{'adddatasettosubplot'}
            addDatasetToSubplot;
        case{'selectsubplot'}
            selectSubplot;
        case{'addsubplot'}
            addSubplot;
        case{'deletesubplot'}
            deleteSubplot;
        case{'moveupsubplot'}
            moveUpSubplot;
        case{'movedownsubplot'}
            moveDownSubplot;
        case{'selectdatasetinsubplot'}
            selectDatasetInSubplot;
        case{'editplotoptions'}
            editPlotOptions;
        case{'removedatasetinsubplot'}
            removeDatasetInSubplot;
        case{'moveupdatasetinsubplot'}
            moveUpDatasetInSubplot;
        case{'movedowndatasetinsubplot'}
            moveDownDatasetInSubplot;
        case{'applytoallaxes'}            
            applyToAllAxes;
        case{'toggleaxesequal'}            
            toggleAxesEqual;
        case{'editxylim'}
            editXYLim(varargin{2});
        case{'selectcoordinatesystem'}
            selectCoordinateSystem;
        case{'editlegend'}
            editLegend;
        case{'editvectorlegend'}
            editVectorLegend;
        case{'togglecolorbar'}
            toggleColorBar;
        case{'editcolorbar'}
            editColorBar;
        case{'togglevectorlegend'}
            toggleVectorLegend;
        case{'togglenortharrow'}
            toggleNorthArrow;
        case{'editnortharrow'}
            editNorthArrow;
        case{'togglescalebar'}
            toggleScaleBar;
        case{'editscalebar'}
            editScaleBar;
        case{'editclim'}
            editCLim;
        case{'editframetext'}
            editFrameText;
        case{'selectformat'}
            selectFormat;
        case{'selectportrait','selectlandscape'}
            selectOrientation;
        case{'exportfigure'}
            exportFigure;
        case{'plotfigure'}
            plotFigure;
        case{'editanimationsettings'}
            editAnimationSettings;
        case{'makeanimation'}
            makeAnimation;
    end
end

%%
function newSession(varargin)
if isempty(varargin)
    % gui already open
    iopt=1;
else
    % gui has not yet been opened
    iopt=0;
end
handles=getHandles;
filename=[handles.settingsdir 'layouts' filesep 'default.mup'];
handles.sessionfile='';
[handles,ok]=muppet_newSession(handles,filename);
if ok
    handles=muppet_updateDatasetNames(handles);
    handles=muppet_updateFigureNames(handles);
    handles=muppet_updateSubplotNames(handles);
    handles=muppet_updateDatasetInSubplotNames(handles);
    handles=muppet_initializeAnimationSettings(handles);
    setHandles(handles);    
    if iopt
        muppet_refreshColorMap(handles);
        selectDataset;
        muppet_updateGUI;
    end
end

%%
function openSession
handles=getHandles;
[filename pathname]=uigetfile('*.mup');
if pathname~=0
    handles.sessionfile=filename;
    cd(pathname);
    [handles,ok]=muppet_newSession(handles,[pathname filename]);
    if ok
        handles=muppet_updateDatasetNames(handles);
        handles=muppet_updateSubplotNames(handles);
        handles=muppet_updateDatasetInSubplotNames(handles);
        % Compute scale of 2d map plots
        for ifig=1:handles.nrfigures
            for isub=1:handles.figures(ifig).figure.nrsubplots
                switch lower(handles.figures(ifig).figure.subplots(isub).subplot.type)
                    case{'map2d'}
                        handles.figures(ifig).figure.subplots(isub).subplot=muppet_updateLimits(handles.figures(ifig).figure.subplots(isub).subplot,'computescale');
                end
            end
        end        
        setHandles(handles);
        selectDataset;
        muppet_updateGUI;
    end
else
    return
end

%%
function saveSession
handles=getHandles;
if isempty(handles.sessionfile)
    [filename pathname]=uiputfile('*.mup');
    if pathname~=0
        handles.sessionfile=[pathname filename];
        setHandles(handles);
    else
      return
    end
end
muppet_saveSessionFile(handles,handles.sessionfile,0);


%%
function saveSessionAs
handles=getHandles;
[filename pathname]=uiputfile('*.mup');
if pathname~=0
  handles.sessionfile=[pathname filename];
  setHandles(handles);
  muppet_saveSessionFile(handles,handles.sessionfile,0);
end

%%
function addDatasetfromURL
handles = getHandles;
handles=muppet_datasetURL_GUI(handles,[1 1 5 5],0);
selectDataset;

%%
function importLayout

handles=getHandles;
[filename pathname]=uigetfile([handles.settingsdir 'layouts' filesep '*.mup']);
if pathname~=0
    handles.nrfigures=0;
    handles.figures=[];
    handles.activefigure=1;
    handles.activesubplot=1;
    handles.activedatasetinsubplot=1;
    [handles,ok]=muppet_readSessionFile(handles,filename,1);    
    handles=muppet_updateSubplotNames(handles);
    handles=muppet_updateDatasetInSubplotNames(handles);
    setHandles(handles);
    muppet_updateGUI;
else
    return
end

%%
function exportLayout

handles=getHandles;
[filename pathname]=uiputfile([handles.settingsdir 'layouts' filesep '*.mup']);
if pathname~=0
    sessionfile=[pathname filename];
    muppet_saveSessionFile(handles,sessionfile,1);
else
    return
end

%%
function reloadXmlFiles
handles=getHandles;
handles=muppet_readXmlFiles(handles);
setHandles(handles);

%%
function selectDataset
handles=getHandles;
if handles.nrdatasets>0
    idtype=muppet_findIndex(handles.datatype,'datatype','name',handles.datasets(handles.activedataset).dataset.type);
    [pathname,filename,ext]=fileparts(handles.datasets(handles.activedataset).dataset.filename);
    currentpath=pwd;
    if ~strcmpi(currentpath,pathname)
        filename=[pathname filename ext];
    else
        filename=[filename ext];
    end
    txt1=['Name : ' handles.datasets(handles.activedataset).dataset.name];
    txt2=['File: ' filename];
    txt3=['Type : ' handles.datatype(idtype).datatype.longname];
    if isempty(handles.datasets(handles.activedataset).dataset.time)
        txt4='';
    else
        txt4=['Time : ' datestr(handles.datasets(handles.activedataset).dataset.time)];
    end
    txt5='';
else
    txt1='';
    txt2='';
    txt3='';
    txt4='';
    txt5='';
end
handles.datasettext1=txt1;
handles.datasettext2=txt2;
handles.datasettext3=txt3;
handles.datasettext4=txt4;
handles.datasettext5=txt5;
setHandles(handles);

%%
function addDataset

handles=getHandles;

ilast=strmatch(lower(handles.lastfiletype),lower(handles.filetypes),'exact');
filterspec{1,1}=handles.filetype(ilast).filetype.filterspec;
filterspec{1,2}=handles.filetype(ilast).filetype.title;

filetypes{1}=handles.filetype(ilast).filetype.name;

n=1;
for ii=1:length(handles.filetype)
    if ii~=ilast
        if isfield(handles.filetype(ii).filetype,'filterspec')
            n=n+1;
            filetypes{n}=handles.filetype(ii).filetype.name;
            filterspec{n,1}=handles.filetype(ii).filetype.filterspec;
            filterspec{n,2}=handles.filetype(ii).filetype.title;
        end
    end
end

[filename, pathname, filterindex] = uigetfile(filterspec);

if pathname~=0
    handles.lastfiletype=filetypes{filterindex};
    setHandles(handles);
    muppet_datasetGUI('makewindow','filename',[pathname filename],'filetype',filetypes{filterindex});
    selectDataset;
end

%%
function deleteDataset
handles=getHandles;
name=handles.datasets(handles.activedataset).dataset.name;
% Check if dataset is used in any subplot
ok=1;
for ifig=1:handles.nrfigures
    if ok
        for isub=1:handles.figures(ifig).figure.nrsubplots
            if handles.figures(ifig).figure.subplots(isub).subplot.nrdatasets>0
                id=muppet_findIndex(handles.figures(ifig).figure.subplots(isub).subplot.datasets,'dataset','name',name);
                if ~isempty(id)
                    ok=0;
                    muppet_giveWarning('text','Cannot delete this dataset as it is used in a subplot!');
                    break
                end
            end
        end
    else
        break
    end
end
if ok
    [handles.datasets handles.activedataset handles.nrdatasets] = UpDownDeleteStruc(handles.datasets, handles.activedataset, 'delete');
    handles=muppet_updateDatasetNames(handles);
    setHandles(handles);
    selectDataset;
end

%%
function addDatasetToSubplot
handles=getHandles;
handles=muppet_addDatasetToSubplot(handles);
setHandles(handles);

%%
function selectSubplot
handles=getHandles;
handles=muppet_updateDatasetInSubplotNames(handles);
handles.activedatasetinsubplot=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.activedataset;
muppet_refreshColorMap(handles);
txt1=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.coordinatesystem.name;
txt2=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.coordinatesystem.type;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.coordinatesystem.text=[txt1 ' - ' txt2];
setHandles(handles);

%%
function addSubplot
handles=getHandles;
handles=muppet_addSubplot(handles,[1 1 5 5],0);
setHandles(handles);

%%
function deleteSubplot
handles=getHandles;
iplt=handles.activesubplot;
if strcmpi(handles.figures(handles.activefigure).figure.subplots(iplt).subplot.type,'annotation')
    handles.figures(handles.activefigure).figure.nrannotations=0;
end
[handles.figures(handles.activefigure).figure.subplots iplt nrsub] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots, iplt, 'delete');
handles.figures(handles.activefigure).figure.nrsubplots=nrsub;
handles.figures(handles.activefigure).figure.activesubplot=iplt;
handles.activesubplot=iplt;
handles.activedatasetinsubplot=1;
if nrsub>0
    handles.activedatasetinsubplot=handles.figures(handles.activefigure).figure.subplots(iplt).subplot.activedataset;
else
    handles.activesubplot=1;
    handles=muppet_initializeSubplot(handles,handles.activefigure,1);
end
handles=muppet_updateSubplotNames(handles);
handles=muppet_updateDatasetInSubplotNames(handles);
muppet_refreshColorMap(handles);
setHandles(handles);

%%
function moveUpSubplot
handles=getHandles;
iplt=handles.activesubplot;
[handles.figures(handles.activefigure).figure.subplots iplt nrsub] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots, iplt, 'up');
handles.figures(handles.activefigure).figure.nrsubplots=nrsub;
handles.figures(handles.activefigure).figure.activesubplot=iplt;
handles.activesubplot=iplt;
handles.activedatasetinsubplot=1;
if nrsub>0
    handles.activedatasetinsubplot=handles.figures(handles.activefigure).figure.subplots(iplt).subplot.activedataset;
end
handles=muppet_updateSubplotNames(handles);
handles=muppet_updateDatasetInSubplotNames(handles);
setHandles(handles);

%%
function moveDownSubplot
handles=getHandles;
iplt=handles.activesubplot;
[handles.figures(handles.activefigure).figure.subplots iplt nrsub] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots, iplt, 'down');
handles.figures(handles.activefigure).figure.nrsubplots=nrsub;
handles.figures(handles.activefigure).figure.activesubplot=iplt;
handles.activesubplot=iplt;
handles.activedatasetinsubplot=1;
if nrsub>0
    handles.activedatasetinsubplot=handles.figures(handles.activefigure).figure.subplots(iplt).subplot.activedataset;
end
handles=muppet_updateSubplotNames(handles);
handles=muppet_updateDatasetInSubplotNames(handles);
setHandles(handles);

%%
function selectDatasetInSubplot
% Select dataset in subplot
handles=getHandles;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.activedataset=handles.activedatasetinsubplot;
setHandles(handles);

%%
function editPlotOptions
handles=getHandles;
handles=muppet_editPlotOptions(handles);
setHandles(handles);

%%
function removeDatasetInSubplot
% Remove selected dataset from subplot
handles=getHandles;
id=handles.activedatasetinsubplot;
[handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets id nrd] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets, id, 'delete');
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.nrdatasets=nrd;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.activedataset=id;
handles.activedatasetinsubplot=id;
switch handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.type
    case{'annotation'}
        handles.figures(handles.activefigure).figure.nrannotations=handles.figures(handles.activefigure).figure.nrannotations-1;
end
handles=muppet_updateDatasetInSubplotNames(handles);
idelplot=0;
if nrd==0
    handles.activedatasetinsubplot=1;
    switch handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.type
        case{'annotation'}
            idelplot=1;
        otherwise
            handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=muppet_setDefaultAxisProperties(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot);
            handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.type='unknown';
    end
end
setHandles(handles);
if idelplot
    deleteSubplot;
end

%%
function moveUpDatasetInSubplot
handles=getHandles;
id=handles.activedatasetinsubplot;
[handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets id nrd] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets, id, 'up');
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.nrdatasets=nrd;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.activedataset=id;
handles.activedatasetinsubplot=id;
handles=muppet_updateDatasetInSubplotNames(handles);
setHandles(handles);

%%
function moveDownDatasetInSubplot
handles=getHandles;
id=handles.activedatasetinsubplot;
[handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets id nrd] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets, id, 'down');
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.nrdatasets=nrd;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.activedataset=id;
handles.activedatasetinsubplot=id;
handles=muppet_updateDatasetInSubplotNames(handles);
setHandles(handles);

%%
function applyToAllAxes
handles=getHandles;
handles=muppet_applyToAllAxes(handles);
setHandles(handles);

%%
function toggleAxesEqual
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
if handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.axesequal==0
  handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.scale=[];
else
  scale=muppet_computeScale([plt.xmin plt.xmax],[plt.ymin plt.ymax],[plt.position(3) plt.position(4)],plt.coordinatesystem.type);
  handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.scale=scale;
end
setHandles(handles);

%%
function selectCoordinateSystem
handles=getHandles;
cs0=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.coordinatesystem.name;
tp0=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.coordinatesystem.type;
[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default',cs0,'defaulttype',tp0,'type','both');
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.coordinatesystem.name=cs;
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.coordinatesystem.type=type;
    switch type
        case{'geographic'}
        case{'projected'}
            handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.projection='equirectangular';
    end
    setHandles(handles);
end

%%
function editXYLim(opt)
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
switch lower(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.type)
    case{'map2d'}
        plt=muppet_updateLimits(plt,opt);
        handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
setHandles(handles);

%%
function editLegend
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.legend;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmldir, 'xmlfile', 'legend.xml');
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.legend=s;
    setHandles(handles);
end

%%
function editVectorLegend
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.vectorlegend;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmldir, 'xmlfile', 'vectorlegend.xml');
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.vectorlegend=s;
    setHandles(handles);
end

%%
function toggleColorBar
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
if isempty(plt.colorbar.position)
    % No colorbar yet
    x0=plt.position(1)+plt.position(3)-2.0;
    y0=plt.position(2)+1.0;
    x1=0.5;
    y1=plt.position(4)-2.0;
    plt.colorbar.position=[x0 y0 x1 y1];
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
setHandles(handles);

%%
function editColorBar
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.colorbar;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmldir, 'xmlfile', 'colorbar.xml');
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.colorbar=s;
    setHandles(handles);
end

%%
function toggleVectorLegend
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
if isempty(plt.vectorlegend.position)
    % No vector legend yet
    x0=plt.position(1)+1.0;
    y0=plt.position(2)+1.0;
    plt.vectorlegend.position=[x0 y0];
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
setHandles(handles);

%%
function toggleNorthArrow
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
if isempty(plt.northarrow.position)
    % No position data available
    x0=1.5;
    y0=plt.position(4)-1.5;
    sz=1.0;
    angle=90;
    plt.northarrow.position=[x0 y0 sz angle];
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
setHandles(handles);

%%
function editNorthArrow
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.northarrow;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmldir, 'xmlfile', 'northarrow.xml');
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.northarrow=s;
    setHandles(handles);
end


%%
function toggleScaleBar
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
if isempty(plt.scalebar.position)
    % No position data available
    x0=1.5;
    y0=1.5;
    z0=round(0.04*plt.scale);
    plt.scalebar.position=[x0 y0];
    plt.scalebar.length=z0;
    plt.scalebar.text=[num2str(z0) ' m'];
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
setHandles(handles);

%%
function editScaleBar
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.scalebar;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmldir, 'xmlfile', 'scalebar.xml');
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.scalebar=s;
    setHandles(handles);
end

%%
function editCLim
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
cdif=plt.cmax-plt.cmin;
cmin=plt.cmin;
cmax=plt.cmax;
cstep=plt.cstep;

if cmax<=cmin || cstep>cdif || cstep<0.01*cdif
%     set(handles.EditCMin,'BackgroundColor',[1 0 0]);
%     set(handles.EditCMax,'BackgroundColor',[1 0 0]);
%     set(handles.EditCStep,'BackgroundColor',[1 0 0]);
else
%     set(handles.EditCMin,'BackgroundColor',[1 1 1]);
%     set(handles.EditCMax,'BackgroundColor',[1 1 1]);
%     set(handles.EditCStep,'BackgroundColor',[1 1 1]);
    muppet_refreshColorMap(handles);
end

setHandles(handles);

%%
function editFrameText
handles=getHandles;
fig=handles.figures(handles.activefigure).figure;
[fig,ok]=muppet_selectFrameText(fig);
if ok
    handles.figures(handles.activefigure).figure=fig;
    setHandles(handles);
end

%%
function selectOrientation
handles=getHandles;
fig=handles.figures(handles.activefigure).figure;
width=fig.width;
height=fig.height;
fig.width=height;
fig.height=width;
% Subplots
for isub=1:fig.nrsubplots
    if strcmpi(fig.orientation(1),'l')
        pos(1)=fig.subplots(isub).subplot.position(2);
        pos(2)=fig.height-(fig.subplots(isub).subplot.position(1)+fig.subplots(isub).subplot.position(3));
        pos(3)=fig.subplots(isub).subplot.position(4);
        pos(4)=fig.subplots(isub).subplot.position(3);
    else
        pos(1)=fig.width-(fig.subplots(isub).subplot.position(2)+fig.subplots(isub).subplot.position(4));
        pos(2)=fig.subplots(isub).subplot.position(1);
        pos(3)=fig.subplots(isub).subplot.position(4);
        pos(4)=fig.subplots(isub).subplot.position(3);
    end
    fig.subplots(isub).subplot.position=pos;
end
% Annotations
for j=1:fig.nrannotations
    isub=fig.nrsubplots;
    if strcmpi(fig.orientation(1),'l')
        pos(1)=fig.subplots(isub).subplot.datasets(j).dataset.position(2);
        pos(2)=fig.height-fig.subplots(isub).subplot.datasets(j).dataset.position(1);
        pos(3)=fig.subplots(isub).subplot.datasets(j).dataset.position(4);
        pos(4)=-fig.subplots(isub).subplot.datasets(j).dataset.position(3);
    else
        pos(1)=fig.width-fig.subplots(isub).subplot.datasets(j).dataset.position(2);
        pos(2)=fig.subplots(isub).subplot.datasets(j).dataset.position(1);
        pos(3)=-fig.subplots(isub).subplot.datasets(j).dataset.position(4);
        pos(4)=fig.subplots(isub).subplot.datasets(j).dataset.position(3);
    end
    switch fig.subplots(isub).subplot.datasets(j).dataset.plotroutine
        case{'textbox','rectangle','ellipse'}
            pos(1)=min(pos(1),pos(1)+pos(3));
            pos(2)=min(pos(2),pos(2)+pos(4));
            pos(3)=abs(pos(3));
            pos(4)=abs(pos(4));
    end
    fig.subplots(isub).subplot.datasets(j).dataset.position=pos;
end        
handles.figures(handles.activefigure).figure=fig;
setHandles(handles);

%%
function selectFormat
handles=getHandles;
name=handles.figures(handles.activefigure).figure.outputfile(1:end-4);
switch lower(handles.figures(handles.activefigure).figure.format)
    case {'png'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.png'];
    case {'jpeg'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.jpg'];
    case {'tiff'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.tif'];
    case {'pdf'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.pdf'];
    case {'eps'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.eps'];
    case {'eps2'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.ps2'];
end
setHandles(handles);

%%
function exportFigure
handles=getHandles;
muppet_exportFigure(handles,handles.activefigure,'export');

%%
function plotFigure
muppet_preview;

%%
function editAnimationSettings
muppet_animationSettings;

%%
function makeAnimation
handles=getHandles;
muppet_makeAnimation(handles,handles.activefigure);
