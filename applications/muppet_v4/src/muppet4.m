clear variables;%close all;

handles.selectfigureoption=1;
handles.muppetversion='4.0';
handles.mode=1;
handles.muppetpath='c:\delft3d\w32\muppet\';
handles.sessionfile='';
handles.currentpath=pwd;
handles.xmldir='c:\work\checkouts\OpenEarthTools\trunk\matlab\applications\muppet4\xml\';

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

handles.animationsettings.frameRate=5;
handles.animationsettings.selectbits=24;
handles.animationsettings.keepfigures=0;
handles.animationsettings.makekmz=0;
handles.animationsettings.avifilename='anim.avi';
handles.animationsettings.prefix='anim';
handles.animationsettings.starttime=datenum(2012,8,18);
handles.animationsettings.stoptime=datenum(2012,8,19);
handles.animationsettings.timestep=3600;

archstr = computer('arch');
switch lower(archstr)
    case{'w32','win32'}
        % win 32
        handles.animationsettings.avioptions.fccHandler=1684633187;
        handles.animationsettings.avioptions.KeyFrames=0;
        handles.animationsettings.avioptions.Quality=10000;
        handles.animationsettings.avioptions.BytesPerSec=300;
        handles.animationsettings.avioptions.Parameters=[99 111 108 114];
    case{'w64','win64'}
        % win 64 - MSVC1
        handles.animationsettings.avioptions.fccHandler=1668707181;
        handles.animationsettings.avioptions.KeyFrames=15;
        handles.animationsettings.avioptions.Quality=7500;
        handles.animationsettings.avioptions.BytesPerSec=300;
        handles.animationsettings.avioptions.Parameters=[75 0 0 0];
end


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

