function muppet_initializegui

% Initialization of GUI settings

handles=getHandles;

% Output options
handles.outputformats={'png','jpeg','tiff','pdf','eps','eps2'};
handles.outputresolutiontexts={'50','100','150','200','300','450','600'};
handles.outputresolutions=[50 100 150 200 300 450 600];
handles.renderers={'ZBuffer','Painters','OpenGL'};

% Color map names
for ii=1:length(handles.colormaps)
    handles.colormapnames{ii}=handles.colormaps(ii).name;
end

% Date formats
dat=datenum(2005,04,28,14,38,25);
for ii=1:length(handles.dateformats)
    handles.dateformattexts{ii}=datestr(dat,handles.dateformats{ii});
end

handles.datasettext1='';
handles.datasettext2='';
handles.datasettext3='';
handles.datasettext4='';
handles.datasettext5='';

handles.lastfiletype='delft3d';

setHandles(handles);
