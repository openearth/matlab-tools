function muppet_UIAddText(varargin)

h=findobj(gcf,'Tag','UIToggleToolEditFigure');
set(h,'State','off');
h=(findobj(gcf,'TooltipString','Zoom In'));
set(h,'State','off');
h=(findobj(gcf,'TooltipString','Zoom Out'));
set(h,'State','off');
h=(findobj(gcf,'TooltipString','Pan'));
set(h,'State','off');

muppet_setPlotEdit(0);

set(gcf, 'windowbuttonmotionfcn', {@movemouse});

%%
function gettextposition(imagefig, varargins,h) 

set(gcf, 'windowbuttonmotionfcn',[]);

if strcmp(get(gcf,'SelectionType'),'normal')

    fig=getappdata(gcf,'figure');
    ifig=fig.number;
    
    % Find subplot number
    hax=gca;
    hh=get(hax,'UserData');
    isub=hh(2);
    
    pos = get(h, 'CurrentPoint');
    xi0=pos(1,1);
    yi0=pos(1,2);

    plttmp=plot(xi0,yi0,'k+');
        
    plt=fig.subplots(isub).subplot;
    switch plt.projection
        case{'mercator'}
            yi=invmerc(yi0);
        case{'albers'}
            [xi,yi]=albers(xi0,yi0,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
        otherwise
            xi=xi0;
            yi=yi0;
    end

    % Add dataset to subplot
    n=fig.subplots(isub).subplot.nrdatasets+1;
    fig.subplots(isub).subplot.nrdatasets=n;
    
    fig.subplots(isub).subplot.datasets(n).dataset=muppet_setDefaultPlotOptions;
    fig.subplots(isub).subplot.datasets(n).dataset.plotroutine='plotinteractivetext';
    fig.subplots(isub).subplot.datasets(n).dataset.font.name='Helvetica';
    fig.subplots(isub).subplot.datasets(n).dataset.font.size=8;
    fig.subplots(isub).subplot.datasets(n).dataset.font.weight='normal';
    fig.subplots(isub).subplot.datasets(n).dataset.font.angle='normal';
    fig.subplots(isub).subplot.datasets(n).dataset.font.color='black';
    fig.subplots(isub).subplot.datasets(n).dataset.type='interactivetext';

    fig.changed=1;
    fig.subplots(isub).subplot.annotationsadded=1;

     delete(plttmp);
     h=text(xi0,yi0,'abc');
     setappdata(h,'axis',gca);
     setappdata(h,'text','abc');
     setappdata(h,'x',xi);
     setappdata(h,'y',yi);
     setappdata(h,'rotation',0);
     setappdata(h,'curvature',0);
     set(h,'Tag','interactivetext');

     usd=[ifig,isub,n];
     options.userdata=usd;
     setappdata(h,'options',options);
     
     fig.subplots(isub).subplot.annotationsadded=1;

     setappdata(gcf,'figure',fig);
     
end

set(gcf, 'windowbuttondownfcn','');
set(gcf,'Pointer','arrow');

%%

function movemouse(imagefig, varargins)

handles=getHandles;

ifig=get(gcf,'UserData');

posgcf = get(gcf, 'CurrentPoint')/handles.figures(ifig).figure.cm2pix;

typ='none';

for j=1:handles.figures(ifig).figure.nrsubplots
    h0=findobj(gcf,'Tag','axis','UserData',[ifig,j]);
    if ~isempty(h0)
        pos=get(h0,'Position')/handles.figures(ifig).figure.cm2pix;
        if posgcf(1)>pos(1) && posgcf(1)<pos(1)+pos(3) && posgcf(2)>pos(2) && posgcf(2)<pos(2)+pos(4)
            typ=handles.figures(ifig).figure.subplots(j).subplot.type;
            h=h0;
        end
    end
end

oktypes={'map'};
ii=strmatch(lower(typ),oktypes,'exact');

if isempty(ii)
    set(gcf,'Pointer','arrow');
    set(gcf,'WindowButtonDownFcn',[]);
else
    set(gcf, 'Pointer', 'crosshair');
    set(gcf, 'windowbuttondownfcn', {@gettextposition,h});
end
