clear variables;%close all;

handles.selectfigureoption=1;
handles.muppetversion='4.0';
handles.mode=1;
handles.muppetpath='c:\delft3d\w32\muppet\';
handles.sessionfile='';
handles.currentpath=pwd;
handles.xmldir='c:\work\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\xml\';

handles=muppet_readXmlFiles(handles);

handles=muppet_getCoordinateSystems(handles);

% Date formats
dat=datenum(2005,04,28,14,38,25);
handles.dateformats=muppet_readDateFormats('c:\delft3d\w32\muppet\settings\defaults\dateformats.def');
for ii=1:length(handles.dateformats)
    handles.dateformattexts{ii}=datestr(dat,handles.dateformats{ii});
end

% Colors
pth='c:\delft3d\w32\muppet\';
handles.colormaps=muppet_importColorMaps(pth);
for ii=1:length(handles.colormaps)
    handles.colormapnames{ii}=handles.colormaps(ii).name;
end

handles.outputformats={'png','jpeg','tiff','pdf','eps','eps2'};
handles.outputresolutiontexts={'50','100','150','200','300','450','600'};
handles.outputresolutions=[50 100 150 200 300 450 600];
handles.renderers={'ZBuffer','Painters','OpenGL'};

handles=muppet_initializeAnimationSettings(handles);

handles.nrdatasets=0;
handles.nrcombineddatasets=0;

handles.datasettext={'',''};
handles.datasetnames={''};

handles.nrfigures=1;
handles.figures(1).figure=muppet_setDefaultFigureProperties(handles);

for ii=1:length(handles.nrfigures)
    handles.figurenames{ii}=handles.figures(ii).figure.name;
end

for ii=1:1
    handles=muppet_initializeSubplot(handles,1,ii);
end

handles.figures(1).figure.subplots(1).subplot.name='abc';
handles.figures(1).figure.subplots(1).subplot.nrdatasets=0;
handles.figures(1).figure.subplots(1).subplot.activedataset=1;
handles.figures(1).figure.subplots(1).subplot.type='unknown';
handles.figures(1).figure.subplots(1).subplot.position=[2 2 15 10];

handles.activedataset=1;
handles.activefigure=1;
handles.activesubplot=1;
handles.activedatasetinsubplot=1;

for id=1:handles.nrdatasets
    handles.datasetnames{id}=handles.datasets(id).dataset.name;    
end
for id=1:handles.figures(1).figure.nrsubplots
    handles.subplotnames{id}=handles.figures(1).figure.subplots(id).subplot.name;
end
handles=muppet_updateDatasetInSubplotNames(handles);

setHandles(handles);

muppet_gui;

handles=muppet_refreshColorMap(handles);

