function ddb_shorelines_nourishments(varargin)

%%

ddb_zoomOff;

if isempty(varargin)

    % New tab selected
    %ddb_refreshScreen;
    % Make shoreline visible
    ddb_plotnourishments('update','active',1,'visible',1);

else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'selectfromlist'}
            select_from_list;
            edit_volume;
        case{'drawnourishment'}
            draw_nourishment;
        case{'deletenourishment'}
            delete_nourishment;
        case{'loadnourishments'}
            load_nourishments;
        case{'savenourishments'}
            save_nourishments;
        case{'editdate'}
            edit_date;
            edit_volume;
        case{'editvolume'}
            edit_volume;
        case{'editrate'}
            edit_rate;
    end
    
end

%%
function edit_date

handles=getHandles;
an=handles.model.shorelines.domain.activenourishment;
handles.model.shorelines.domain.nourishments(an).duration= ...
handles.model.shorelines.domain.nourishments(an).tend- ...
handles.model.shorelines.domain.nourishments(an).tstart

setHandles(handles);

%%
function edit_volume

handles=getHandles;

an=handles.model.shorelines.domain.activenourishment;
handles.model.shorelines.domain.nourishments(an).rate= round(...
handles.model.shorelines.domain.nourishments(an).volume*1e6/ ...
handles.model.shorelines.domain.nourishments(an).duration/ ...
handles.model.shorelines.domain.nourishments(an).nourlength/ ...
handles.model.shorelines.domain.d*365);

setHandles(handles);

%%
function edit_rate

handles=getHandles;

an=handles.model.shorelines.domain.activenourishment;
handles.model.shorelines.domain.nourishments(an).volume= ...
handles.model.shorelines.domain.nourishments(an).rate* ...
handles.model.shorelines.domain.nourishments(an).duration* ...
handles.model.shorelines.domain.nourishments(an).nourlength* ...
handles.model.shorelines.domain.d/365/1e6;

setHandles(handles);

%%
function select_from_list

handles=getHandles;

handles = ddb_shorelines_plot_nourishment(handles, 'plot');

setInstructions({'','Click on map to draw nourishment','Use right-click to end nourishment'});
setHandles(handles);
compute_length;

%%
function draw_nourishment

handles=getHandles;

gui_polyline('draw','axis',handles.GUIHandles.mapAxis,'tag','nourishments_tmp','marker','o', ...
    'createcallback',@create_nourishment, ...
    'linecolor','g','closed',1);

setInstructions({'','Click on map to draw nourishment','Use right-click to end nourishment'});

setHandles(handles);

%%
function create_nourishment(h,x,y)

handles=getHandles;

% Delete temporary nourishment

delete(h);
handles.model.shorelines.domain.nrnourishments=handles.model.shorelines.domain.nrnourishments+1;
handles.model.shorelines.domain.activenourishment=handles.model.shorelines.domain.nrnourishments;
as=handles.model.shorelines.domain.activenourishment;
handles.model.shorelines.domain.nourishments(as).x=x;
handles.model.shorelines.domain.nourishments(as).y=y;
handles.model.shorelines.domain.nourishmentnames{as}=['nourishment ',num2str(as)];
handles.model.shorelines.domain.nourishments(as).name=['nourishment ',num2str(as)];
handles.model.shorelines.domain.nourishment_transmission(as)=0;
handles.model.shorelines.domain.nourishments(as).length=length(handles.model.shorelines.domain.nourishments(as).x);
handles = ddb_shorelines_plot_nourishment(handles, 'plot');
handles.model.shorelines.status='waiting';

setHandles(handles);

clearInstructions;

gui_updateActiveTab;
compute_length

draw_nourishment;

%%
function delete_nourishment

handles=getHandles;

% First delete existing nourishment
as=handles.model.shorelines.domain.activenourishment;
nr=handles.model.shorelines.domain.nrnourishments;
delete (handles.model.shorelines.domain.nourishments(as).handle);
handles.model.shorelines.domain.nourishments=handles.model.shorelines.domain.nourishments([1:as-1,as+1:nr]);
handles.model.shorelines.domain.nrnourishments=handles.model.shorelines.domain.nrnourishments-1;
handles.model.shorelines.domain.activenourishment=handles.model.shorelines.domain.nrnourishments;
handles=update_nourishment_names(handles);
handles.model.shorelines.domain.activenourishment=min(as,handles.model.shorelines.domain.nrnourishments);
handles = ddb_shorelines_plot_nourishment(handles, 'plot');
setHandles(handles);

gui_updateActiveTab;

%%
function load_nourishments

handles=getHandles;

%[x,y]=landboundary('read',handles.model.shorelines.domain.nourishment.filename);
[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBnourish);
matname=handles.model.shorelines.domain.LDBnourish;
matname(end-2:end)='mat';
load(matname);
handles.model.shorelines.domain.nourishments=nourishments;

[xi,yi,nrnourishments,i1,i2]= get_one_polygon(x,y,1);

for as=1:nrnourishments
    [xi,yi,nrnourishments,i1,i2]= get_one_polygon(x,y,as);
    handles.model.shorelines.domain.nourishments(as).x=xi;
    handles.model.shorelines.domain.nourishments(as).y=yi;
    handles.model.shorelines.domain.nourishments(as).length=length(xi);
    handles.model.shorelines.domain.nourishmentnames{as}=['nourishment ',num2str(as)];
    handles.model.shorelines.domain.nourishments(as).name=['nourishment ',num2str(as)];
    handles.model.shorelines.domain.nourishments(as).transmission=0;
    handles.model.shorelines.domain.activenourishment=as;
    setHandles(handles);
    compute_length;
end
handles.model.shorelines.domain.nrnourishments=nrnourishments;
handles.model.shorelines.domain.activenourishment=1;

handles = ddb_shorelines_plot_nourishment(handles, 'plot');

setHandles(handles);

gui_updateActiveTab;

%%
function save_nourishments

handles=getHandles;

x=handles.model.shorelines.domain.nourishments(1).x;
y=handles.model.shorelines.domain.nourishments(1).y;
for as=2:handles.model.shorelines.domain.nrnourishments
    x=[x,NaN,handles.model.shorelines.domain.nourishments(as).x];
    y=[y,NaN,handles.model.shorelines.domain.nourishments(as).y];
end
%landboundary('write',handles.model.shorelines.domain.nourishment.filename,x,y);
out=[x;y]';
save(handles.model.shorelines.domain.LDBnourish,'out','-ascii');
setHandles(handles);

gui_updateActiveTab;

matname=handles.model.shorelines.domain.LDBnourish;
matname(end-2:end)='mat';
nourishments=handles.model.shorelines.domain.nourishments;
nourishments=rmfield(nourishments,'handle');
save(matname,'nourishments');
%%
function edit_name

handles=getHandles;
handles=update_nourishment_names(handles)
setHandles(handles);

%%
function handles=update_nourishment_names(handles)
handles.model.shorelines.domain.nourishmentnames={''};
for as=1:handles.model.shorelines.domain.nrnourishments
    handles.model.shorelines.domain.nourishmentnames{as}=handles.model.shorelines.domain.nourishments(as).name;
end

gui_updateActiveTab;

function compute_length
handles=getHandles;

x_mc=handles.model.shorelines.domain.shoreline.x;
y_mc=handles.model.shorelines.domain.shoreline.y;
an=handles.model.shorelines.domain.activenourishment;
xp=handles.model.shorelines.domain.nourishments(an).x;
yp=handles.model.shorelines.domain.nourishments(an).y;
P=InterX([x_mc;y_mc],[xp;yp]);
if ~isempty(P)
    xcross=P(1,:);
    ycross=P(2,:);
    handles.model.shorelines.domain.nourishments(an).nourlength=round(hypot(xcross(2)-xcross(1),ycross(2)-ycross(1)));
end
setHandles(handles);
gui_updateActiveTab;

