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

    handles=getHandles;

    pos = get(h, 'CurrentPoint');
    xi=pos(1,1);
    yi=pos(1,2);

    plttmp=plot(xi,yi,'k+');
    
    nn=get(h,'UserData');
    ifig=nn(1);
    isub=nn(2);
    handles.activefigure=ifig;
    handles.activesubplot=isub;
    
    % Add dataset
    handles.nrdatasets=handles.nrdatasets+1;
    id=handles.nrdatasets;
    handles.activedataset=handles.nrdatasets;
    
    handles.datasets(id).dataset.filetype='FreeText';
    handles.datasets(id).dataset.filename='';
    handles.datasets(id).dataset.type='freetext';
    handles.datasets(id).dataset.combineddataset=0;
    handles.datasets(id).dataset.datetime=0;
    handles.datasets(id).dataset.parameter='freetext';
    handles.datasets(id).dataset.block=0;
    handles.datasets(id).dataset.text={''};
    handles.datasets(id).dataset.x=xi;
    handles.datasets(id).dataset.y=yi;    
    handles.datasets(id).dataset.rotation=0;
    handles.datasets(id).dataset.curvature=0;
    handles.datasets(id).dataset.name=['Text ' handles.datasets(id).dataset.text{1}];

    % Add dataset to subplot
    n=handles.figures(ifig).figure.subplots(isub).subplot.nrdatasets+1;
    handles.figures(ifig).figure.subplots(isub).subplot.nrdatasets=n;
    handles.activedatasetinsubplot=n;
    
    handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset=muppet_setDefaultPlotOptions;
    handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset.name=handles.datasets(id).dataset.name;
    handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset.plotroutine='plottext';
    handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset.font.name='Helvetica';
    handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset.font.size=8;
    handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset.font.weight='normal';
    handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset.font.angle='normal';
    handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset.font.color='black';
    handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset.font.horizontalalignment='center';
    handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset.font.verticalalignment='baseline';

    % Get string
    %data=muppet_plotOptionsText('data',data);
    
    handles.datasets(id).dataset.text{1}='abc';
    
    delete(plttmp);

    if ~isempty(handles.datasets(id).dataset.text{1})
        handles.datasets(id).dataset.name=['Text ' handles.datasets(id).dataset.text{1}];
        handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset.name=handles.datasets(id).dataset.name;
%         data=RefreshAvailableDatasets(data);
%         data=RefreshActiveAvailableDatasetText(data);
%         data=RefreshDatasetsInSubplot(data);
        handles=muppet_updateDatasetNames(handles);
        handles=muppet_updateDatasetInSubplotNames(handles);
        handles=muppet_plotText(handles,ifig,isub,n,1);
        setHandles(handles);
        muppet_updateGUI;

%        figure(handles.figures(ifig).figure.handle);
%        tx=text(handles.datasets(id).dataset.position(1),handles.datasets(id).dataset.position(2),handles.datasets(id).dataset.string);
%        [tx,txc]=muppet_plotText(handles.datasets(id).dataset,handles.figures(ifig).figure.subplots(isub).subplot.datasets(n).dataset,handles.DefaultColors,FontRed,1);
    end
    
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

oktypes={'map2d'};
ii=strmatch(lower(typ),oktypes,'exact');

if isempty(ii)
    set(gcf,'Pointer','arrow');
    set(gcf,'WindowButtonDownFcn',[]);
else
    set(gcf, 'Pointer', 'crosshair');
    set(gcf, 'windowbuttondownfcn', {@gettextposition,h});
end
