function muppet_UIDrawFreeHand(varargin)

muppet_setPlotEdit(0);
plotedit off;

fig=getappdata(gcf,'figure');
ifig=fig.number;

n=0;
for j=1:fig.nrsubplots
    if strcmpi(fig.subplots(j).subplot.type,'map2d')
        n=n+1;
        h(n)=findobj(gcf,'Tag','axis','UserData',[ifig,j]);
    end
end

opt=muppet_setDefaultPlotOptions;

opt.markersize=4;
opt.fillclosedpolygons=1;
opt.fillcolor='red';

if opt.fillclosedpolygons
    facecolor=colorlist('getrgb','color',opt.fillcolor);
else
    facecolor='none';
end

switch varargin{3}
    case 1
        tp='polyline';
    case 2
        tp='spline';
    case 3
        tp='curvedarrow';
end

if n>0
    gui_polyline('draw','tag','interactivepolyline','marker','o', ...
        'createcallback',@createPolygon, ...
        'changecallback',@muppet_changeInteractivePolygon,'axis',h, ...
        'markersize',opt.markersize,'markeredgecolor',colorlist('getrgb','color',opt.markeredgecolor), ...
        'markerfacecolor',colorlist('getrgb','color',opt.markerfacecolor), ...
        'linewidth',opt.linewidth,'linecolor',colorlist('getrgb','color',opt.linecolor),'linestyle',opt.linestyle, ...
        'facecolor',facecolor, ...
        'arrowthickness',opt.arrowthickness,'headthickness',opt.headthickness,'headlength',opt.headlength, ...
        'type',tp,'closed',0);
end


%%
function createPolygon(h,x,y,nr)

fig=getappdata(gcf,'figure');
ifig=fig.number;

% Find subplot number
hax=getappdata(h,'axis');
hh=get(hax,'UserData');
isub=hh(2);

fig.subplots(isub).subplot.annotationsadded=1;

fig.subplots(isub).subplot.nrdatasets=fig.subplots(isub).subplot.nrdatasets+1;
nrd=fig.subplots(isub).subplot.nrdatasets;
opt=muppet_setDefaultPlotOptions;

opt.markersize=4;
opt.fillclosedpolygons=1;
opt.fillcolor='red';

fig.subplots(isub).subplot.datasets(nrd).dataset=opt;

options=getappdata(h,'options');
usd=[ifig,isub,nrd];
options.userdata=usd;
setappdata(h,'options',options);

fig.changed=1;

setappdata(gcf,'figure',fig);
