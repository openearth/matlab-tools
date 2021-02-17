function ddb_shorelines_numerics(varargin)

%%
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_plotshorelines('update','active',1,'visible',1);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectspitoption'}
            select_spit_option;
        case{'selectfromlist'}
            select_from_list;
        case{'drawchannel'}
            draw_channel;
        case{'deletechannel'}
            delete_channel;
        case{'loadchannels'}
            load_channels;
        case{'savechannels'}
            save_channels;
            
    end
    
end

%%
function select_spit_option

handles=getHandles;
opt=handles.model.shorelines.domain.spit_opt;
%ddb_giveWarning('text',['Thank you for selecting spit option ' opt]);
setHandles(handles);
%%
function select_from_list

handles=getHandles;

handles = ddb_shorelines_plot_channel(handles, 'plot');

setInstructions({'','Click on map to draw channel in seaward direction','Use right-click to end channel'});
setHandles(handles);

%%
function draw_channel

handles=getHandles;

gui_polyline('draw','axis',handles.GUIHandles.mapAxis,'tag','channels_tmp','marker','o', ...
    'createcallback',@create_channel, ...
    'linecolor','g','closed',0);

setInstructions({'','Click on map to draw channel','Use right-click to end channel'});

setHandles(handles);

%%
function create_channel(h,x,y)

handles=getHandles;

% Delete temporary channel

delete(h);
handles.model.shorelines.domain.nrchannels=handles.model.shorelines.domain.nrchannels+1;
handles.model.shorelines.domain.activechannel=handles.model.shorelines.domain.nrchannels;
as=handles.model.shorelines.domain.activechannel;
handles.model.shorelines.domain.channels(as).x=x;
handles.model.shorelines.domain.channels(as).y=y;
handles.model.shorelines.domain.channelnames{as}=['channel ',num2str(as)];
handles.model.shorelines.domain.channels(as).name=['channel ',num2str(as)];
handles.model.shorelines.domain.channels(as).length=length(handles.model.shorelines.domain.channels(as).x);
handles = ddb_shorelines_plot_channel(handles, 'plot');
handles.model.shorelines.status='waiting';

setHandles(handles);

clearInstructions;

gui_updateActiveTab;

draw_channel;

%%
function delete_channel

handles=getHandles;

% First delete existing channel
as=handles.model.shorelines.domain.activechannel;
nr=handles.model.shorelines.domain.nrchannels;
delete (handles.model.shorelines.domain.channels(as).handle);
handles.model.shorelines.domain.channels=handles.model.shorelines.domain.channels([1:as-1,as+1:nr]);
handles.model.shorelines.domain.nrchannels=handles.model.shorelines.domain.nrchannels-1;
handles.model.shorelines.domain.activechannel=handles.model.shorelines.domain.nrchannels;
handles=update_channel_names(handles);
handles.model.shorelines.domain.activechannel=min(as,handles.model.shorelines.domain.nrchannels);
handles = ddb_shorelines_plot_channel(handles, 'plot');
setHandles(handles);

gui_updateActiveTab;

%%
function load_channels

handles=getHandles;

%[x,y]=landboundary('read',handles.model.shorelines.domain.channel.filename);
[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBchannels);
matname=handles.model.shorelines.domain.LDBchannels;
matname(end-2:end)='mat';
load(matname);
handles.model.shorelines.domain.channels=channels;
[xi,yi,nrchannels,i1,i2]= get_one_polygon(x,y,1);
for as=1:nrchannels
    [xi,yi,nrchannels,i1,i2]= get_one_polygon(x,y,as);
    handles.model.shorelines.domain.channels(as).x=xi;
    handles.model.shorelines.domain.channels(as).y=yi;
    handles.model.shorelines.domain.channels(as).length=length(xi);
    handles.model.shorelines.domain.channelnames{as}=['channel ',num2str(as)];
    handles.model.shorelines.domain.channels(as).name=['channel ',num2str(as)];
    handles.model.shorelines.domain.activechannel=as;
    setHandles(handles);
end
handles.model.shorelines.domain.nrchannels=nrchannels;
handles.model.shorelines.domain.activechannel=1;

handles = ddb_shorelines_plot_channel(handles, 'plot');

setHandles(handles);

gui_updateActiveTab;

%%
function save_channels

handles=getHandles;

x=handles.model.shorelines.domain.channels(1).x;
y=handles.model.shorelines.domain.channels(1).y;
for as=2:handles.model.shorelines.domain.nrchannels
    x=[x,NaN,handles.model.shorelines.domain.channels(as).x];
    y=[y,NaN,handles.model.shorelines.domain.channels(as).y];
end
%landboundary('write',handles.model.shorelines.domain.channel.filename,x,y);
out=[x;y]';
save(handles.model.shorelines.domain.LDBchannels,'out','-ascii');
setHandles(handles);

gui_updateActiveTab;

matname=handles.model.shorelines.domain.LDBchannels;
matname(end-2:end)='mat';
channels=handles.model.shorelines.domain.channels;
channels=rmfield(channels,'handle');
save(matname,'channels');
%%
function edit_name

handles=getHandles;
handles=update_channel_names(handles)
setHandles(handles);

%%
function handles=update_channel_names(handles)
handles.model.shorelines.domain.channelnames={''};
for as=1:handles.model.shorelines.domain.nrchannels
    handles.model.shorelines.domain.channelnames{as}=handles.model.shorelines.domain.channels(as).name;
end

gui_updateActiveTab;

